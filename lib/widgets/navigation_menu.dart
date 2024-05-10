import 'package:actualia/utils/themes.dart';
import 'package:flutter/material.dart';

import '../models/navigation_menu.dart';

class ActualiaBottomNavigationBar extends StatefulWidget {
  final List<Destination> destinations;
  const ActualiaBottomNavigationBar({required this.destinations, super.key});

  @override
  State<ActualiaBottomNavigationBar> createState() =>
      _ActualiaBottomNavigationBar();
}

class _ActualiaBottomNavigationBar extends State<ActualiaBottomNavigationBar> {
  Views _currentView = Views.NEWS;

  void setCurrentViewState(Views view) {
    if (view != Views.CAMERA) {
      setState(() {
        _currentView = view;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget bar = Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: widget.destinations.map((dest) {
          return RawMaterialButton(
            fillColor: dest.view == _currentView ? THEME_BUTTON : null,
            onPressed: () {
              setCurrentViewState(dest.view);
              dest.onPressed(_currentView);
            },
            child: dest.icon,
          );
        }).toList(),
      ),
    );

    return bar;
  }
}
