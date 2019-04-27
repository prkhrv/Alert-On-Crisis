import 'dart:async';

import 'package:alert_on_crises/app/utils/auth_utils.dart';
import 'package:alert_on_crises/app/utils/attach_device_to_user_utils.dart';
import 'package:alert_on_crises/app/utils/distress_alert_utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alert_on_crises/app/utils/network_utils.dart';
import 'package:alert_on_crises/app/components/error_box.dart';
import 'package:alert_on_crises/app/components/username_field.dart';
import 'package:alert_on_crises/app/components/password_field.dart';
import 'package:alert_on_crises/app/components/login_button.dart';
import 'package:device_info/device_info.dart';
import 'dart:io' show Platform;


class LoginScreen extends StatefulWidget {
	@override
	LoginScreenState createState() => new LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
	final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
	Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
	SharedPreferences _sharedPreferences;
	bool _isError = false;
	bool _obscureText = true;
	bool _isLoading = false;

	var _deviceId;
	var _deviceModel;

  bool _enableFingerprint = false;
	TextEditingController _usernameController, _passwordController;
	String _errorText, _usernameError, _passwordError;

	@override
	void initState() {
		super.initState();
		_fetchSessionAndNavigate();
		_usernameController = new TextEditingController();
		_passwordController = new TextEditingController();
	}

	_fetchSessionAndNavigate() async {
		_sharedPreferences = await _prefs;
		String authToken = AuthUtils.getToken(_sharedPreferences);
    
		if(authToken != null) {
      Navigator.of(_scaffoldKey.currentContext).pop();
			Navigator.of(_scaffoldKey.currentContext).pushReplacementNamed('distressAlert');
		}
	}

	_showLoading() {
		setState(() {
		  _isLoading = true;
		});
	}

	_hideLoading() {
		setState(() {
		  _isLoading = false;
		});
	}

  _attachDeviceToUser(authToken) async{
    
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      _deviceId = androidInfo.id.toString();
      _deviceModel = androidInfo.model;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      _deviceId = iosInfo.identifierForVendor.toString();
      _deviceModel = iosInfo.utsname.machine;
    }
    var responseJson = await NetworkUtils.attachDeviceToUser(_deviceModel, _deviceId, authToken);
    
    print(responseJson);

    if(responseJson == null) {
      NetworkUtils.showSnackBar(_scaffoldKey, 'Something went wrong!');
    } else if(responseJson == 'NetworkError') {
      NetworkUtils.showSnackBar(_scaffoldKey, null);
    } else if(!responseJson['success']) {
      NetworkUtils.showSnackBar(_scaffoldKey, 'User does not exist or invalid auth token provided.');
    } else {
      AttachDeviceToUserUtils.insertDetails(_sharedPreferences, _deviceId, _deviceModel);
    }
  }

  _getAppSettingsData(authToken) async {
    bool appSettingsReceived = false;
    while(!appSettingsReceived){

      var responseJson = await NetworkUtils.getAppConfigSettings(
				authToken
			);

      print(responseJson);
			if(responseJson['success']) {
        DistressAlertUtils.insertData(_sharedPreferences, 'emergency_number', responseJson['data']['emergency_number']);
        DistressAlertUtils.insertData(_sharedPreferences, 'security_desk_number', responseJson['data']['security_desk_number']);
        appSettingsReceived = true;
      }
      await Future.delayed(Duration(milliseconds: 200));
    }
  }
	_authenticateUser() async {
		_showLoading();
		if(_valid()) {
			var responseJson = await NetworkUtils.authenticateUser(
				_usernameController.text, _passwordController.text
			);
      
			print(responseJson);

			if(responseJson == null) {
				NetworkUtils.showSnackBar(_scaffoldKey, 'Something went wrong!');
			} else if(responseJson == 'NetworkError') {
				NetworkUtils.showSnackBar(_scaffoldKey, null);
			} else if(!responseJson['success']) {
				NetworkUtils.showSnackBar(_scaffoldKey, 'Invalid Username/Password');
			} else {
				AuthUtils.insertDetails(_sharedPreferences, responseJson);
				
        _attachDeviceToUser(responseJson['data']['token']);
        _getAppSettingsData(responseJson['data']['token']);

        Navigator.of(_scaffoldKey.currentContext).pop();
        if(_enableFingerprint){
          print('Fingerprint enabled');
          Navigator.of(_scaffoldKey.currentContext).pushReplacementNamed('fingerprintSetup');
        }else{
          Navigator.of(_scaffoldKey.currentContext).pushReplacementNamed('distressAlert');
        }
			}
			_hideLoading();
		} else {
			setState(() {
				_isLoading = false;
				_usernameError;
				_passwordError;
			});
		}
	}

	_valid() {
		bool valid = true;
    print(_usernameController.text.isNotEmpty);
		if(_usernameController.text.isEmpty) {
			valid = false;
			_usernameError = "Username can't be blank!";
		}

		if(_passwordController.text.isEmpty) {
			valid = false;
			_passwordError = "Password can't be blank!";
		}
		return valid;
	}

	Widget _loginScreen() {
		return new SafeArea(
      
			child: new ListView(
				padding: const EdgeInsets.symmetric(horizontal: 24.0),
				children: <Widget>[
          SizedBox(height: 80),
					new ErrorBox(
						isError: _isError,
						errorText: _errorText
					),
          SizedBox(height: 80.0),
					new UsernameField(
						usernameController: _usernameController,
						usernameError: _usernameError
					),
          SizedBox(height: 48.0),
					new PasswordField(
						passwordController: _passwordController,
						obscureText: _obscureText,
						passwordError: _passwordError,
						togglePassword: _togglePassword,
					),
					SizedBox(height: 24.0),
          new Row(
            children: <Widget>[
              new Switch(
                value: _enableFingerprint,
                inactiveThumbColor: Colors.green,
                inactiveTrackColor: Colors.grey,
                activeColor: Colors.green,
                onChanged: (bool e) {
                  _enableFingerprint = e;
                },
              ),
              new Expanded(child: new Text('Enable Fingerprint', 
                style: TextStyle(color: Colors.white, fontSize: 18.0)
                )
              ),
            ],
          ),
          SizedBox(height: 24.0),
          new LoginButton(onPressed: _authenticateUser)
				],
			),
		);
	}

	_togglePassword() {
		setState(() {
			_obscureText = !_obscureText;
		});
	}

	Widget _loadingScreen() {
		return new Container(
			margin: const EdgeInsets.only(top: 100.0),
			child: new Center(
				child: new Column(
					children: <Widget>[
						new CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
              // valueColor: .,
							strokeWidth: 4.0
						),
						new Container(
							padding: const EdgeInsets.all(8.0),
							child: new Text(
								'Please Wait',
								style: new TextStyle(
									color: Colors.white,
									fontSize: 16.0
								),
							),
						)
					],
				)
			)
		);
	}

	@override
  final bgColor = const Color(0xFF040333);
	Widget build(BuildContext context) {
		return new Scaffold(
      backgroundColor: bgColor,
			key: _scaffoldKey,
			body: _isLoading ? _loadingScreen() : _loginScreen()
		);
	}

}