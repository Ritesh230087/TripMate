// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:provider/provider.dart';
// import 'package:rolo/app/service_locator/service_locator.dart';
// import 'package:rolo/app/themes/themes_data.dart';
// import 'package:rolo/features/auth/presentation/view_model/login_view_model/login_view_model.dart';
// import 'package:rolo/features/cart/presentation/view_model/cart_event.dart';
// import 'package:rolo/features/cart/presentation/view_model/cart_viewmodel.dart';
// import 'package:rolo/features/order/domain/use_case/create_order_usecase.dart';
// import 'package:rolo/features/order/presentation/view_model/order_history_view_model.dart';
// import 'package:rolo/features/splash/presentation/view/splash_screen_view.dart';
// import 'package:rolo/features/splash/presentation/view_model/splash_view_model.dart';
// import 'package:rolo/features/auth/presentation/view_model/register_view_model/register_view_model.dart';
// import 'package:rolo/features/notification/presentation/view_model/notification_viewmodel.dart';

// class App extends StatelessWidget {
//   const App({super.key});
//   static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         Provider<CreateOrderUseCase>(
//           create: (_) => serviceLocator<CreateOrderUseCase>(),
//         ),
//       ],
//       child: MultiBlocProvider(
//         providers: [
//           BlocProvider.value(value: serviceLocator<SplashViewModel>()),
//           BlocProvider(create: (_) => serviceLocator<RegisterViewModel>()),
//           BlocProvider(create: (_) => serviceLocator<LoginViewModel>()),
//           BlocProvider(create: (_) => serviceLocator<OrderHistoryViewModel>()),
//           BlocProvider(
//             create: (_) => serviceLocator<CartViewModel>()..add(LoadCart()),
//           ),
//           BlocProvider(
//             create: (_) => serviceLocator<NotificationViewModel>(),
//           ),
//         ],
//         child: MaterialApp(
//           navigatorKey: navigatorKey,
//           debugShowCheckedModeBanner: false,
//           theme: getApplicationTheme(),
//           home: const SplashScreen(),
//         ),
//       ),
//     );
//   }
// }