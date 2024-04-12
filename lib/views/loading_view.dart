
import 'package:flutter/cupertino.dart';

class LoadingView extends StatelessWidget {

  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Fetching data ...",
        textScaler: TextScaler.linear(0.75),
      ),
    );
  }
}