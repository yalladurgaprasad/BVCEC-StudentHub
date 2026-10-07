import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class ApiServiceException implements Exception {
  final String message;
  final int? statusCode;

  ApiServiceException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiServiceException: $message (Status: ${statusCode ?? "N/A"})';
}

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  final http.Client client;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  Future<List<UserModel>> fetchUsers({String endpoint = '$baseUrl/users'}) async {
    try {
      final response = await client.get(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => UserModel.fromJson(json)).toList();
      } else if (response.statusCode == 400) {
        throw ApiServiceException('Bad Request: Invalid endpoint or payload.', 400);
      } else if (response.statusCode == 404) {
        throw ApiServiceException('Resource Not Found (404).', 404);
      } else if (response.statusCode >= 500) {
        throw ApiServiceException('Server Error (${response.statusCode}). Please try again later.', response.statusCode);
      } else {
        throw ApiServiceException('Failed to load users (${response.statusCode}).', response.statusCode);
      }
    } on SocketException {
      throw ApiServiceException('No Internet Connection. Please check your network setting.');
    } on http.ClientException catch (e) {
      throw ApiServiceException('Network Error: ${e.message}');
    } on FormatException {
      throw ApiServiceException('Invalid Response Format received from server.');
    } catch (e) {
      if (e is ApiServiceException) rethrow;
      throw ApiServiceException('Unexpected error: ${e.toString()}');
    }
  }
}
