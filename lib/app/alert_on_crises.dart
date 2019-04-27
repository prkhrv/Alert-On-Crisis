import 'package:alert_on_crises/app/pages/distress_alert_screen.dart';
import 'package:flutter/material.dart';
import './pages/login_screen.dart';
import './pages/splash_screen.dart';
import 'package:alert_on_crises/app/pages/fingerprint_screen.dart';

class AlertOnCrises extends StatelessWidget {
  final cameras;
  final firebaseStorage;
  AlertOnCrises(this.cameras, this.firebaseStorage);
  @override
  Widget build(BuildContext context) {
    
    return new MaterialApp(
	    title: 'Alert On Crises',
      theme: new ThemeData(
        // primaryColor: Colors.green.shade500,
        // textSelectionColor: Colors.green.shade500,
        // buttonColor: Colors.green.shade500,
	      // accentColor: Colors.green.shade500,
	      // bottomAppBarColor: Colors.white
      ),
      home: new SplashScreen(),
	    routes: {
        'login': (BuildContext context) => new LoginScreen(),
      	'distressAlert': (BuildContext context) => new DistressAlertScreen(cameras, firebaseStorage),
        'fingerprintSetup': (BuildContext context) => new FingerprintScreen(),
	    },
    );
  }
}