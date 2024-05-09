import 'dart:convert';

class JsonUtil {
  Map _p (String value) {
    try {
      return {
        'status': true,
        'data': json.decode(value) as Map<String, dynamic>
      };
    } on FormatException catch (e) {
      return {
        'status': false,
        'message': 'The provided string is not valid JSON'
      };
    }
  }

  /// 是否Json
  bool isJson (String value) {
    return _p(value)['status'];
  }

  /// 判定并转换
  Map isSupAndConversion (String value) {
    Map _conversion = _p(value);

    if (!_conversion['status']) return {};
    return _conversion['data'];
  }
}