import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  final String text;
  const LoadingView({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Align(
              child: Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontFamily: 'EB Garamond',
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          )),
          const SizedBox(height: 16),
          const Align(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
