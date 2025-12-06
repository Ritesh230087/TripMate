import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tripmate/app/service_locator/service_locator.dart';
import 'package:tripmate/features/auth/presentation/view/login_view.dart';
import 'package:tripmate/features/auth/presentation/view_model/login_viewmodel/login_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TripMate',
      theme: ThemeData(primarySwatch: Colors.amber, useMaterial3: true),
      home: BlocProvider(
        create: (context) => serviceLocator<LoginViewModel>(),
        child: const LoginView(),
      ),
    );
  }
}