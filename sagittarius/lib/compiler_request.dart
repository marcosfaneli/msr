import 'dart:convert';

class CompilerRequest {
  String code;
  String className;

  CompilerRequest({required this.code, required this.className});

  Map<String, dynamic> toJson() => {
        'code': code,
        'className': className,
      };

  factory CompilerRequest.fromJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return CompilerRequest(
      code: json['code'],
      className: json['className'],
    );
  }
}
