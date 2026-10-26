class Constants {
  static Future<String> getBaseUrl(String ip) async {
    return "http://$ip:8000"; // Example base URL
  }

  static const String ttvEndPoint = "upload";
  static const String port = "8000";
}
