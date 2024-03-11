enum MapIconType {
  None(value: "None"),
  // 自定义图片
  Url(value: "Url"),
  Assets(value: "Assets"),
  // 地图内置图片
  Arty(value: "Arty", path: "assets/images/icon/arty.png"),
  PresupposeArty(value: "PresupposeArty", path: "assets/images/icon/arty.png"),
  CollectArty(value: "CollectArty", path: "assets/images/icon/arty.png"),
  PlainGrid(value: "PlainGrid"),
  ArtyRadius(value: "ArtyRadius");

  final String value;

  final String? path;

  const MapIconType({
    required this.value,
    this.path,
  });
}
