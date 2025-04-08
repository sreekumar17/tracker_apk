import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;
import 'helpers/database_helper.dart'; // ✅ This is correct now
import 'background_task.dart';
import 'package:permission_handler/permission_handler.dart' as perm;

const taskName = "backgroundLocationTask"; // ✅ Add this to fix usage

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  Workmanager().registerPeriodicTask(
    "1",
    taskName,
    frequency: Duration(minutes: 15),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Location location = Location();
  bool _serviceEnabled = false;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

 void _initLocation() async {  _serviceEnabled = await location.serviceEnabled(); if (!_serviceEnabled) { _serviceEnabled = await location.requestService(); if (!_serviceEnabled) return;  }

 _permissionGranted = await location.hasPermission(); if (_permissionGranted == PermissionStatus.denied) { _permissionGranted = await location.requestPermission(); if (_permissionGranted != PermissionStatus.granted) return;  }

if (await perm.Permission.locationAlways.isDenied) { final bgStatus = await perm.Permission.locationAlways.request(); if (!bgStatus.isGranted) { debugPrint("❌ Background location permission not granted"); return;  } }

 location.changeSettings(interval: 2000, distanceFilter: 1); location.onLocationChanged.listen((LocationData currentLocation) async { setState(() { _locationData = currentLocation; });
 
 await DatabaseHelper.insertLocation(
  currentLocation.latitude!,
  currentLocation.longitude!,
);
}); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Live Location')),
      body: Center(
        child: _locationData == null
            ? CircularProgressIndicator()
            : Text(
                'Lat: ${_locationData!.latitude}, Lng: ${_locationData!.longitude}',
                style: TextStyle(fontSize: 20),
              ),
      ),
    );
  }
}
