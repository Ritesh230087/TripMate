import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripmate/app/constant/api_endpoints.dart';
import 'package:tripmate/app/shared_pref/token_shared_pref.dart';
import 'package:tripmate/core/network/api_service.dart';
import 'package:tripmate/core/network/dio_error_interceptor.dart';
import 'package:tripmate/features/auth/data/data_source/remote_data_source/auth_remote_data_source.dart';
import 'package:tripmate/features/auth/data/repository/remote_repository/auth_remote_repository.dart';
import 'package:tripmate/features/auth/domain/repository/auth_repository.dart';
import 'package:tripmate/features/auth/domain/use_case/login_usecase.dart';
import 'package:tripmate/features/auth/domain/use_case/register_use_case.dart';
import 'package:tripmate/features/auth/presentation/view_model/login_viewmodel/login_viewmodel.dart';
import 'package:tripmate/features/auth/presentation/view_model/register_viewmodel/register_viewmodel.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  // --- Core ---
  final dio = Dio();
  dio.options.baseUrl = ApiEndpoints.baseUrl;
  dio.interceptors.add(DioErrorInterceptor());
  dio.interceptors.add(PrettyDioLogger(requestHeader: true, requestBody: true, responseHeader: true));
  
  serviceLocator.registerLazySingleton<Dio>(() => dio);
  serviceLocator.registerLazySingleton<ApiService>(() => ApiService(serviceLocator()));
  
  final sharedPrefs = await SharedPreferences.getInstance();
  serviceLocator.registerLazySingleton<SharedPreferences>(() => sharedPrefs);
  serviceLocator.registerLazySingleton<TokenSharedPrefs>(() => TokenSharedPrefs(serviceLocator()));

  // --- Auth Feature ---
  serviceLocator.registerFactory<AuthRemoteDataSource>(() => AuthRemoteDataSource(serviceLocator()));
  serviceLocator.registerFactory<IAuthRepository>(() => AuthRemoteRepository(serviceLocator()));
  
  serviceLocator.registerFactory<LoginUseCase>(() => LoginUseCase(serviceLocator(), serviceLocator()));
  serviceLocator.registerFactory<RegisterUseCase>(() => RegisterUseCase(serviceLocator()));

  serviceLocator.registerFactory<LoginViewModel>(() => LoginViewModel(serviceLocator()));
  serviceLocator.registerFactory<RegisterViewModel>(() => RegisterViewModel(serviceLocator()));
}