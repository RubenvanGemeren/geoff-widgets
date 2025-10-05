import 'dart:async';

class NotificationData {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  NotificationData({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });
}

class NotificationService {
  final List<NotificationData> _notifications = [];
  final StreamController<List<NotificationData>> _notificationsController =
      StreamController<List<NotificationData>>.broadcast();

  Stream<List<NotificationData>> get notificationsStream => _notificationsController.stream;
  List<NotificationData> get notifications => List.unmodifiable(_notifications);

  void addNotification(String title, String message) {
    final notification = NotificationData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
    );

    _notifications.insert(0, notification);
    _notificationsController.add(_notifications);
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = NotificationData(
        id: _notifications[index].id,
        title: _notifications[index].title,
        message: _notifications[index].message,
        timestamp: _notifications[index].timestamp,
        isRead: true,
      );
      _notificationsController.add(_notifications);
    }
  }

  void clearAllNotifications() {
    _notifications.clear();
    _notificationsController.add(_notifications);
  }

  void dispose() {
    _notificationsController.close();
  }
}
