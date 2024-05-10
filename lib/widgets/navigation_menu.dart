import 'package:flutter/material.dart';

import '../models/navigation_bar.dart';

class ActualiaBottomNavigationBar extends StatefulWidget {
  final List<Destination> destinations;
  const ActualiaBottomNavigationBar({required this.destinations, super.key});

  @override
  State<ActualiaBottomNavigationBar> createState() =>
      _ActualiaBottomNavigationBar();
}

class _ActualiaBottomNavigationBar extends State<ActualiaBottomNavigationBar> {
  Views _currentView = Views.NEWS;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget bar = Container(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: widget.destinations.map((dest) {
          return OutlinedButton(
            child: dest.icon,
            onPressed: () {
              setState(() {
                _currentView = dest.view;
              });
              dest.onPressed(_currentView);
            },
          );
        }).toList(),
      ),
    );

    return bar;
  }
}
