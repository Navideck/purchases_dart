import 'dart:core';

final RegExp rcApiKeyRegex = RegExp(r'^rcb_[a-zA-Z0-9_.-]+$');
final RegExp paddleApiKeyRegex = RegExp(r'^pdl_[a-zA-Z0-9_.-]+$');
final RegExp rcSimulatedStoreApiKeyRegex = RegExp(r'^test_[a-zA-Z0-9_.-]+$');

/// Checks if the API key is a web billing sandbox key
///
/// [apiKey] - The API key string to check
/// Returns true if the API key starts with "rcb_sb_", false otherwise
bool isWebBillingSandboxApiKey(String? apiKey) {
  return apiKey?.startsWith('rcb_sb_') ?? false;
}

/// Checks if the API key is a valid web billing API key
///
/// [apiKey] - The API key string to check
/// Returns true if the API key matches the RevenueCat API key format, false otherwise
bool isWebBillingApiKey(String? apiKey) {
  return apiKey != null ? rcApiKeyRegex.hasMatch(apiKey) : false;
}

/// Checks if the API key is a valid Paddle API key
///
/// [apiKey] - The API key string to check
/// Returns true if the API key matches the Paddle API key format, false otherwise
bool isPaddleApiKey(String? apiKey) {
  return apiKey != null ? paddleApiKeyRegex.hasMatch(apiKey) : false;
}

/// Checks if the API key is a simulated store API key
///
/// [apiKey] - The API key string to check
/// Returns true if the API key matches the simulated store API key format, false otherwise
bool isSimulatedStoreApiKey(String? apiKey) {
  return apiKey != null ? rcSimulatedStoreApiKeyRegex.hasMatch(apiKey) : false;
}
