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
    Widget leftCorner;
    if (enableReturnButton) {
      leftCorner = ReturnButton(onPressed!);
    } else {
      leftCorner = const SizedBox(width: 10);
    }

    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //Invisible box to center the title
          leftCorner,
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
                  fontSize: 22,
                  fontFamily: 'Fira Code',
                  fontWeight: FontWeight.w300,
                  height: 0.06,
                ),
              ),
            ),
          ),
          // Profile button aligned to the right
          IconButton(
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

class ReturnButton extends StatelessWidget {
  final void Function() onPressed;

  const ReturnButton(this.onPressed, {super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16.0),
      child: const Padding(
        padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: Icon(Icons.arrow_back_ios_new),
      ),
    );
  }
}
