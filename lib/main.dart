import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:workmanager/workmanager.dart';
import 'helpers/database_helper.dart';
import 'background_task.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
import 'dart:async';
import 'services/foreground_service.dart'; // Import the new foreground service

const taskName = "backgroundLocationTask";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the foreground service
  await initializeForegroundService(); // Now works with await

  // Initialize Workmanager
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  // Register the periodic task for background work
  Workmanager().registerPeriodicTask(
    "1",
    taskName,
    frequency: Duration(minutes: 15), // Adjust the frequency as needed
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

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final loc.Location location = loc.Location();
  bool _serviceEnabled = false;
  loc.PermissionStatus? _permissionGranted;
  loc.LocationData? _locationData;
  bool _isListening = false;
  StreamSubscription<loc.LocationData>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initLocation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initLocation();
    }
  }

  Future<void> _initLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) return;
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) return;
    }

    if (await perm.Permission.locationAlways.isDenied) {
      final bgStatus = await perm.Permission.locationAlways.request();
      if (!bgStatus.isGranted) {
        debugPrint("❌ Background location permission not granted");
        return;
      }
    }

    await location.changeSettings(interval: 2000, distanceFilter: 1);

    if (!_isListening) {
      _isListening = true;

      _locationSubscription = location.onLocationChanged.listen((loc.LocationData currentLocation) async {
        setState(() {
          _locationData = currentLocation;
        });

        await DatabaseHelper.insertLocation(
          currentLocation.latitude ?? 0.0,
          currentLocation.longitude ?? 0.0,
        );
      });
    }
  }

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
