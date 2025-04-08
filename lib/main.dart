import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'background_task.dart';
import 'location_service.dart';
import 'db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.initDB();
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  Workmanager().registerPeriodicTask(
    "1", // unique name
    taskName,
    frequency: Duration(minutes: 15), // Android min is 15 mins
    initialDelay: Duration(minutes: 1),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LocationHome(),
    );
  }
}

class LocationHome extends StatefulWidget {
  @override
  _LocationHomeState createState() => _LocationHomeState();
}

class _LocationHomeState extends State<LocationHome> {
  String status = 'Collecting...';

  @override
  void initState() {
    super.initState();
    checkLocation();
  }

 Future<void> checkLocation() async {
  final pos = await LocationService().getCurrentLocation();
  if (pos != null) {
    await DBHelper.insertLocation(pos.latitude, pos.longitude);
    setState(() {
      status = 'Location saved: (${pos.latitude}, ${pos.longitude})';
    });
  } else {
    setState(() {
      status = 'Location not available';
    });

    // ✅ Show SnackBar here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please enable location services")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Location Tracker')),
      body: Center(child: Text(status)),
    );
  }
}
