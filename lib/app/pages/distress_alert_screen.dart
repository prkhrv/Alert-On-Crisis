import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:device_info/device_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alert_on_crises/app/utils/network_utils.dart';
import 'package:alert_on_crises/app/utils/auth_utils.dart';
import 'package:alert_on_crises/app/utils/distress_alert_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:location/location.dart';
import 'package:random_string/random_string.dart' as random;
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import 'dart:io' show Platform;

List<CameraDescription> cameras;

class DistressAlertScreen extends StatefulWidget {
  List<CameraDescription> cameras;
  final FirebaseStorage firebaseStorage;
  DistressAlertScreen(this.cameras, this.firebaseStorage);

  @override
  _DistressAlertScreenState createState() => new _DistressAlertScreenState();
}

class _DistressAlertScreenState extends State<DistressAlertScreen> {

  var cameras;
  var firebaseStorage;
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
  String _isVideoRecorded = 'false';
  String _is911Called = 'false';
  String _isServiceDeskCalled = 'false';
  String _injuredIconText = 'I am injured';
  bool _isDistressCallSent = false;
  String _distressCallRequestStatus = 'Press and hold\nTo send Distress call\nand record video';
  String _distressId, _videoPath, _emergencyNumber, _securityDeskNumber, _distressCallInjuredStatus, _distressCallSafeStatus;
  String _locationDetected = 'false';
  String _isLocationSentAfterDistressCall = 'false';
  String _appDirPath;
  bool _canShowMarkedSafeOverlay=false;
  String _isUserMarkedInjured = 'false';
  bool _canShowInjuredOverlay = false;
  String _recordVideoText = 'Record Video ...';
  bool _isFingerprint;
  String _chatMessageFromServer;
  String _retryVideoRecord;
  String _evacuationDirections;
  double _screenHeight, _longitude, _latitude;
  String _fingerprintAuthText = 'Scan your fingerprint to authenticate';
  List<StorageUploadTask> _tasks = <StorageUploadTask>[];
  String _videoUploadStatus;
  
  _getApiValueForUserInjuryStatus() {
    _isUserMarkedInjured == 'true' ? '1' : '';
  }

  _flushDistressData() async{
    _sharedPreferences.remove('is_location_detected');
    _sharedPreferences.remove('evacuation_directions');
    _sharedPreferences.remove('server_chat_message');
    _sharedPreferences.remove('location_sent_after_distress_alert');
    _sharedPreferences.remove('is_user_marked_injured');
    _sharedPreferences.remove('emergency_number');
    _sharedPreferences.remove('distress_alert_id');
    _sharedPreferences.remove('is_video_recorded');
    _sharedPreferences.remove('distress_alert_sent_at');
    _sharedPreferences.remove('is_911_called');
    _sharedPreferences.remove('is_service_desk_called');
    _sharedPreferences.remove('video_upload_status');

    setState(() {
      _distressId = null;
      _chatMessageFromServer = null;
      _evacuationDirections = null;
      _isVideoRecorded = 'false';
      _locationDetected = 'false';
      _isDistressCallSent = false;
      _distressCallRequestStatus = 'Press and hold\nTo send Distress call\nand record video';
      _videoPath = null;
      _distressCallInjuredStatus = null;
      _recordVideoText = 'Record Video ...';
      _counter = 15;
      _isLocationSentAfterDistressCall = 'false';
      _isUserMarkedInjured = 'false';
      _distressCallSafeStatus = '';
      _is911Called = 'false';
      _isServiceDeskCalled = 'false';
      _injuredIconText = 'I am injured';
      _videoUploadStatus = null;
    });
  }

