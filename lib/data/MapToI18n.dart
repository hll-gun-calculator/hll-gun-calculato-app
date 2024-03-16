import 'package:json_annotation/json_annotation.dart';

/// 多语言转换
/// 例子:
/// "name" : {
///   "zh_CN": 1,
///   "en_US": "one"
/// }
///
/// or
///
/// "name" : "one"
class StringOrMapConverter implements JsonConverter<dynamic, Object> {
  const StringOrMapConverter();

  @override
  dynamic fromJson(Object json) {
    if (json is String && json.isEmpty) return json ?? "";

    if (json is Map<String, dynamic>) {
      return json;
    } else if (json is String) {
      return json;
    }

    return json;
  }

  @override
  Object toJson(dynamic object) {
    return object ?? Object();
  }
}
