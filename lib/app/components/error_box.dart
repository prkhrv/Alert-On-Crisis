import 'package:flutter/material.dart';

class ErrorBox extends StatelessWidget {
	final bool isError;
	final String errorText;
	ErrorBox({this.isError, this.errorText});
	
  @override
  Widget build(BuildContext context) {
	  if(isError) {
		  return new Container(
			  child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
				  children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 60.0,
                      child: Image.asset('lib/app/assets/logo.png', height: 80.0, width: 120.0,),
                    ),
                  ],
                ),
              ),
            ),
					
					  new Container(
						  decoration: new BoxDecoration(
							  border: const Border(
								  top: const BorderSide(width: 1.0, color: const Color(0xFFFF3F3F)),
								  left: const BorderSide(width: 1.0, color: const Color(0xFFFF3F3F)),
								  right: const BorderSide(width: 1.0, color: const Color(0xFFFF3F3F)),
								  bottom: const BorderSide(width: 1.0, color: const Color(0xFFFF3F3F)),
							  ),
							  borderRadius: new BorderRadius.circular(32.0)
						  ),
						  padding: const EdgeInsets.symmetric(vertical: 14.0),
						  margin: const EdgeInsets.only(bottom: 20.0),
						  child: new Center(
							  child: new Text(
								  errorText ?? '',
								  style: new TextStyle(color: Colors.red.shade500),
							  ),
						  )
					  ),
				
				  ] // children
			  ),
		  );
	  } else {
		  return new Container(
			  child: CircleAvatar(
          backgroundColor: Colors.white,
          radius: 60.0,
          child: Image.asset('lib/app/assets/logo.png', height: 120.0, width: 120.0,),
        )
		  );
	  }
  }	
}