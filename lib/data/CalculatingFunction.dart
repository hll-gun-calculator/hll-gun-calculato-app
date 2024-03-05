import 'package:json_annotation/json_annotation.dart';

part 'CalculatingFunction.g.dart';

@JsonSerializable()
class CalculatingFunction {
  final String name;
  final String version;
  final Map<String, dynamic>? child;
  final String author;
  final String website;

  CalculatingFunction({
    this.name = "none",
    this.version = "0.0.1",
    this.child,
    this.author = "",
    this.website = "",
  });

  factory CalculatingFunction.fromJson(Map<String, dynamic> json) =>
      _$CalculatingFunctionFromJson(json);

  Map<String, dynamic> toJson() => _$CalculatingFunctionToJson(this);
}
