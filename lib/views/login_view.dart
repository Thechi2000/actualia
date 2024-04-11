import 'package:actualia/models/auth_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  String? _error;

  @override
  Widget build(BuildContext context) {
    AuthModel authModel = Provider.of(context);
    double viewWidth = MediaQuery.of(context).size.width;

    Image monogram = Image.asset('assets/img/monogram.png', width: .35*viewWidth);
    
    return SizedBox(
      width: double.maxFinite, // hacky potentially
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max, 
        children: <Widget>[
          monogram,
          const Text("LOGIN GOES HERE")
        ],
      )
    );
  }
}
