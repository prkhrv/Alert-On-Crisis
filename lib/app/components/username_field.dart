import 'package:flutter/material.dart';

class UsernameField extends StatelessWidget {
	final TextEditingController usernameController;
	final String usernameError;
  UsernameField({this.usernameController, this.usernameError});
  
	@override
  Widget build(BuildContext context) {
    return new Container(
      height: 40.0,
	    child: new TextField(
        
        keyboardType: TextInputType.text,
        controller: usernameController,
        style: new TextStyle(
          height: 1.5
        ),
        decoration: new InputDecoration(
          
          fillColor: Colors.white,
            
          filled: true,
          contentPadding: const EdgeInsets.all(4.0),
          errorText: usernameError,
          labelText: 'Username',
        )
		  )
	  );
  }
	
}