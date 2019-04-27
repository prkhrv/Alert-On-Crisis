import 'package:shared_preferences/shared_preferences.dart';

class AuthUtils {

	static final String endPoint = '/index.php?option=com_sellaciouscommunity&task=user.authenticate&format=json';

	// Keys to store and fetch data from SharedPreferences
	static final String authTokenKey = 'auth_token';
	static final String userIdKey = 'user_id';
	static final String nameKey = 'name';
	static final String roleKey = 'role';

	static String getToken(SharedPreferences prefs) {
		return prefs.getString(authTokenKey);
	}

	static insertDetails(SharedPreferences prefs, var response) {
    prefs.setString(authTokenKey, response['data']['token']);
	}
	
}