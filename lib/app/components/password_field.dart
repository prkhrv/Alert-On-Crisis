import 'package:flutter/material.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController passwordController;
  final bool obscureText;
  final String passwordError;
  final VoidCallback togglePassword;
  PasswordField({
	  this.passwordController,
	  this.obscureText,
	  this.passwordError,
	  this.togglePassword
  });
  
	@override
  Widget build(BuildContext context) {
		return new Container(
			margin: const EdgeInsets.only(bottom: 16.0),
			child: new TextField(
        style: new TextStyle(
          height: 1.5
        ),
        controller: passwordController,
        obscureText: obscureText,
        decoration: new InputDecoration(
          errorText: passwordError,
          fillColor: Colors.white,

          filled: true,
          contentPadding: const EdgeInsets.all(4.0),
          labelText: 'Password',
          suffixIcon: new GestureDetector(
            onTap: togglePassword,
            child: new Icon(Icons.remove_red_eye),
          )
        )
      )
		);
  }	
}