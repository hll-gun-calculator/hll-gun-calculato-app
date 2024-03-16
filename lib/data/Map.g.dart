// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Map.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MapInfo _$MapInfoFromJson(Map<String, dynamic> json) => MapInfo(
      name: json['name'] as String? ?? "none",
      description: _$JsonConverterFromJson<Object, dynamic>(
              json['description'], const StringOrMapConverter().fromJson) ??
          "",
      size: json['size'] == null
          ? const Offset(1000, 1000)
          : MapInfo.ListAsOffset(json['size'] as List),
      initialPosition: json['initialPosition'] == null
          ? const Offset(0, 0)
          : MapInfo.ListAsOffset(json['initialPosition'] as List),
      factions: MapInfo.factionsFromJson(json['factions'] as Map),
      assets: json['assets'] == null
          ? null
          : MapInfoAssets.fromJson(json['assets'] as Map<String, dynamic>),
      childs: (json['childs'] as List<dynamic>?)
              ?.map((e) => MapInfoAssets.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      marker: (json['marker'] as List<dynamic>?)
          ?.map((e) => MapInfoMarkerItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MapInfoToJson(MapInfo instance) => <String, dynamic>{
      'name': instance.name,
      'description': const StringOrMapConverter().toJson(instance.description),
      'size': MapInfo.OffsetAsList(instance.size),
      'initialPosition': MapInfo.OffsetAsList(instance.initialPosition),
      'factions': MapInfo.ValueToJson(instance.factions),
      'assets': instance.assets,
      'childs': MapInfo.childsToJson(instance.childs),
      'marker': instance.marker,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

MapInfoFactionInfo _$MapInfoFactionInfoFromJson(Map<String, dynamic> json) =>
    MapInfoFactionInfo(
      gunPosition: (json['gunPosition'] as List<dynamic>?)
              ?.map((e) => Gun.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      points: json['points'] == null
          ? const []
          : MapInfoFactionInfo.pointsFromJson(json['points'] as List),
      direction: $enumDecodeNullable(
              _$MapInfoFactionInfoDirectionEnumMap, json['direction']) ??
          MapInfoFactionInfoDirection.Left,
    );

Map<String, dynamic> _$MapInfoFactionInfoToJson(MapInfoFactionInfo instance) =>
    <String, dynamic>{
      'gunPosition': instance.gunPosition,
      'points': MapInfoFactionInfo.pointsToJson(instance.points),
      'direction': MapInfoFactionInfo.MapInfoFactionInfoDirectionToJson(
          instance.direction),
    };

const _$MapInfoFactionInfoDirectionEnumMap = {
  MapInfoFactionInfoDirection.Top: 'Top',
  MapInfoFactionInfoDirection.Left: 'Left',
  MapInfoFactionInfoDirection.Right: 'Right',
  MapInfoFactionInfoDirection.Bottom: 'Bottom',
};

MapInfoMarkerItem _$MapInfoMarkerItemFromJson(Map<String, dynamic> json) =>
    MapInfoMarkerItem(
      name: json['name'] as String? ?? "none",
      iconType: $enumDecode(_$MapIconTypeEnumMap, json['iconType']),
      iconPath: json['iconPath'] as String? ?? "",
      points: (json['points'] as List<dynamic>?)
              ?.map((e) => MarkerPointItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$MapInfoMarkerItemToJson(MapInfoMarkerItem instance) =>
    <String, dynamic>{
      'name': instance.name,
      'iconType': _$MapIconTypeEnumMap[instance.iconType]!,
      'iconPath': instance.iconPath,
      'points': instance.points,
    };

const _$MapIconTypeEnumMap = {
  MapIconType.None: 'None',
  MapIconType.Url: 'Url',
  MapIconType.Assets: 'Assets',
  MapIconType.Arty: 'Arty',
  MapIconType.PresupposeArty: 'PresupposeArty',
  MapIconType.CollectArty: 'CollectArty',
  MapIconType.PlainGrid: 'PlainGrid',
  MapIconType.ArtyRadius: 'ArtyRadius',
  MapIconType.Landmark: 'Landmark',
};

MarkerPointItem _$MarkerPointItemFromJson(Map<String, dynamic> json) =>
    MarkerPointItem(
      name: json['name'] as String? ?? "none",
      x: (json['x'] as num?)?.toDouble() ?? .0,
      y: (json['y'] as num?)?.toDouble() ?? -.0,
      id: json['id'] as String?,
    );

Map<String, dynamic> _$MarkerPointItemToJson(MarkerPointItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'x': instance.x,
      'y': instance.y,
    };

MapInfoAssets _$MapInfoAssetsFromJson(Map<String, dynamic> json) =>
    MapInfoAssets(
      index: json['index'] as int? ?? 0,
      type: $enumDecodeNullable(_$MapIconTypeEnumMap, json['type']) ??
          MapIconType.None,
      network: json['network'] as String?,
      local: json['local'] as String?,
    );

Map<String, dynamic> _$MapInfoAssetsToJson(MapInfoAssets instance) =>
    <String, dynamic>{
      'index': instance.index,
      'type': _$MapIconTypeEnumMap[instance.type]!,
      'network': instance.network,
      'local': instance.local,
    };
