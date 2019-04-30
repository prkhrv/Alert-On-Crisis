import 'package:alert_on_crises/app/pages/distress_alert_screen.dart';
import 'package:alert_on_crises/app/utils/auth_utils.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class FingerprintScreen extends StatefulWidget {
	@override
	FingerprintScreenState createState() => new FingerprintScreenState();
}

class FingerprintScreenState extends State<FingerprintScreen> {
  bool isFingerprint;

  Future<Null> biometrics() async {
    final LocalAuthentication auth = new LocalAuthentication();
    bool authenticated = false;

    try {
      authenticated = await auth.authenticateWithBiometrics(
          localizedReason: 'Scan your fingerprint to authenticate',
          useErrorDialogs: false,
          stickyAuth: false);
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted){
      
    }
    if (authenticated) {
      setState(() {
        Navigator.of(context).pushNamed('distressAlert');
      });
    }
    else{
      biometrics();
    }
  }

  @override
	void initState() {
		super.initState();
    biometrics();
	}

  Widget _fingerprintScreen() {
		return new SafeArea(
			child: new Column(
        children: <Widget>[
          new Container(
            child: new Align(
              alignment: FractionalOffset.centerRight,
              child: Image.asset('lib/app/assets/usericon.png', height: 40.0, width: 40.0,)
            )
          ),
          SizedBox(height: 80.0),
          Center(
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 60.0,
              child: Image.asset('lib/app/assets/logo.png', height: 120.0, width: 120.0,),
            ),
          ),
          SizedBox(height: 260.0),
          Center(
            child: new Material(
              shape: CircleBorder(),
              color: Colors.transparent,
              child: Ink.image(
                image:AssetImage('lib/app/assets/fingerprint.png'),
                fit:BoxFit.cover,
                width: 120.0,
                height: 120.0,
                child: InkWell(
                  onTap: (){
                    
                  },
                  child: null
                )
              )
            )
          )  
        ]
      )
    );
  }

  @override
  final bgColor = const Color(0xFF040333);
	Widget build(BuildContext context) {
		return new Scaffold(
      backgroundColor: bgColor,
			body: _fingerprintScreen()
		);
	}

}