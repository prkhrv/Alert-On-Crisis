import 'package:shared_preferences/shared_preferences.dart';

class DistressAlertUtils {

	static final String endPoint = '/index.php?option=com_sellaciouscommunity&task=distress.alert&format=json';

	// Keys to store and fetch data from SharedPreferences
	static final String distressAlertId = 'distress_alert';

	static String getData(SharedPreferences prefs, key) {
		return prefs.getString(key);
	}

	static insertData(SharedPreferences prefs, key, value) {
    prefs.setString(key, value);
    print('The value of ${key} is ${prefs.getString(key)}');
	}
  
}