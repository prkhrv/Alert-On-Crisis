import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'auth_utils.dart';
import 'distress_alert_utils.dart';
import 'attach_device_to_user_utils.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class NetworkUtils {
	static final String host = productionHost;
	static final String productionHost = 'http://community.sellacious.com';

	static dynamic authenticateUser(String username, String password) async {
		var uri = host + AuthUtils.endPoint;

		try {
			final response = await http.post(
				uri,
				body: {
					'username': username,
					'password': password
				}
			);

			final responseJson = json.decode(response.body);
			return responseJson;

		} catch (exception) {
			print(exception);
			if(exception.toString().contains('SocketException')) {
				return 'NetworkError';
			} else {
				return null;
			}
		}
	}

  static dynamic getDistressRecord(String authToken, String distressId) async{
    var uri = host + '/index.php?option=com_sellaciouscommunity&task=distress.getItem&format=json';
    try {
			final response = await http.post(
				uri,
				body: {
          'token':authToken,
					'distress_id': distressId,
          'fields': 'id,message1,message2'
				}
			);

			final responseJson = json.decode(response.body);
			return responseJson;

		} catch (exception) {
			print(exception);
			if(exception.toString().contains('SocketException')) {
				return 'NetworkError';
			} else {
				return null;
			}
		}
  }

  static dynamic updateDistressAlert(String authToken, String distressId, String userLocation, String videoText, String videoUrl, String distressNotes, String emergencyCallTimeStamp, String securityDeskCallTimeStamp, String isSafe, String isInjured) async{
    var uri = host + '/index.php?option=com_sellaciouscommunity&task=distress.update&format=json';

    try {
			final response = await http.post(
				uri,
				body: {
          'token':authToken,
					'distress_id': distressId,
					'location': userLocation,
          'video_text': videoText,
          'video_url': videoUrl,
          'distress_notes':distressNotes,
          'emergency_call': emergencyCallTimeStamp,
          'security_desk_call': securityDeskCallTimeStamp,
          'is_safe': isSafe,
          'is_injured' : isInjured
				}
			);

			final responseJson = json.decode(response.body);
			return responseJson;

		} catch (exception) {
			print(exception);
			if(exception.toString().contains('SocketException')) {
				return 'NetworkError';
			} else {
				return null;
			}
		}
  }

  static dynamic getAppConfigSettings(String authToken) async{
    var uri = host + '/index.php?option=com_sellaciouscommunity&task=config.getAll&format=json';

    try {
			final response = await http.post(
				uri,
				body: {
          'token':authToken,
				}
			);

			final responseJson = json.decode(response.body);
			return responseJson;

		} catch (exception) {
			print(exception);
			if(exception.toString().contains('SocketException')) {
				return 'NetworkError';
			} else {
				return null;
			}
		}
  }

  static dynamic attachDeviceToUser(String deviceType, String deviceId, String authToken) async{
    var uri = host + AttachDeviceToUserUtils.endPoint;

    try {
			final response = await http.post(
				uri,
				body: {
					'device_id': deviceId,
					'device_type': deviceType,
          'token': authToken
				}
			);

			final responseJson = json.decode(response.body);
			return responseJson;

		} catch (exception) {
			print(exception);
			if(exception.toString().contains('SocketException')) {
				return 'NetworkError';
			} else {
				return null;
			}
		}
  }

	static logoutUser(BuildContext context, SharedPreferences prefs) {
		prefs.setString(AuthUtils.authTokenKey, null);
		prefs.setInt(AuthUtils.userIdKey, null);
		prefs.setString(AuthUtils.nameKey, null);
		Navigator.of(context).pushReplacementNamed('/');
	}

	static showSnackBar(GlobalKey<ScaffoldState> scaffoldKey, String message) {
		scaffoldKey.currentState.showSnackBar(
			new SnackBar(
				content: new Text(message ?? 'You are offline'),
			)
		);
	}


  static sendDistressAlert(String authToken, String deviceId) async{
   var uri = host + DistressAlertUtils.endPoint;

    try {
			final response = await http.post(
				uri,
				body: {
					'device_id': deviceId,
					'token': authToken,
          'type': 'New distress call alert'
				}
			);

			final responseJson = json.decode(response.body);
			return responseJson;

		} catch (exception) {
			print(exception);
			if(exception.toString().contains('SocketException')) {
				return 'NetworkError';
			} else {
				return null;
			}
		} 
  }

  static uploadVideo(String authToken, String distressId, String videoFilePath) async{
   var uri = host + '/index.php?option=com_sellaciouscommunity&task=media.upload&format=json';
    Dio dio = new Dio();
    print('video upload started');
    FormData formData = new FormData.from({
      'record_id': distressId,
      'token': authToken,
      'field': 'footage',
      'context': 'distress', // Other Field
      'filestream': new UploadFileInfo(new File(videoFilePath), "distressAlert_${distressId}.mp4"),
    });
    

    try {
			Response response = await dio.post(uri, data: formData);
      final responseJson = json.decode(response.data);
			return responseJson;

		} catch (exception) {
			print(exception);
			if(exception.toString().contains('SocketException')) {
				return 'NetworkError';
			} else {
				return null;
			}
		} 
  }

	static fetch(var authToken, var endPoint) async {
		var uri = host + endPoint;

		try {
			final response = await http.get(
				uri,
				headers: {
					'Authorization': authToken
				},
			);

			final responseJson = json.decode(response.body);
			return responseJson;

		} catch (exception) {
			print(exception);
			if(exception.toString().contains('SocketException')) {
				return 'NetworkError';
			} else {
				return null;
			}
		}
	}
}