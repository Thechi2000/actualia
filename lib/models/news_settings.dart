import 'package:country_list/country_list.dart';

class NewsSettings {
  List<String> cities;
  List<String> countries;
  List<String> interests;
  bool wantsCities;
  bool wantsCountries;
  bool wantsInterests;
  String locale;
  String userPrompt;

  // Predefined lists
  List<String> predefinedCities = [
    'New York',
    'Mexico',
    'Toronto',
    'Basel',
    'Lausanne',
    'Paris',
    'Rome',
    'Berlin',
    'Moscow'
  ];
  List<String> predefinedCountries = Countries.list.map((c) => c.name).toList();
  List<String> predefinedInterests = [
    'Sports',
    'Music',
    'Politics',
    'Gaming',
    'E-sports',
    'Research',
    'Physics',
    'Biology',
    'Math',
    'People',
    'Events',
  ];

  List<String> predefinedTitlePrompts = [
    'What are you interested in?',
    'What are you looking for?',
    'What do you want to know?',
    'What are you curious about?',
    'What are you passionate about?',
    'What are you excited about?',
    'What are you eager to learn?',
    'What are you eager to know?',
    'What are you eager to discover?',
    'What are you eager to explore?',
    'What are you eager to experience?',
  ];

  List<String> predefinedPrompts = [
    'What are you interested in?',
    'What are you looking for?',
    'What do you want to know?',
    'What are you curious about?',
    'What are you passionate about?',
    'What are you excited about?',
    'What are you eager to learn?',
    'What are you eager to know?',
    'What are you eager to discover?',
    'What are you eager to explore?',
    'What are you eager to experience?',
  ];

  NewsSettings(
      {required this.cities,
      required this.countries,
      required this.interests,
      required this.wantsCities,
      required this.wantsCountries,
      required this.wantsInterests,
      required this.locale,
      required this.userPrompt});

  factory NewsSettings.defaults() {
    return NewsSettings(
      cities: [],
      countries: [],
      interests: [],
      wantsCities: false,
      wantsCountries: false,
      wantsInterests: false,
      locale: 'en',
      userPrompt: '',
    );
  }
}
