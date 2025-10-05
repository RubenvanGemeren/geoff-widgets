import '../../../../core/api/weather_service.dart';
import '../../../../core/api/notification_service.dart';

abstract class AmbientRepository {
  Future<WeatherData?> getCurrentWeather(String location);
  WeatherData getMockWeatherData();
  Stream<List<NotificationData>> getNotificationsStream();
  void addNotification(String title, String message);
  void markNotificationAsRead(String notificationId);
  void clearAllNotifications();
}
