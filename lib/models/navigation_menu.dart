import 'package:flutter/material.dart';

class Destination {
  final Views view;
  final IconData icon;
  final void Function(Views) onPressed;

  Destination(
      {required this.view, required this.icon, required this.onPressed});
}

enum Views { NEWS, CAMERA, FEED }
