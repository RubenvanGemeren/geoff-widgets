import 'package:get_it/get_it.dart';
import '../storage/local_storage_service.dart';
import '../api/weather_service.dart';
import '../api/notification_service.dart';
import '../../features/ambient/domain/repositories/ambient_repository.dart';
import '../../features/ambient/data/repositories/ambient_repository_impl.dart';

final GetIt serviceLocator = GetIt.instance;

class ServiceLocator {
  static Future<void> setup() async {
    // Core Services
    serviceLocator.registerLazySingleton<LocalStorageService>(
      () => LocalStorageService(),
    );

    serviceLocator.registerLazySingleton<WeatherService>(
      () => WeatherService(),
    );

    serviceLocator.registerLazySingleton<NotificationService>(
      () => NotificationService(),
    );

    // Repositories
    serviceLocator.registerLazySingleton<AmbientRepository>(
      () => AmbientRepositoryImpl(
        weatherService: serviceLocator<WeatherService>(),
        notificationService: serviceLocator<NotificationService>(),
      ),
    );
  }
}
