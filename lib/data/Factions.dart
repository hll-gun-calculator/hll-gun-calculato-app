// ignore_for_file: file_names, constant_identifier_names

enum Factions {
  None(value: "None"),
  UnitedStates(value: "UnitedStates"),
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

  static Factions _getItemAsName (String name) {
    Factions _key = Factions.None;
    for (var i in Factions.values) {
      if (i.value == name) _key = i;
    }
    return _key;
  }

  static Factions parse(dynamic i) {
    if (i is int) {
      if (i == -1) return Factions.None;
      return Factions.values[i];
    }

    if (i is String && Factions.toList.contains(i)) {
      return _getItemAsName(i);
    }

    if (i is Factions) {
      return i;
    }

    return Factions.None;
  }
}