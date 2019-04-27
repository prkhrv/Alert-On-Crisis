import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:device_info/device_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alert_on_crises/app/utils/network_utils.dart';
import 'package:alert_on_crises/app/utils/auth_utils.dart';
import 'package:alert_on_crises/app/utils/distress_alert_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

List<CameraDescription> cameras;

class DistressAlertScreenBack extends StatefulWidget {
  List<CameraDescription> cameras;
  DistressAlertScreenBack(this.cameras);
  @override
  _DistressAlertScreenBackState createState() => new _DistressAlertScreenBackState();
}

class _DistressAlertScreenBackState extends State<DistressAlertScreenBack> {
  var cameras;
  String _deviceId;
  String _authToken;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
	Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
	SharedPreferences _sharedPreferences;
  CameraController controller;
  bool cameraGot = false;
  int _counter = 15;
  bool _buttonPressed = false;
  bool _loopActive = false;
  bool _postDistressCallScreenLoaded=false;
  bool _isVideoRecorded = false;
  bool _isDistressCallSent = false;
  String _distressCallRequestStatus = 'Sending Distress Call';
  int _distressId; 
  Future<String> _videoPath;

  Widget _screenContent = Container(
    height: double.infinity,
    width: double.infinity,
    color: Color.fromRGBO(00, 00, 00, 0.5),
    child: Column(
      children: <Widget>[
        new Container(
          height: 40,
          child: new Align(
            alignment: FractionalOffset.topRight,
            child: Image.asset('lib/app/assets/usericon.png', height: 40.0, width: 40.0,)
          )
        ),
        new Container(
          height: 484.8,
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            height: 250.0,
            padding: EdgeInsets.all(20.0),
            color: Color.fromRGBO(00, 00, 00, 0.7),
            child: Row(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.all(Radius.circular(50.0)),
                      child: Container(
                        padding: EdgeInsets.all(4.0),
                        child: Image.asset('lib/app/assets/distress_screen_icon.png', height: 140.0),
                      ),
                    ) 
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 30.0),
                          child: Text('Press and hold\n\n\n to send Distress call\n\n\n and recrord video',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17.0
                            )
                          )
                        )
                      ],
                    )
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    )
  );

   Future<String> _startVideoRecording() async {
    if (!controller.value.isInitialized) {
      return null;
    }
 
    // Do nothing if a recording is on progress
    if (controller.value.isRecordingVideo) {
      return null;
    }
 
    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final String videoDirectory = '${appDirectory.path}/Videos';
    await Directory(videoDirectory).create(recursive: true);
    final String currentTime = DateTime.now().toString();
    final String filePath = '$videoDirectory/alert-${_distressId}.mp4';
 
    try {
      await controller.startVideoRecording(filePath);
    } on CameraException catch (e) {
      return null;
    }
 
    return filePath;
  }

  Future<void> _stopVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }
 
    try {
      await controller.stopVideoRecording();
    } on CameraException catch (e) {
      return null;
    }
  }
  

  void _decreaseCounterWhilePressed() async {
    // make sure that only one loop is active
    if (_loopActive) return;
    _loopActive = true;
    while (_buttonPressed) {
      // do your thing
      setState(() {
        _counter--;
      });
      await Future.delayed(Duration(seconds: 1));
    }
    _loopActive = false;
  }

  Future<Null> getCamera() async {
    setState(() {
      this.cameras = widget.cameras;
      this.cameraGot = true;
    });
  }

  _fetchSessionData() async{
    _sharedPreferences = await _prefs;
		_authToken = AuthUtils.getToken(_sharedPreferences);

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    _deviceId = androidInfo.id.toString();
  }

  _sendDistressAlert() async{
    
    var responseJson = await NetworkUtils.sendDistressAlert(
      _authToken, _deviceId
    );
    print(responseJson);
    if(responseJson == null) {
      setState((){_distressCallRequestStatus = 'Something went wrong!';});
    } else if(responseJson == 'NetworkError') {
      setState((){_distressCallRequestStatus = 'Waiting for internet to send Distress Call';});
    } else if(!responseJson['success']) {
      setState((){_distressCallRequestStatus = 'Something went wrong!';});
    } else {
      setState((){
        _screenContent = Row(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Container(
                color: Color.fromRGBO(00, 00, 00, 0.5),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 50.0),
                    Image.asset(
                      'lib/app/assets/mark-injured.png',
                      height: 55.0,
                      width: 55.0,
                    ),
                    Material(
                      type: MaterialType.transparency, 
                      child: Text(
                        'I am injured', 
                        style:TextStyle(
                          color: Colors.white,
                          fontSize: 13.0,
                        )
                      )
                    ),
                    SizedBox(height: 400.0),
                    Image.asset(
                      'lib/app/assets/911.png',
                      height: 55.0,
                      width: 55.0,
                    ),
                    Material(
                      type: MaterialType.transparency, 
                      child: Text(
                        'Call 911', 
                        style:TextStyle(
                          color: Colors.white,
                          fontSize: 13.0,
                        )
                      )
                    ),
                    SizedBox(height: 50.0),
                    Image.asset(
                      'lib/app/assets/safe-icon.png',
                      height: 55.0,
                      width: 55.0,
                    ),
                    Material(
                      type: MaterialType.transparency, 
                      child: Text(
                        'I am Safe', 
                        style:TextStyle(
                          color: Colors.white,
                          fontSize: 13.0,
                        )
                      )
                    ),
                  ]
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: Container(
                color: Color.fromRGBO(00, 00, 00, 0.7),
                child:Column(
                  children: <Widget>[
                    SizedBox(height: 70.0),
                    Material(
                      type: MaterialType.transparency, 
                      child: Text(
                        'Distress Call Sent at ${TimeOfDay.now().toString()} ...\nSecuirty Protocols activated ..\nSecurity administrator Notified ...\nAlert Broadcasted ...', 
                        style:TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                        )
                      )
                    )
                  ],
                )
              ),
            ),
          ],
        );
        _isDistressCallSent = true;
        _distressId = responseJson['data'];
      });
    }  

  }

  @override
  void initState() {
    super.initState();
    getCamera();
    _fetchSessionData();
    print(cameras);

    if(this.cameraGot) {
      controller = new CameraController(this.cameras[0], ResolutionPreset.high);
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new AspectRatio(
      key: _scaffoldKey,

      aspectRatio: controller.value.aspectRatio,
      child: Container(
        child: Stack(
          children: <Widget>[
            CameraPreview(controller),
            GestureDetector(
              onLongPress: (){
                _buttonPressed = true;
                _decreaseCounterWhilePressed();
                if(!_postDistressCallScreenLoaded){
                  setState(() {
                    _screenContent = Row(
                      children: <Widget>[
                        Expanded(
                          flex: 3,
                          child: Container(
                            color: Color.fromRGBO(00, 00, 00, 0.5),
                            child: Column(
                              children: <Widget>[
                                SizedBox(height: 50.0),
                                Image.asset(
                                  'lib/app/assets/mark-injured.png',
                                  height: 55.0,
                                  width: 55.0,
                                ),
                                Material(
                                  type: MaterialType.transparency, 
                                  child: Text(
                                    'I am injured', 
                                    style:TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.0,
                                    )
                                  )
                                ),
                                SizedBox(height: 400.0),
                                Image.asset(
                                  'lib/app/assets/911.png',
                                  height: 55.0,
                                  width: 55.0,
                                ),
                                Material(
                                  type: MaterialType.transparency, 
                                  child: Text(
                                    'Call 911', 
                                    style:TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.0,
                                    )
                                  )
                                ),
                                SizedBox(height: 50.0),
                                Image.asset(
                                  'lib/app/assets/safe-icon.png',
                                  height: 55.0,
                                  width: 55.0,
                                ),
                                Material(
                                  type: MaterialType.transparency, 
                                  child: Text(
                                    'I am Safe', 
                                    style:TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.0,
                                    )
                                  )
                                ),
                              ]
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: Container(
                            color: Color.fromRGBO(00, 00, 00, 0.7),
                            child:Column(
                              children: <Widget>[
                                SizedBox(height: 70.0),
                                Material(
                                  type: MaterialType.transparency, 
                                  child: Text(
                                    _distressCallRequestStatus, 
                                    style:TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.0,
                                    )
                                  )
                                )
                              ],
                            )
                          ),
                        ),
                      ],
                    );
                    _postDistressCallScreenLoaded = true;
                  });
                  _sendDistressAlert();
                  _videoPath = _startVideoRecording();
                }
              },
              onLongPressUp: (){
                _buttonPressed = false;
                _stopVideoRecording();
                print(_videoPath);
              },
              
              child: _screenContent
              
            )  
          ],
        ),
      ),
    );
  }
}