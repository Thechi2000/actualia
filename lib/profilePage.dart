import 'dart:math';

import 'package:actualia/models/news_settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:actualia/models/auth_model.dart';

class ProfilePageView extends StatefulWidget {
  const ProfilePageView({super.key});

  @override
  State<ProfilePageView> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePageView> {

  ValueNotifier<bool> isInterestUnfold = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    isInterestUnfold.addListener(() { build(context); });
  }

  @override
  Widget build(BuildContext context) {

    /* TODO : Fix the providers
    AuthModel authModel = Provider.of<AuthModel>(context);
    NewsSettings newsSettings = Provider.of<NewsSettings>(context);
    */

    // For test purposes
    /* 
    String? _username = "roman.paccaud@epfl.ch";
    List<String> _interests = ["Science", "Hollow Knight", "Daily Silksong News", "NDLM recherche un CQ", "CLIC", "PolyLAN 39"];
    
    String? _username = authModel.user?.email;
    List<String> _interests = newsSettings.interests;
    */ 

    String? _username = "roman.paccaud@epfl.ch";
    List<String> _interests = ["Science", "Hollow Knight", "Daily Silksong News", "NDLM recherche un CQ", "CLIC", "PolyLAN 39"];

    double verticalPadding = 20.0;
    double horizontalPadding = 16.0;

    Container line = Container(
            padding : const EdgeInsets.symmetric(horizontal: 16.0),
            child : const Divider()
            );

    Container fullLine = Container(
            child : const Divider()
            );

    Container getInterests() {
      if (!isInterestUnfold.value) {
        // Nothing
        return Container();
      }
      else {
        // List of all interests
        return Container(
          padding : EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
          child : Container(
            padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
            child : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _interests.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(16))
                    ),
                  child: Container(padding: const EdgeInsets.all(8.0), child : Text(_interests[index]))
                );
              }
            )
          ),
        );
      }
    }

    isInterestUnfold.addListener(() { getInterests(); });

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          // Username display
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children : [Container(
              padding : EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
              child : Text("Hey, $_username !")
            ),]
          ),
          fullLine,

          // User interests, initially folded but can be unfolded by clicking on "Interests"
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children : [Container(
              padding : EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
              child : TextButton(style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () { isInterestUnfold.value = !isInterestUnfold.value; },
              child: const Text('Interests'))
            ),]
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [getInterests(),]
          ),
          line,

          // Sources from which the user wants to be inform
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [Container(
              padding : EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
              child : TextButton(style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () { print("Click on sources"); },
              child: const Text('Sources'))
            ),]
          ),

          line,

          // Alarm manager
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [Container(
              padding : EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
              child : TextButton(style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () { print("Click on Alarm"); },
              child: const Text('Alarm'))
            ),]
          ),

          line,

          // Manage Storage
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [Container(
              padding : EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
              child : TextButton(style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () { print("Click on \"Manage Storage\""); },
              child: const Text('Manage Storage'))
            ),]
          ),

          line,

          // Narrator (voice) settings
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [Container(
              padding : EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
              child : TextButton(style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () { print("Click on Narrator"); },
              child: const Text('Narrator Settings'))
            ),]
          ),

          line,

          // Accessibility
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [Container(
              padding : EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
              child : TextButton(style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () { print("Click on Accessibility"); },
              child: const Text('Accessibility'))
            ),]
          ),

          fullLine,
        ],
      )
    );
  }
}
