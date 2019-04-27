import 'package:shared_preferences/shared_preferences.dart';

class AttachDeviceToUserUtils {

	static final String endPoint = '/index.php?option=com_sellaciouscommunity&task=device.add&format=json';

	// Keys to store and fetch data from SharedPreferences
	static final String deviceId = 'device_id';
	static final String deviceType = 'device_type';

	static String getDeviceId(SharedPreferences prefs) {
		print("Device Id is ${prefs.getString(deviceId)}");
    print(prefs.getString('device_id'));
    return prefs.getString(deviceId);
	}

	static insertDetails(SharedPreferences prefs, var deviceId, var deviceType) {

    prefs.setString(deviceId, deviceId.toString());
		prefs.setString(deviceType, deviceType);
  }
	
}