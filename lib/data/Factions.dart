enum Factions {
  None(value: "None"),
  America(value: "America"),
  Germany(value: "Germany"),
  TheSovietUnion(value: "TheSovietUnion"),
  GreatBritain(value: "GreatBritain");

  final String value;

  const Factions({
    required this.value,
  });

  static List get toList {
    List _keys = [];
    for (var element in Factions.values) {
      _keys.add(element.value);
    }
    return _keys;
  }

  static Factions parse(int i) {
    if (i == -1) return Factions.None;
    return Factions.values[i];
  }
}
