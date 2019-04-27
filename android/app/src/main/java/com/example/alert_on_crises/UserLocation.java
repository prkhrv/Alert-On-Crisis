// package com.example.alert_on_crises;

// import android.content.Context;
// import android.content.ContextWrapper;
// import android.os.Bundle;
// import android.app.Activity;
// import android.content.pm.PackageManager;
// import android.location.Location;
// import android.location.LocationListener;
// import android.location.LocationManager;

// import android.support.v4.app.ActivityCompat;
// import android.support.v4.content.ContextCompat;
// import android.support.v7.app.AppCompatActivity;
// import android.util.Log;

// public class UserLocation extends Activity implements LocationListener {
//   private LocationManager locationManager;
//   private String provider;
//   private Location location;
//   @Override
//   public void onCreate(Bundle savedInstanceState) {
//     super.onCreate(savedInstanceState);
//     locationManager = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
//     provider = LocationManager.GPS_PROVIDER;

//     // if (ActivityCompat.checkSelfPermission(this, android.Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
//     //   ActivityCompat.requestPermissions(this, new String[]{android.Manifest.permission.ACCESS_FINE_LOCATION}, 10);

//     //   // TODO: Consider calling
//     //   //    ActivityCompat#requestPermissions
//     //   // here to request the missing permissions, and then overriding
//     //   //   public void onRequestPermissionsResult(int requestCode, String[] permissions,
//     //   //                                          int[] grantResults)
//     //   // to handle the case where the user grants the permission. See the documentation
//     //   // for ActivityCompat#requestPermissions for more details.
//     //   return;
//     // }
//     location = locationManager.getLastKnownLocation(provider);

//   }

//   // int getLongitude(){
//   //   if (location != null){
//   //     int lng = (int) (location.getLongitude());
//   //     return lng;
//   //   } else {
//   //     return 0;
//   //   }
//   // }

//   int getLongitude(){
//     if (location != null){
//       int lat = (int) (location.getLongitude());
//       return lat;
//     } else{
//       if (!checkPermissions(this)){
//         requestPermissions();
//         int lat = (int) (location.getLongitude());
//         return lat;
//       }else{
//         int lat = (int) (location.getLongitude());
//         return lat;
//       }
//     }
//   }

//   private boolean checkPermissions(Activity activity) {
//     int permissionState = ActivityCompat.checkSelfPermission(activity, android.Manifest.permission.ACCESS_FINE_LOCATION);
//     return permissionState == PackageManager.PERMISSION_GRANTED;
//   }

//   protected void onResume() {
//     super.onResume();
//     if (ActivityCompat.checkSelfPermission(this, android.Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(this, android.Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
//       ActivityCompat.requestPermissions(this, new String[]{android.Manifest.permission.ACCESS_FINE_LOCATION}, 10);
//       // TODO: Consider calling
//       //    ActivityCompat#requestPermissions
//       // here to request the missing permissions, and then overriding
//       //   public void onRequestPermissionsResult(int requestCode, String[] permissions,
//       //                                          int[] grantResults)
//       // to handle the case where the user grants the permission. See the documentation
//       // for ActivityCompat#requestPermissions for more details.
//       return;
//     }
//     locationManager.requestLocationUpdates(provider, 400, 0, this);
//   }

//     /* Remove the locationlistener updates when Activity is paused */
//     @Override
//     protected void onPause() {
//       super.onPause();
//       locationManager.removeUpdates(this);
//     }

//     @Override
//     public void onLocationChanged(Location location) {
//       Log.d("location change:", " change1  " );
//       int lat = (int) (location.getLatitude());
//       int lng = (int) (location.getLongitude());
//     }

//     @Override
//     public void onStatusChanged(String provider, int status, Bundle extras) {
//       // TODO Auto-generated method stub
//     }

//     @Override
//     public void onProviderEnabled(String provider) {

//     }

//     @Override
//     public void onProviderDisabled(String provider) {
//     }

//     private void requestPermissions() {
//       ActivityCompat.requestPermissions(this, new String[]{android.Manifest.permission.ACCESS_FINE_LOCATION}, 10);
//     }


//     // @Override
//     // public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
//     //   switch (requestCode) {
//     //     case 10: {
//     //       if (grantResults.length > 0 &&
//     //         grantResults[0] == PackageManager.PERMISSION_GRANTED) {
//     //       } else {
//     //       }
//     //       return;
//     //     }
//     //   }
//     // }
    
//     // private void getLocation() {
//     //     if (ContextCompat.checkSelfPermission(this, android.android.Manifest.permission.ACCESS_FINE_LOCATION) !=
//     //         PackageManager.PERMISSION_GRANTED) {
//     //         ActivityCompat.requestPermissions(this,
//     //             new String[] {
//     //                 android.Manifest.permission.ACCESS_FINE_LOCATION
//     //             },
//     //             10);

//     //     } else {
//     //         locationManager.getLastKnownLocation(provider)
//     //             .addOnSuccessListener(this, new OnSuccessListener < Location > () {
//     //                 @Override
//     //                 public void onSuccess(Location location) {
//     //                     // Got last known location. In some rare situations this can be null.
//     //                     if (location != null) {
//     //                         // use location.getLatitude() and location.getLongitude()

//     //                     }
//     //                 }
//     //             });
//     //     }

//     // }

//     // 
// }