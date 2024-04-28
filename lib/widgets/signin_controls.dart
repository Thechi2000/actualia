import 'package:actualia/models/auth_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class SignInControls extends StatefulWidget {
  const SignInControls({super.key});

  @override
  State<SignInControls> createState() => _SignInControls();
}

class _SignInControls extends State<SignInControls> {
  String? _error;

  @override
  Widget build(BuildContext context) {
    AuthModel authModel = Provider.of(context);
    SvgPicture googleLogo = SvgPicture.asset('assets/img/g_logo.svg');
    double viewWidth = MediaQuery.of(context).size.width;

    return Column(// lots of hardcoded values ! so fun
        children: <Widget>[
      ElevatedButton(
          child: Container(
            padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                      padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                      child: googleLogo),
                  const Text(
                      style: TextStyle(
                        fontFamily: "EB Garamond",
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                      "Sign in with Google"),
                ]),
          ),
          onPressed: () async {
            await authModel.signInWithGoogle();
          }),
      Container(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: TextButton(
              key: const Key("signin-guest"),
              child: const Text(
                  style: TextStyle(
                    fontFamily: "EB Garamond",
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  "Sign in as guest"),
              onPressed: () async {
                await authModel.signInWithFakeAccount();
              })),
      if (_error != null) ...<Widget>[
        Text(
          _error!,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    ]);
  }
}
