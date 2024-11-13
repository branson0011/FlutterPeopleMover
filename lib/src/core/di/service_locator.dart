import 'package:get_it/get_it.dart';
import '../services/error_service.dart';
import '../services/location_service.dart';
import '../services/biometric_service.dart';
import '../../features/auth/services/auth_service.dart';

final GetIt serviceLocator = GetIt.instance;

void setupServiceLocator() {
  // Core services
  serviceLocator.registerLazySingleton(() => ErrorService());
  serviceLocator.registerLazySingleton(() => LocationService());
  serviceLocator.registerLazySingleton(() => BiometricService());

  // Auth services
  serviceLocator.registerLazySingleton(() => AuthService());
}
