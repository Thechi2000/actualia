import 'package:actualia/views/interests_wizard_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:actualia/models/auth_model.dart';
import 'package:actualia/viewmodels/news_settings.dart';

class ProfilePageView extends StatefulWidget {
  const ProfilePageView({super.key});

  @override
  State<ProfilePageView> createState() => _ProfilePageState();
}

enum SettingsRows {
  interests("Interests"),
  sources("Sources"),
  alarm("Alarm"),
  storage("Storage"),
  narrator("Narrator"),
  accessibility("Accessibility");

  const SettingsRows(this.name);
  final String name;
}

class _ProfilePageState extends State<ProfilePageView> {
  ValueNotifier<bool> isInterestUnfold = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    isInterestUnfold.addListener(() {
      build(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    AuthModel authModel = Provider.of<AuthModel>(context);
    NewsSettingsViewModel newsSettings =
        Provider.of<NewsSettingsViewModel>(context);

    String? _username = authModel.user?.email;
    List<String> _interests = newsSettings.settings?.interests ?? [];

    debugPrint("[ from PROFILEPAGEVIEW ] view called and instanciated");

    double unitPadding = 16.0;

    Widget profilePage = Center(
        child: ListView(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      children: <Widget>[
        // Username display
        Container(
            padding: EdgeInsets.symmetric(
                vertical: unitPadding / 2, horizontal: unitPadding + 16.0),
            alignment: Alignment.centerLeft,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                      style: TextStyle(
                          fontFamily: "Fira Code",
                          fontSize: 36.0, // Large
                          fontWeight: FontWeight.w600), // SettingsTitle => H1?
                      "Hello!"),
                  Container(
                      padding: EdgeInsets.symmetric(
                        vertical: unitPadding,
                        horizontal: 1.5 * unitPadding,
                      ),
                      child: Text(
                          style: const TextStyle(
                              fontFamily: "Fira Code",
                              fontSize: 16.0, // Small
                              color: Color(0xFF818181),
                              fontWeight: FontWeight.w300), // H2?
                          _username ?? "Unknown User")),
                  FilledButton.tonal(
                    onPressed: () async {
                      Navigator.pop(context);
                      if (await authModel.signOut()) {
                        debugPrint("signed out fine");
                      }
                    },
                    child: const Text(
                        style: TextStyle(fontFamily: "Fira Code"), "Logout"),
                  )
                ])),

        Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: ListView.separated(
              itemCount: SettingsRows.values.length,
              shrinkWrap: true,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                SettingsRows row = SettingsRows.values[index];
                return ListTile(
                    dense: true,
                    title: Text(
                        style: const TextStyle(
                            fontFamily: "Fira Code", fontSize: 16.0),
                        row.name),
                    titleAlignment: ListTileTitleAlignment.center,
                    onTap: () {
                      debugPrint("Click on ${row.name}"); // TODO: make Toast
                    });
              },
            )),

        // Redirection to home page
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Container(
              padding: EdgeInsets.symmetric(horizontal: unitPadding),
              child: TextButton(
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(
                        fontSize: 16.0, fontFamily: "Fira Code"), // Small
                  ),
                  onPressed: () {
                    print("Click on Done");
                    Navigator.pop(context);
                  },
                  child: const Text('Done'))),
        ]),
      ],
    ));

    return Material(
      child: Container(
          padding: const EdgeInsets.fromLTRB(16, 96, 16, 16),
          child: profilePage),
    );
  }
}
