import 'package:get_it/get_it.dart';
import '../services/error_service.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../../features/auth/services/auth_service.dart';

final GetIt serviceLocator = GetIt.instance;

void setupServiceLocator() {
  // Core services
  serviceLocator.registerLazySingleton(() => ErrorService());
  serviceLocator.registerLazySingleton(() => ApiService());
  serviceLocator.registerLazySingleton(() => LocationService());

  // Auth services
  serviceLocator.registerLazySingleton(() => AuthService());
  
  // Profile services
  serviceLocator.registerLazySingleton(() => ProfileService());
}
