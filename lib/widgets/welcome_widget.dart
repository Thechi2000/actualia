import 'package:actualia/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WelcomeWidget extends StatelessWidget {
  const WelcomeWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Consumer<UserModel>(
            builder: (context, model, child) => Text(
              "Welcome ${model.user?.email ?? 'UnknownEmail'}!",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          )
        ],
      ),
    );
  }
}