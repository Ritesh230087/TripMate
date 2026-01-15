import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripmate/app/constant/api_endpoints.dart';
import 'package:tripmate/app/shared_pref/token_shared_pref.dart';
import 'package:tripmate/core/network/api_service.dart';
import 'package:tripmate/core/network/dio_error_interceptor.dart';
// ✅ Import your SocketService here
import 'package:tripmate/core/network/socket_service.dart'; 

// --- Auth Feature Imports ---
import 'package:tripmate/features/auth/data/data_source/remote_data_source/auth_remote_data_source.dart';
import 'package:tripmate/features/auth/data/repository/remote_repository/auth_remote_repository.dart';
import 'package:tripmate/features/auth/domain/repository/auth_repository.dart';
import 'package:tripmate/features/auth/domain/use_case/login_usecase.dart';
import 'package:tripmate/features/auth/domain/use_case/register_use_case.dart';
import 'package:tripmate/features/auth/presentation/view_model/login_viewmodel/login_viewmodel.dart';
import 'package:tripmate/features/auth/presentation/view_model/register_viewmodel/register_viewmodel.dart';

// --- Home Feature Imports ---
import 'package:tripmate/features/home/presentation/view_model/home_view_model.dart';
import 'package:tripmate/features/notifications/data/data_source/remote_data_source/notification_remote_data_source.dart';

// --- Profile Feature Imports ---
import 'package:tripmate/features/profile/data/data_source/remote_data_source/profile_remote_data_source.dart';
import 'package:tripmate/features/profile/data/repository/profile_repository_impl.dart';
import 'package:tripmate/features/profile/domain/repository/profile_repository.dart';
import 'package:tripmate/features/profile/domain/use_case/get_profile_usecase.dart';
import 'package:tripmate/features/profile/presentation/view_model/profile_view_model.dart';

// --- Ride & Rider Feature Imports ---
import 'package:tripmate/features/ride/data/data_source/remote_data_source/ride_remote_data_source.dart';
import 'package:tripmate/features/ride/data/data_source/remote_data_source/rider_kyc_remote_data_source.dart';
import 'package:tripmate/features/ride/data/repository/ride_repository_impl.dart';
import 'package:tripmate/features/ride/data/repository/rider_kyc_repository_impl.dart';
import 'package:tripmate/features/ride/domain/repository/ride_repository.dart';
import 'package:tripmate/features/ride/domain/repository/rider_kyc_repository.dart';
import 'package:tripmate/features/ride/domain/use_case/apply_rider_usecase.dart';
import 'package:tripmate/features/ride/domain/use_case/publish_ride_usecase.dart';
import 'package:tripmate/features/ride/domain/use_case/send_request_usecase.dart';
import 'package:tripmate/features/ride/presentation/view_model/publish_ride_bloc.dart';
import 'package:tripmate/features/ride/presentation/view_model/request_bloc.dart';
import 'package:tripmate/features/ride/presentation/view_model/rider_kyc_view_model.dart';
import 'package:tripmate/features/ride/presentation/view_model/rider_request_bloc.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  // ==========================
  // 1. Core & External
  // ==========================
  final dio = Dio();
  dio.options.baseUrl = ApiEndpoints.baseUrl;
  dio.interceptors.add(DioErrorInterceptor());
  dio.interceptors.add(PrettyDioLogger(
    requestHeader: true,
    requestBody: true,
    responseHeader: true,
  ));
  
  serviceLocator.registerLazySingleton<Dio>(() => dio);
  serviceLocator.registerLazySingleton<ApiService>(() => ApiService(serviceLocator()));
  
  // ✅ REGISTER SOCKET SERVICE HERE
  serviceLocator.registerLazySingleton<SocketService>(() => SocketService());

  final sharedPrefs = await SharedPreferences.getInstance();
  serviceLocator.registerLazySingleton<SharedPreferences>(() => sharedPrefs);
  serviceLocator.registerLazySingleton<TokenSharedPrefs>(() => TokenSharedPrefs(serviceLocator()));

  // ==========================
  // 2. Auth Feature
  // ==========================
  serviceLocator.registerFactory<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(serviceLocator()),
  );
  serviceLocator.registerFactory<IAuthRepository>(
    () => AuthRemoteRepository(serviceLocator()),
  );
  
  serviceLocator.registerFactory<LoginUseCase>(
    () => LoginUseCase(serviceLocator(), serviceLocator()),
  );
  serviceLocator.registerFactory<RegisterUseCase>(
    () => RegisterUseCase(serviceLocator()),
  );

  serviceLocator.registerFactory<LoginViewModel>(
    () => LoginViewModel(serviceLocator()),
  );
  serviceLocator.registerFactory<RegisterViewModel>(
    () => RegisterViewModel(serviceLocator()),
  );

  // ==========================
  // 3. Home Feature
  // ==========================
  serviceLocator.registerFactory<HomeViewModel>(
    () => HomeViewModel(),
  );

  // ==========================
  // 4. Profile Feature
  // ==========================
  serviceLocator.registerFactory<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSource(serviceLocator(), serviceLocator()),
  );
  serviceLocator.registerFactory<IProfileRepository>(
    () => ProfileRepositoryImpl(serviceLocator()),
  );
  serviceLocator.registerFactory<GetProfileUseCase>(
    () => GetProfileUseCase(serviceLocator()),
  );
  serviceLocator.registerFactory<ProfileViewModel>(
    () => ProfileViewModel(getProfileUseCase: serviceLocator()),
  );


  serviceLocator.registerLazySingleton<RiderRemoteDataSource>(
    () => RiderRemoteDataSource(serviceLocator(), serviceLocator()),
  );
  serviceLocator.registerLazySingleton<RideRemoteDataSource>(
    () => RideRemoteDataSource(serviceLocator(), serviceLocator()),
  );

  // --- Repositories ---
  serviceLocator.registerLazySingleton<IRiderRepository>(
    () => RiderRepositoryImpl(serviceLocator()),
  );
  serviceLocator.registerLazySingleton<IRideRepository>(
    () => RideRepositoryImpl(serviceLocator()),
  );

  // --- Use Cases ---
  serviceLocator.registerFactory<ApplyRiderUseCase>(
    () => ApplyRiderUseCase(serviceLocator()),
  );
  serviceLocator.registerFactory<PublishRideUseCase>(
    () => PublishRideUseCase(serviceLocator()),
  );
  serviceLocator.registerFactory<SendRequestUseCase>(
    () => SendRequestUseCase(serviceLocator()),
  );

  // --- Blocs / ViewModels ---
  serviceLocator.registerFactory<RiderKycViewModel>(
    () => RiderKycViewModel(serviceLocator()),
  );
  
  serviceLocator.registerFactory<RideBloc>(
    () => RideBloc(serviceLocator()),
  );

  serviceLocator.registerFactory<RequestBloc>(
    () => RequestBloc(
      sendRequestUseCase: serviceLocator<SendRequestUseCase>(),
    ),
  );

  serviceLocator.registerFactory<RiderRequestBloc>(
    () => RiderRequestBloc(
      serviceLocator<RideRemoteDataSource>(),
    ),
  );

    serviceLocator.registerFactory<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSource(serviceLocator<Dio>(), serviceLocator<TokenSharedPrefs>()),
  );
}