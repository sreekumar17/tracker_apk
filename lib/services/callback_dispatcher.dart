import 'package:workmanager/workmanager.dart';
import 'notification_service.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await NotificationService.init();
    await NotificationService.updateNotification(); // 🔁 Update existing notification
    return Future.value(true);
  });
}
