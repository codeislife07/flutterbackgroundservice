import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';



final FlutterLocalNotificationsPlugin flutterLocalPlugin =FlutterLocalNotificationsPlugin();
const AndroidNotificationChannel notificationChannel=AndroidNotificationChannel(
    "coding is life foreground",
    "coding is life foreground service",
    description: "This is channel des....",
  importance: Importance.high
);


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await initservice();
  runApp(const MyApp());
}

Future<void> initservice()async{
  var service=FlutterBackgroundService();
  //set for ios
  if(Platform.isIOS){
    await flutterLocalPlugin.initialize(const InitializationSettings(
      iOS: DarwinInitializationSettings()
    ));
  }

  await flutterLocalPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(notificationChannel);

  //service init and start
  await service.configure(
      iosConfiguration: IosConfiguration(
        onBackground: iosBackground,
        onForeground: onStart
      ),
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: "coding is life",
        initialNotificationTitle: "Coding is life",
        initialNotificationContent: "Awsome Content",
        foregroundServiceNotificationId: 90
      )
  );
  service.startService();

  //for ios enable background fetch from add capability inside background mode

}

//onstart method
@pragma("vm:enry-point")
void onStart(ServiceInstance service){
  DartPluginRegistrant.ensureInitialized();

  service.on("setAsForeground").listen((event) {
    print("foreground ===============");
  });

  service.on("setAsBackground").listen((event) {
    print("background ===============");
  });

  service.on("stopService").listen((event) {
    service.stopSelf();
  });

  //display notification as service
  Timer.periodic(Duration(seconds: 2), (timer) {
    flutterLocalPlugin.show(
        90,
        "Cool Service",
        "Awsome ${DateTime.now()}",
        NotificationDetails(android:AndroidNotificationDetails("coding is life","coding is life service",ongoing: true,icon: "app_icon")));
  });
  print("Background service ${DateTime.now()}") ;

}

//iosbackground
@pragma("vm:enry-point")
Future<bool> iosBackground(ServiceInstance service)async{
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //layout
            SizedBox(height: 200,),
            ElevatedButton(onPressed: (){
              FlutterBackgroundService().invoke("stopService");
            }, child: Text("stop service")),
            ElevatedButton(onPressed: (){
              FlutterBackgroundService().startService();
            }, child: Text("start service")),
          ],
        ),
      ),

    );
  }
}