  _getUserLocation() async{
    var currentLocation = LocationData;
    var location = new Location();
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      LocationData currentLocation = await location.getLocation();

      DistressAlertUtils.insertData(_sharedPreferences, 'is_location_detected', 'true');

      setState(() {
        _locationDetected = 'true';
        if (currentLocation.longitude != _longitude){
          _longitude = currentLocation.longitude;
        }

        if (currentLocation.latitude != _latitude){
          _latitude = currentLocation.latitude;
        }
      });

    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
      }
    }
    
  }

  Future<Null> biometrics() async {
    final LocalAuthentication auth = new LocalAuthentication();
    bool authenticated = false;

    try {
      authenticated = await auth.authenticateWithBiometrics(
        useErrorDialogs: false,
        localizedReason: 'Scan your fingerprint to authenticate',
        stickyAuth: false
      );
    } on PlatformException catch (e) {
      print(e);
      // if (e.code == auth_error.notAvailable) {
      //   setState(() {
      //     _fingerprintAuthText = 'Fingerprint not available on device';
      //   });
      //   // Handle this exception here.
      // } else if(e.code == auth_error.notEnrolled){
      //   setState(() {
      //     _fingerprintAuthText = 'Fingerprint not set on device';
      //   });
      // } else if(e.code == auth_error.passcodeNotSet){
      //   setState(() {
      //     _fingerprintAuthText = 'Pattern/Pin/Password not set on device';
      //   });
      // }
    }
    if (!mounted){

    }
    print(authenticated);
    if (authenticated) {
      setState(() {
        _isFingerprint = true;

        _fingerprintAuthText = 'Scan your fingerprint to authenticate';
        _canShowMarkedSafeOverlay = false;
        _markSafe('', '', '', 'marking user safe', '', '', 'true', '');
        _flushDistressData();
      });
    }
    else{
      setState(() {
        _fingerprintAuthText = 'Fingerprint authentication failed, please try again';
      });
      biometrics();                                  

    }
  }

  _localPath() async {
    // Application documents directory: /data/user/0/{package_name}/{app_name}
    final applicationDirectory = await getApplicationDocumentsDirectory();

    setState(() {_appDirPath = applicationDirectory.path;});
  }

  _launchcaller(number)  async {
    String url = "tel://${number}";

    if (await canLaunch(url))
    {
      await launch(url);
    }

    else{
      throw 'Could not launch $url';
    }

  }

  _fetchExitDirectionsAndOverlayMessage() async {
    while(_distressCallSafeStatus == null){
      var responseJson = await NetworkUtils.getDistressRecord(
        _authToken, _distressId.toString()
      );
      
      print(responseJson);
      if(responseJson != null && responseJson['success']) {
        
        String currentMessage2 = responseJson['data']['message2'];
        String currentMessage1 = responseJson['data']['message1'];


        if (currentMessage1 != ''){
          DistressAlertUtils.insertData(_sharedPreferences, 'server_chat_message', currentMessage1);
          setState(() {
            _chatMessageFromServer = currentMessage1;
          });
        }

        if (currentMessage2 != ''){
          DistressAlertUtils.insertData(_sharedPreferences, 'evacuation_directions', currentMessage2);
          setState(() {
            _evacuationDirections = currentMessage2;
          });
        }
      }
      await Future.delayed(Duration(milliseconds: 2000));
    }
  }

  _mark911Called() async {
    bool mark911Called = false;
    while(!mark911Called){
      var now = formatDate(DateTime.now().toUtc(), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]);
      var responseJson = await NetworkUtils.updateDistressAlert(
        _authToken, _distressId.toString(), '', '', '', 'User has attempted emergency call', now.toString(), '', '', _getApiValueForUserInjuryStatus()
      );
      print(responseJson);
      if(responseJson['success']) {
        mark911Called = true;
      }
      await Future.delayed(Duration(milliseconds: 200));
    }
  }

  _markServiceDeskCalled() async {
    bool markServiceDeskCalled = false;
    while(!markServiceDeskCalled){
      var now = formatDate(DateTime.now().toUtc(), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]);
      var responseJson = await NetworkUtils.updateDistressAlert(
        _authToken, _distressId.toString(), '', '', '', 'User has attempted service desk call', '', now.toString(), '', _getApiValueForUserInjuryStatus()
      );
      print(responseJson);
      if(responseJson['success']) {
        markServiceDeskCalled = true;
      }
      await Future.delayed(Duration(milliseconds: 200));
    }
  }

  _sendUserLocationUpdates() async {
    while(_distressId != null){
      var userLocation = _getUserLocation();
      if (_latitude != null){
        var responseJson = await NetworkUtils.updateDistressAlert(
        _authToken, _distressId.toString(), "${_latitude},${_longitude}", '', '', '', '', '', '', _getApiValueForUserInjuryStatus()
        );
        print(responseJson);
        if(responseJson['success']){

          DistressAlertUtils.insertData(_sharedPreferences, 'location_sent_after_distress_alert', 'true');
          setState(() {
            _isLocationSentAfterDistressCall = 'true';
          });
        }
      }
      await Future.delayed(Duration(milliseconds: 5000));
    }
  }

  

  _markSafe(userLocation, videoText, videoUrl, distressNotes, emergencyCallTimeStamp, securityDeskCallTimeStamp, isSafe, isInjured) async{
    setState((){_distressCallSafeStatus = 'Marking you safe ...';});
    bool distressAlertUpdated = false;
    while(!distressAlertUpdated){
      var responseJson = await NetworkUtils.updateDistressAlert(
        _authToken, _distressId.toString(), userLocation, videoText, videoUrl, distressNotes, emergencyCallTimeStamp, securityDeskCallTimeStamp, '1', ''
      );
      print(responseJson);
      if(responseJson == null) {
        setState(() {_distressCallSafeStatus = 'Something went wrong!';});
      } else if(responseJson == 'NetworkError') {
        setState(() {_distressCallSafeStatus = 'Waiting for internet to\n mark you safe ...';});
      } else if(!responseJson['success']) {
        setState(() {_distressCallSafeStatus = 'Something went wrong while\n marking you safe!';});
      } else {
        distressAlertUpdated = true;
        setState(() {
          if(_distressId != null){
            _distressCallSafeStatus = 'You have marked yourself safe ...';
          }
        });
      }
      await Future.delayed(Duration(milliseconds: 200));
    }
  }

  _markInjured(userLocation, videoText, videoUrl, distressNotes, emergencyCallTimeStamp, securityDeskCallTimeStamp, isSafe, isInjured) async{
    setState((){
      _distressCallInjuredStatus = 'Marking you injured ...';
      _canShowInjuredOverlay = true;
    });
    bool distressAlertUpdated = false;
    while(!distressAlertUpdated){
      var responseJson = await NetworkUtils.updateDistressAlert(
        _authToken, _distressId.toString(), userLocation, videoText, videoUrl, distressNotes, emergencyCallTimeStamp, securityDeskCallTimeStamp, isSafe, '1'
      );
      print(responseJson);
      if(responseJson == null) {
        setState(() {_distressCallInjuredStatus = 'Uploading Please Wait';});
      } else if(responseJson == 'NetworkError') {
        setState(() {_distressCallInjuredStatus = 'Waiting for internet to\n mark you injured ...';});
      } else if(!responseJson['success']) {
        setState(() {_distressCallInjuredStatus = 'Something went wrong while\n marking you injured!';});
      } else {
        distressAlertUpdated = true;
        setState(() {
          _isUserMarkedInjured = 'true';
          DistressAlertUtils.insertData(_sharedPreferences, 'is_user_marked_injured', _isUserMarkedInjured);
          _distressCallInjuredStatus = 'You have marked yourself injured ...';
        });
      }
      await Future.delayed(Duration(milliseconds: 200));
    }
  }

  Future<String> _startVideoRecording() async {
    // Do nothing if a recording is on progress

    setState((){
      _recordVideoText = 'Recording ...';
    });

    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final String videoDirectory = '${_appDirPath}/Videos';
    await Directory(videoDirectory).create(recursive: true);
    final String filePath = '$videoDirectory/distress_alert_${random.randomAlphaNumeric(10)}.mp4';

    try {
      await controller.startVideoRecording(filePath);
      _videoPath = filePath;
    } on CameraException catch (e) {
      _showCameraException(e);
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
      _showCameraException(e);
      return null;
    }
  }

  void _showCameraException(CameraException e) {
    String errorText = 'Error: ${e.code}\nError Message: ${e.description}';
    print(errorText);
  }

  void _decreaseCounterWhilePressed() async {
    // make sure that only one loop is active
    if (_loopActive) return;
    _loopActive = true;
    while (_buttonPressed) {
      // do your thing
      if(_counter == 0){
        setState(() {
          _stopVideoRecording().then((_) {});
          _sendVideoURL();
          _isVideoRecorded = 'true';
          _retryVideoRecord = null;
          DistressAlertUtils.insertData(_sharedPreferences, 'is_video_recorded', _isVideoRecorded);
        });
      }

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
      this.firebaseStorage = widget.firebaseStorage;
      this.cameraGot = true;
    });
  }

  Future<void> _uploadFile() async {
    final String uuid = Uuid().v1();
    final Directory systemTempDir = Directory.systemTemp;
    final File file = await File(_videoPath);
    final StorageReference ref =
      widget.firebaseStorage.ref().child('distressAlert_${_distressId}.mp4');
    final StorageUploadTask uploadTask = ref.putFile(
      file,
      StorageMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'activity': 'Distress Call'},
      ),
    );
    final String url = await ref.getDownloadURL();
    print(url);

    setState(() {
      _tasks.add(uploadTask);
    });
  }

  _sendVideoURL() async{
    setState((){_videoUploadStatus = 'Video uploading started...';});
    DistressAlertUtils.insertData(_sharedPreferences, 'video_upload_status', _videoUploadStatus);
    bool isVideoUploaded = false;
    
    while(!isVideoUploaded){
      var responseJson = await NetworkUtils.uploadVideo(
        _authToken, _distressId.toString(), _videoPath
      );
      print(responseJson);
      if(responseJson == null) {
        setState(() {_videoUploadStatus = 'Uploading Please wait';});
        DistressAlertUtils.insertData(_sharedPreferences, 'video_upload_status', _videoUploadStatus);
      } else if(responseJson == 'NetworkError') {
        setState(() {_videoUploadStatus = 'Waiting for internet to\n upload the video ...';});
        DistressAlertUtils.insertData(_sharedPreferences, 'video_upload_status', _videoUploadStatus);
      } else if(!responseJson['success']) {
        setState(() {_videoUploadStatus = 'Something went wrong while\n uploading the video!';});
        DistressAlertUtils.insertData(_sharedPreferences, 'video_upload_status', _videoUploadStatus);
      } else {
        setState(() {
          setState((){_videoUploadStatus = 'Video uploaded successfully...';});
          DistressAlertUtils.insertData(_sharedPreferences, 'video_upload_status', _videoUploadStatus);
          isVideoUploaded = true;
        });
      }
      await Future.delayed(Duration(milliseconds: 200));
    }
  }

  _fetchSessionData() async{
    // _getUserLocation();
    _sharedPreferences = await _prefs;
		_authToken = AuthUtils.getToken(_sharedPreferences);
    _emergencyNumber = '911';
    _securityDeskNumber = DistressAlertUtils.getData(_sharedPreferences, 'security_desk_number');
    var distressId = DistressAlertUtils.getData(_sharedPreferences, 'distress_alert_id');    
    // _getLocation();
    if (distressId != null){
      setState(() {
        var now = DistressAlertUtils.getData(_sharedPreferences, 'distress_alert_sent_at');
        var locationDetected = DistressAlertUtils.getData(_sharedPreferences, 'is_location_detected');
        var locationSentAfterDistressAlert = DistressAlertUtils.getData(_sharedPreferences, 'location_sent_after_distress_alert');
        
        _locationDetected = locationDetected == 'true' ? 'true' : 'false';
        _isLocationSentAfterDistressCall = locationSentAfterDistressAlert == 'true' ? 'true' : 'false';
        
        _distressCallRequestStatus = 'Distress Call sent at ${now.toString()} ...\nSecuirty Protocols activated ..\nSecurity administrator Notified ...\nAlert Broadcasted ...';
        
        _distressId = distressId.toString();
        _isDistressCallSent = true;
        _evacuationDirections = DistressAlertUtils.getData(_sharedPreferences, 'evacuation_directions');
        _chatMessageFromServer = DistressAlertUtils.getData(_sharedPreferences, 'server_chat_message');
        
        var distressInjureStatus = DistressAlertUtils.getData(_sharedPreferences, 'is_user_marked_injured');
        
        if(distressInjureStatus != null){
          _isUserMarkedInjured = 'true';
          _distressCallInjuredStatus = 'You have marked yourself injured ...';
          _injuredIconText = 'You are injured';
        }
        _fetchExitDirectionsAndOverlayMessage();
        _sendUserLocationUpdates();

        _videoUploadStatus = DistressAlertUtils.getData(_sharedPreferences, 'video_upload_status');
        _isVideoRecorded = DistressAlertUtils.getData(_sharedPreferences, 'is_video_recorded');
        _is911Called = DistressAlertUtils.getData(_sharedPreferences, 'is_911_called');
        _isServiceDeskCalled = DistressAlertUtils.getData(_sharedPreferences, 'is_service_desk_called');
      });
    }

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      _deviceId = androidInfo.id.toString();
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      _deviceId = iosInfo.identifierForVendor.toString();
    }
  }

  _sendDistressAlert() async{
    setState(() {
      var now = formatDate(DateTime.now(), [hh, ':', nn, ' ', am]);
      _distressCallRequestStatus = 'Sending Distress Call at ${now.toString()}...';
    });
    while(!_isDistressCallSent){
      var responseJson = await NetworkUtils.sendDistressAlert(
        _authToken, _deviceId
      );
      print(responseJson);
      if(responseJson == null) {
        setState((){_distressCallRequestStatus = 'Something went wrong!';});
      } else if(responseJson == 'NetworkError') {
        setState((){_distressCallRequestStatus = 'Waiting for internet to\n send Distress Call ...';});
      } else if(!responseJson['success']) {
        setState((){_distressCallRequestStatus = 'Something went wrong while\n sending Distress Call!';});
      } else {
        setState((){
          var now = formatDate(DateTime.now(), [hh, ':', nn, ' ', am]);
          _isDistressCallSent = true;

          _distressId =responseJson['data'].toString();

          _distressCallRequestStatus = 'Distress Call sent at ${now.toString()} ...\nSecuirty Protocols activated ..\nSecurity administrator Notified ...\nAlert Broadcasted ...';

          DistressAlertUtils.insertData(_sharedPreferences, 'distress_alert_sent_at', now.toString());
          DistressAlertUtils.insertData(_sharedPreferences, 'distress_alert_id', responseJson['data'].toString());
          _fetchExitDirectionsAndOverlayMessage();
          _sendUserLocationUpdates();

        });
      }
      await Future.delayed(Duration(milliseconds: 200));
    }
  }

  _locationSentText(){
    String locationSentText = _isLocationSentAfterDistressCall == 'true' ? 'Location sent' : 'Location not sent';
    String locationDetectedText =_locationDetected == 'true' ? 'Real Time Location ON' : 'Real Time Location OFF';

    return '${locationSentText}\n${locationDetectedText}';
  }

  @override
  void initState() {
    super.initState();

    getCamera();
    _fetchSessionData();
    _localPath();
    print(cameras);

    if(this.cameraGot) {
      controller = new CameraController(this.cameras[0], ResolutionPreset.medium);
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
    _screenHeight = MediaQuery.of(context).size.height;
    return new AspectRatio(
      key: _scaffoldKey,

      aspectRatio: controller.value.aspectRatio,
      child: Container(
        height: double.infinity,
        width: double.infinity,
        child: Stack(
          children: <Widget>[
            CameraPreview(controller),
            GestureDetector(
              onLongPress: (){
                _buttonPressed = true;
                _decreaseCounterWhilePressed();
                if(!_isDistressCallSent){
                  _sendDistressAlert();
                }
                if(_isVideoRecorded == 'false'){
                  _startVideoRecording().then((String filePath) {});
                }

              },
              onLongPressUp: (){
                _buttonPressed = false;
                if(_isVideoRecorded == 'false'){
                  _stopVideoRecording().then((_) {});
                  _sendVideoURL();
                }
                print(_videoPath);
                if(_counter >= 14){
                  _recordVideoText = 'Record Video ...';
                  _retryVideoRecord = 'Video length too short, Please try again!';
                  _counter = 15;
                }else{
                  setState(() {
                    DistressAlertUtils.insertData(_sharedPreferences, 'is_video_recorded', 'true');
                    _isVideoRecorded = 'true';
                    _retryVideoRecord = null;
                  });
                }

                // print(_videoPath);
              },

              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Container(
                      color: Color.fromRGBO(00, 00, 00, 0.5),
                      child: Column(
                        children: _isDistressCallSent ? <Widget>[

                          SizedBox(height: 50.0),
                          Material(
                            color: Colors.transparent,
                            child: Ink.image(
                              image:AssetImage('lib/app/assets/mark-injured.png'),
                              fit:BoxFit.cover,
                              width: 55.0,
                              height: _screenHeight*0.07,
                              child: InkWell(
                                onTap: () {
                                  if (_isUserMarkedInjured != 'true'){
                                    _markInjured('', '', '', 'marking user injured', '', '', '', 'true');
                                    _injuredIconText = 'You are injured';
                                    setState((){
                                      _canShowInjuredOverlay = true;
                                    });
                                    
                                    
                                  }
                                },
                                child: null
                              )
                            )
                          ),
                          Material(
                            type: MaterialType.transparency,
                            child: Text(
                              _injuredIconText,
                              style:TextStyle(
                                color: Colors.white,
                                fontSize: 13.0,
                              )
                            )
                          ),

                          SizedBox(height: _screenHeight*0.44),
                          Material(
                            color: Colors.transparent,
                            child: Ink.image(
                              image:AssetImage('lib/app/assets/service-desk.png'),
                              fit:BoxFit.cover,
                              width: 55.0,
                              height: _screenHeight*0.08,
                              child: InkWell(
                                onTap: (){
                                  _launchcaller(_securityDeskNumber);
                                  DistressAlertUtils.insertData(_sharedPreferences, 'is_service_desk_called', 'true');
                                  _markServiceDeskCalled();
                                  _isServiceDeskCalled = 'true';
                                },
                                child: null
                              )
                            )
                          ),
                          Material(
                            type: MaterialType.transparency,
                            child: Text(
                              'Call Service Desk',
                              style:TextStyle(
                                color: Colors.white,
                                fontSize: 13.0,
                              )
                            )
                          ),
                          SizedBox(height: _screenHeight*0.02),
                          Material(
                            color: Colors.transparent,
                            child: Ink.image(
                              image:AssetImage('lib/app/assets/911.png'),
                              fit:BoxFit.cover,
                              width: 55.0,
                              height: _screenHeight*0.07,
                              child: InkWell(
                                onTap: (){
                                  _launchcaller(_emergencyNumber);
                                  DistressAlertUtils.insertData(_sharedPreferences, 'is_911_called', 'true');
                                  _mark911Called();
                                  _is911Called = 'true';
                                },
                                child: null
                              )
                            )
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
                          
                          SizedBox(height: _screenHeight*0.06),
                          Material(
                            color: Colors.transparent,
                            child: Ink.image(
                              image:AssetImage('lib/app/assets/safe-icon.png'),
                              fit:BoxFit.cover,
                              width: 55.0,
                              height: _screenHeight*0.07,
                              child: InkWell(
                                onTap: (){
                                  setState(() {
                                    _canShowMarkedSafeOverlay = true;
                                    biometrics();
                                  });
                                },
                                child: null
                              )
                            )
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
                        ] : [],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: Container(
                      color: Color.fromRGBO(00, 00, 00, 0.7),
                      child:Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 9),
                          child: Column(
                            children: <Widget>[
                              SizedBox(height: 30.0),
                              Row(
                                children: <Widget>[
                                  Image.asset(
                                    'lib/app/assets/location-icon.png',
                                    height: 30.0,
                                    width: 30.0,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Material(
                                      type:MaterialType.transparency,
                                      child: Text(
                                        _locationSentText(),
                                        style:TextStyle(
                                          color: Colors.white,
                                          fontSize: 15.0,
                                        )
                                      )
                                    )
                                  )
                                ]
                              ),

                              SizedBox(height: _screenHeight*0.08),
                              Material(
                                type: MaterialType.transparency,
                                child:Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    _distressCallRequestStatus,
                                    textAlign: TextAlign.left,
                                    style:TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.0
                                    )
                                  )
                                )
                              ),
                              _isVideoRecorded == 'true' ? Material(
                                type: MaterialType.transparency,
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    'Video recorded successfully ...',
                                    textAlign: TextAlign.left,
                                    style:TextStyle(
                                      color: Colors.yellowAccent,
                                      fontSize: 15.0
                                    )
                                  )
                                )
                              ) : new Container(width: 0, height: 0),
                              _videoUploadStatus != null ? Material(
                                type: MaterialType.transparency,
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    _videoUploadStatus,
                                    textAlign: TextAlign.left,
                                    style:TextStyle(
                                      color: Colors.yellowAccent,
                                      fontSize: 15.0
                                    )
                                  )
                                )
                              ) : new Container(width: 0, height: 0),
                              _is911Called == 'true' ? Material(
                                type: MaterialType.transparency,
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    'You have called 911 ...',
                                    textAlign: TextAlign.left,
                                    style:TextStyle(
                                      color: Colors.yellowAccent,
                                      fontSize: 15.0
                                    )
                                  )
                                )
                              ) : new Container(width: 0, height: 0),
                              _isServiceDeskCalled == 'true' ? Material(
                                type: MaterialType.transparency,
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    'You have called Service Desk ...',
                                    textAlign: TextAlign.left,
                                    style:TextStyle(
                                      color: Colors.yellowAccent,
                                      fontSize: 15.0
                                    )
                                  )
                                )
                              ) : new Container(width: 0, height: 0),
                              _distressCallInjuredStatus != null ? Material(
                                type: MaterialType.transparency,
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    _distressCallInjuredStatus,
                                    textAlign: TextAlign.left,
                                    style:TextStyle(
                                      color: Colors.yellowAccent,
                                      fontSize: 15.0
                                    )
                                  )
                                )
                              ) : new Container(width: 0, height: 0),
                              _distressCallSafeStatus != null ? Material(
                                type: MaterialType.transparency,
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    _distressCallSafeStatus,
                                    textAlign: TextAlign.left,
                                    style:TextStyle(
                                      color: Colors.yellowAccent,
                                      fontSize: 15.0
                                    )
                                  )
                                )
                              ) : new Container(width: 0, height: 0),
                              SizedBox(height: 20),
                              Material(
                                type: MaterialType.transparency,
                                child: Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Container(
                                    
                                    height: 100,
                                    padding: EdgeInsets.symmetric(vertical: 10.0),
                                    child: _chatMessageFromServer != null ? Text(
                                      _chatMessageFromServer,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 25.0
                                      ) 
                                    ) : new Container(height: 0, width: 0)
                                  )
                                )
                              ),
                              SizedBox(height: 10),
                              
                              Material(
                                type: MaterialType.transparency,
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                    height: 50,
                                    padding: EdgeInsets.symmetric(vertical: 10.0),
                                    child: _evacuationDirections != null ? Text(
                                      _evacuationDirections,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.0
                                      ) 
                                    ) : new Container(height: 0, width: 0)
                                  )
                                )
                              ),

                              SizedBox(height: 40.0),
                              _isVideoRecorded == 'false' ? Material(
                                type: MaterialType.transparency,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    _recordVideoText,
                                    textAlign: TextAlign.left,
                                    style:TextStyle(
                                      color: Colors.white,
                                      fontSize: 25.0
                                    )
                                  )
                                )
                              ) : new Container(height: 0, width: 0),
                              SizedBox(height: 10),
                              _isVideoRecorded == 'false' ? Material(
                                type: MaterialType.transparency,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$_counter',
                                    textAlign: TextAlign.left,
                                    style:TextStyle(
                                      color: Colors.white,
                                      fontSize: 40.0
                                    )
                                  )
                                )
                              ) : new Container(height: 0, width: 0),
                              SizedBox(height: 10),
                              _retryVideoRecord != null ? Material(
                                type: MaterialType.transparency,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    _retryVideoRecord,
                                    textAlign: TextAlign.left,
                                    style:TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.0
                                    )
                                  )
                                )
                              ) : new Container(height: 0, width: 0),
                            ],
                          )
                        )
                      )
                    ),
                  ),
                ],
              )
            ),
            _canShowInjuredOverlay ? Container(
              height: double.infinity,
              width: double.infinity,
              color: Color.fromRGBO(00, 00, 00, 0.5),
              child: new Column(children: <Widget>[
                SizedBox(height: _screenHeight*0.35),
                new Material(
                  type:MaterialType.transparency,
                  child: Text(
                    "You have\n Marked yourself",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40.0
                    ),
                  )
                ),
                SizedBox(height: _screenHeight*0.1),
                new Material(
                  type:MaterialType.transparency,
                  child: Text(
                    "Injured",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 40.0
                    ),
                  )
                ),
                SizedBox(height: _screenHeight*0.25),
                new Align(
                  alignment: FractionalOffset.bottomRight,
                  
                  child: new RaisedButton(
                    shape: CircleBorder(),
                    color: Color(0xFF00FF64),
                    padding:EdgeInsets.all(10.0),
                    child: Icon(Icons.exit_to_app),
                    onPressed: (){
                      setState(() {
                        _canShowInjuredOverlay = false;
                      });
                    }
                  )
                )
              ])
            ) : new Container(height: 0.0, width: 0.0),
            _canShowMarkedSafeOverlay ? Container(
              height: double.infinity,
              width: double.infinity,
              color: Color.fromRGBO(00, 00, 00, 0.5),
              child: SafeArea(
                child: new Column(
                  children: <Widget>[
                    SizedBox(height: 120.0),
                    Center(
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 60.0,
                        child: Material(
                          color: Colors.transparent,
                          child: Ink.image(
                            image:AssetImage('lib/app/assets/fingerprint.png'),
                            fit: BoxFit.cover,

                            width: 120.0,
                            height: 120.0,
                            child: InkWell(
                            
                              child: null
                            )
                          )
                        )
                      )
                    ),
                    SizedBox(height: 260.0),
                    Center(
                      child: new Material(
                        type:MaterialType.transparency,
                        child: Text(
                          "Confirm\n You are safe",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40.0
                          ),
                        )
                      )
                    ),
                    // SizedBox(height: 10.0),
                    // Center(
                    //   child: new Material(
                    //     type:MaterialType.transparency,
                    //     child: Text(
                    //       _fingerprintAuthText,
                    //       textAlign: TextAlign.center,
                    //       style: TextStyle(
                    //         color: Colors.white,
                    //         fontSize: 12.0
                    //       ),
                    //     )
                    //   )
                    // ),
                  ]
                )
              )
            ) : new Container(height: 0, width: 0)
          ],
        ),
      ),
    );
  }
}
