import 'dart:io';

import 'package:actualia/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key, required this.title});
  final String title;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  String? _error;

  // @override
  // void initState() {
  //   super.initState();
  //   supabase.auth.onAuthStateChange.listen((data) {
  //     setState(() {
  //       _userEmail = data.session?.user.email;
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (_error != null) ...<Widget>[
          Text(
            _error!,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
        if (Platform.isAndroid) ...<Widget>[
          Text(
            'Welcome !',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(
            'You need to login before getting fresh news ;)',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          OutlinedButton(
            onPressed: () async {
              final ok =
                  await Provider.of<UserModel>(context, listen: false).signInWithGoogle();
              if (!ok) {
                setState(() {
                  _error = "Social login failed, check the logs";
                });
              }
            },
            child: const Text('Login with Google'),
          )
        ],
        if (!Platform.isAndroid) ...<Widget>[
          Text(
            'User is not authenticated',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(
            'Google Sign In is not available on this platform',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          OutlinedButton(
            onPressed: () async {
              final ok = await Provider.of<UserModel>(context, listen: false)
                  .signInWithEmail("fake", "fake");
              if (!ok) {
                setState(() {
                  _error = "Login failed. Check your credentials";
                });
              }
            },
            child: const Text('Login'),
          )
        ],
      ],
    ));
  }
}
