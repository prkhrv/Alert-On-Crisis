import 'package:flutter/material.dart';
import './app/alert_on_crises.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'dart:io' show Platform;

import 'dart:async';

List<CameraDescription> cameras;

Future<Null> main() async {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);
  
  Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([PermissionGroup.camera, PermissionGroup.location, PermissionGroup.microphone]);

  print(permissions);
  cameras = await availableCameras();

  final FirebaseApp app = await FirebaseApp.configure(
    name: 'test',
    options: FirebaseOptions(
      googleAppID: Platform.isIOS
          ? '1:159623150305:ios:4a213ef3dbd8997b'
          : '1:109477341545:android:e46ed4bf794a6d13',
      gcmSenderID: '109477341545',
      apiKey: 'AIzaSyCRtLEnSHcn1B2m_HA4owpIIOIGvDBJ_yw',
      projectID: 'alert-on-crises',
    ),
  );
  final FirebaseStorage storage = FirebaseStorage(app: app, storageBucket: 'gs://alert-on-crises.appspot.com');

  runApp(new AlertOnCrises(cameras, storage));
}
