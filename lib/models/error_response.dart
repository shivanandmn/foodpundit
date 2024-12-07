import 'error_code.dart';

class ErrorResponse {
  final ErrorCode code;
  final String message;
  final dynamic details;
  final bool shouldReturnToCamera;

  ErrorResponse({
    required this.code,
    required this.message,
    this.details,
    this.shouldReturnToCamera = false,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      code: ErrorCode.fromString(json['code'] as String),
      message: json['message'] as String,
      details: json['details'],
      shouldReturnToCamera: json['shouldReturnToCamera'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code.value,
      'message': message,
      if (details != null) 'details': details,
      'shouldReturnToCamera': shouldReturnToCamera,
    };
  }
}
