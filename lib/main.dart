import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tripmate/app/service_locator/service_locator.dart';
import 'package:tripmate/core/network/socket_service.dart';
import 'package:tripmate/core/services/notification_service.dart';
import 'package:tripmate/features/auth/presentation/view/reset_password_view.dart';
import 'package:tripmate/features/auth/presentation/view_model/login_viewmodel/login_viewmodel.dart';
import 'package:tripmate/features/auth/presentation/view_model/register_viewmodel/register_viewmodel.dart';
import 'package:tripmate/features/home/presentation/view_model/home_view_model.dart';
import 'package:tripmate/features/profile/presentation/view_model/profile_event.dart'; // Import ProfileEvent
import 'package:tripmate/features/profile/presentation/view_model/profile_view_model.dart';
import 'package:tripmate/features/splash/presentation/view/splash_view.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  NotificationService.initialize();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.requestPermission();

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    NotificationService.display(message);
  });

  await initDependencies();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;


  @override
  void initState() {
    super.initState();
    _initDeepLinks();
    _setupGlobalSocketListeners();
  }

  // Real-time KYC Update Listener via Socket
  void _setupGlobalSocketListeners() {
    final socket = SocketService().socket;

    socket.on('new_notification', (data) {
      // If a KYC update is received, refresh the profile across the app
      if (data['type'] == 'kyc_update') {
        final context = navigatorKey.currentContext;
        if (context != null) {
          context.read<ProfileViewModel>().add(LoadProfileEvent());
          
          // Show real-time feedback
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message']),
              backgroundColor: data['title'].contains('Approved') ? Colors.green : Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    });
  }

  void _initDeepLinks() async {
    _appLinks = AppLinks();
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) _handleNavigation(initialUri);
    } catch (e) {
      debugPrint("❌ Deep Link Error: $e");
    }

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleNavigation(uri);
    });
  }

  void _handleNavigation(Uri uri) {
    if (uri.toString().contains('reset-password')) {
      final token = uri.pathSegments.last;
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => ResetPasswordView(token: token)),
      );
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => serviceLocator<LoginViewModel>()),
        BlocProvider(create: (_) => serviceLocator<RegisterViewModel>()),
        BlocProvider(create: (_) => serviceLocator<HomeViewModel>()),
        BlocProvider(create: (_) => serviceLocator<ProfileViewModel>()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'TripMate',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF9F5E9),
          primaryColor: const Color(0xFF8B4513),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF8B4513),
            primary: const Color(0xFF8B4513),
          ),
        ),
        home: const SplashView(),
      ),
    );
  }
}