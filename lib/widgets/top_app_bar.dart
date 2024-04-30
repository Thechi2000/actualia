import 'package:actualia/views/profile_view.dart';
import 'package:flutter/material.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool enableReturnButton;
  final void Function()? onPressed;

  const TopAppBar({
    this.enableReturnButton = false,
    this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //Invisible box to center the title
          const SizedBox(width: 40, height: 40),
          // Central button acting as the application title
          Expanded(
            child: TextButton(
              onPressed: () {
                // Action for the title button
              },
              style: TextButton.styleFrom(
                alignment: Alignment.center,
              ),
              child: const Text(
                'ActualIA',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24, // Medium
                  fontFamily: 'Fira Code',
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
          // Profile button aligned to the right
          IconButton(
            iconSize: 28.0,
            icon: const Icon(Icons.account_circle, color: Colors.grey),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (builder) => const ProfilePageView()));
            },
          ),
        ],
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48);
}
