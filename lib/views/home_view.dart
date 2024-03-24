import 'package:actualia/widgets/welcome_widget.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key, required this.title});
  final String title;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const WelcomeWidget(),
          OutlinedButton(
            onPressed: () {
              print("Logout button pressed");
            },
            child: const Text('Logout'),
          )
        ]);
  }
}
