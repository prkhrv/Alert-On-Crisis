import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  LoginButton({this.onPressed});
  
	@override
  Widget build(BuildContext context) {
		return new Container(
			margin: const EdgeInsets.symmetric(vertical: 12.0),
			child: new Align(
        alignment: FractionalOffset.centerRight,
				
        child: new RaisedButton(
          shape: CircleBorder(),
          color: Color(0xFF00FF64),
          padding:EdgeInsets.all(10.0),
          child: Icon(Icons.arrow_forward),
          onPressed: onPressed
        )
      ) 
		);
  }	
}