import '../../../../core/api/weather_service.dart';
import '../../../../core/api/notification_service.dart';
import '../../domain/repositories/ambient_repository.dart';

class AmbientRepositoryImpl implements AmbientRepository {
  final WeatherService _weatherService;
  final NotificationService _notificationService;

  AmbientRepositoryImpl({
    required WeatherService weatherService,
    required NotificationService notificationService,
  }) : _weatherService = weatherService,
       _notificationService = notificationService;

  @override
  Future<WeatherData?> getCurrentWeather(String location) async {
    return await _weatherService.getCurrentWeather(location);
  }

  @override
  WeatherData getMockWeatherData() {
    return _weatherService.getMockWeatherData();
  }

  @override
  Stream<List<NotificationData>> getNotificationsStream() {
    return _notificationService.notificationsStream;
  }

  @override
  void addNotification(String title, String message) {
    _notificationService.addNotification(title, message);
  }

  @override
  void markNotificationAsRead(String notificationId) {
    _notificationService.markAsRead(notificationId);
  }

  @override
  void clearAllNotifications() {
    _notificationService.clearAllNotifications();
  }
}
