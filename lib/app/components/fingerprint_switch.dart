import 'package:flutter/material.dart';

class FingerprintField extends StatelessWidget {
   bool switchFieldValue;
  
  FingerprintField({this.switchFieldValue});

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        new Switch(
          value: switchFieldValue,
          inactiveThumbColor: Colors.green,
          inactiveTrackColor: Colors.grey,
          activeColor: Colors.green,
          onChanged: (bool e) {switchFieldValue = e
          ;},
        ),
        new Expanded(child: new Text('Enable Fingerprint', 
          style: TextStyle(color: Colors.white, fontSize: 18.0)
          )
        ),
      ],
    );
  }
}