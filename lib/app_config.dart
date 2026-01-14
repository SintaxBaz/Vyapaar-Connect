class AppConfig {
  /// Optional: your backend endpoint that calls Gemini securely.
  /// Example (Firebase Functions): https://us-central1-<project-id>.cloudfunctions.net/parseMenu
  static const String geminiBackendUrl =
      String.fromEnvironment('GEMINI_BACKEND_URL');

  /// Dev-only fallback: calling Gemini directly from the app exposes the API key.
  /// Prefer using `geminiBackendUrl`.
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

  static bool get hasBackend => geminiBackendUrl.trim().isNotEmpty;
  static bool get hasApiKey => geminiApiKey.trim().isNotEmpty;
}
