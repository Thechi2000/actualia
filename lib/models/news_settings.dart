class NewsSettings {
  final List<String> cities;
  final List<String> countries;
  final List<String> interests;
  final bool wantsCities;
  final bool wantsCountries;
  final bool wantsInterests;

  NewsSettings({
    required this.cities,
    required this.countries,
    required this.interests,
    required this.wantsCities,
    required this.wantsCountries,
    required this.wantsInterests,
  });
}
