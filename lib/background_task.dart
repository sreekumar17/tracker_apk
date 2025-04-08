import 'package:workmanager/workmanager.dart';
import 'location_service.dart';
import 'db_helper.dart';
import 'upload_service.dart';

const taskName = "backgroundLocationTask";

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final position = await LocationService().getCurrentLocation();
    if (position != null) {
      await DBHelper.insertLocation(position.latitude, position.longitude);
    }

    await UploadService.uploadToServer();
    return Future.value(true);
  });
}
