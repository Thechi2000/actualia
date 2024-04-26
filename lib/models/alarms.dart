class Alarms {
  bool enabled;

  Alarms({
    required this.enabled,
  });

  factory Alarms.defaults() {
    return Alarms(
      enabled: false,
    );
  }
}
