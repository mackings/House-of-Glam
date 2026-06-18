/// 🌐 API Configuration

class ApiConfig {
  // 🔗 Base URL for all API endpoints
  // static const String baseUrl = "https://hog-fyic.onrender.com";

  static const String baseUrl = "https://hog-backend-s6w9.onrender.com";

  //static const String baseUrl = "https://hogbackend.vercel.app";

  // 📡 API Version
  static const String apiVersion = "v1";

  // 🔗 Full API Base URL (with version)
  static const String apiBaseUrl = "$baseUrl/api/$apiVersion";

  // ⏱️ Default timeout durations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // 📋 Common Headers
  static Map<String, String> get defaultHeaders => {
    "Content-Type": "application/json",
  };

  static Map<String, String> getAuthHeaders(String token) => {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token",
  };
}
