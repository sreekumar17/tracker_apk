import 'package:workmanager/workmanager.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'helpers/database_helper.dart'; // ✅ Import from helpers folder

const taskName = "backgroundLocationTask"; // ✅ Define it here too

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    Location location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return Future.value(false);
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted != PermissionStatus.granted) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return Future.value(false);
      }
    }

    LocationData loc = await location.getLocation();

    await DatabaseHelper.insertLocation(loc.latitude!, loc.longitude!);

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
