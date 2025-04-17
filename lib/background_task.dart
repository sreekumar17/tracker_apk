import 'package:workmanager/workmanager.dart';
import 'package:location/location.dart' as loc;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'helpers/database_helper.dart';
import 'package:permission_handler/permission_handler.dart' as perm;

const taskName = "backgroundLocationTask";

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final location = loc.Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return Future.value(false);
    }

    loc.PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted != loc.PermissionStatus.granted) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        return Future.value(false);
      }
    }

    if (await perm.Permission.locationAlways.isDenied) {
      final bgStatus = await perm.Permission.locationAlways.request();
      if (!bgStatus.isGranted) {
        return Future.value(false);
      }
    }

    loc.LocationData locData = await location.getLocation();

    await DatabaseHelper.insertLocation(
      locData.latitude ?? 0.0,
      locData.longitude ?? 0.0,
    );

    List<Map<String, dynamic>> data = await DatabaseHelper.getAllLocations();

    final response = await http.post(
      Uri.parse('https://jsonplaceholder.typicode.com/posts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'locations': data}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      await DatabaseHelper.clearLocations();
    }

    return Future.value(true);
  });
}
