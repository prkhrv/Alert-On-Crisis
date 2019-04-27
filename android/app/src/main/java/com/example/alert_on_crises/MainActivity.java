package com.example.alert_on_crises;
import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;


public class MainActivity extends FlutterActivity {
//  public static final String CHANNEL = "samples.flutter.io/location";
//  private FusedLocationProviderClient fusedLocationClient;
//  private Location locationSaved;

 @Override
 public void onCreate(Bundle savedInstanceState) {
  super.onCreate(savedInstanceState);
  GeneratedPluginRegistrant.registerWith(this);
//   fusedLocationClient = LocationServices.getFusedLocationProviderClient(this);
//   new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(new MethodChannel.MethodCallHandler() {
//    @Override
//    public void onMethodCall(MethodCall call, Result result) {
//     System.out.println(call.method);
//     if (call.method.equals("getLongitude")) {
//      int lng = getLongitude();
//      result.success(lng);
//     } else {
//      result.notImplemented();
//     }
//    }
//   });
 }

//  int getLongitude() {
//   if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) !=
//    PackageManager.PERMISSION_GRANTED) {
//    ActivityCompat.requestPermissions(this,
//     new String[] {
//      Manifest.permission.ACCESS_FINE_LOCATION
//     },
//     10);

//   } else {
//    fusedLocationClient.getLastLocation()
//     .addOnSuccessListener(this, new OnSuccessListener < Location > () {
//      @Override
//      public void onSuccess(Location location) {
//       // Got last known location. In some rare situations this can be null.
//       if (location != null) {
//        locationSaved=location;
//       }
//      }
//     });
//   }
//   if(locationSaved!=null) {
//       return (int)locationSaved.getLongitude();
//   }
//   return 0;
//  }

//  @Override
//  public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
//   switch (requestCode) {
//    case 10:
//     {
//      // If request is cancelled, the result arrays are empty.
//      if (grantResults.length > 0 &&
//       grantResults[0] == PackageManager.PERMISSION_GRANTED) {
//       getLongitude();
//      } else {
//       // permission denied, boo! Disable the
//       // functionality that depends on this permission.
//      }
//      return;
//     }
//   }
//  }
}