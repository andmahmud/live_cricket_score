import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../config/constants.dart';
import '../../models/match_model.dart';
import '../logging/logger_service.dart';

class CricketApiService {
  final http.Client _client;
  static const Duration _timeout = Duration(seconds: 15);

  CricketApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<MatchModel>> fetchAllMatches() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.liveMatches}');
    AppLogger.logApiRequest(url.toString());

    try {
      final response = await _client.get(url).timeout(_timeout);
      AppLogger.logApiResponse(url.toString(), response.statusCode);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseMatchesResponse(data);
      } else {
        throw ApiException(
          'Server returned ${response.statusCode}',
          response.statusCode,
        );
      }
    } on SocketException catch (e) {
      AppLogger.logError('Network error fetching matches', e);
      throw ApiException('No internet connection', 0);
    } on TimeoutException catch (e) {
      AppLogger.logError('Timeout fetching matches', e);
      throw ApiException('Request timed out', 0);
    } on FormatException catch (e) {
      AppLogger.logError('Invalid JSON response', e);
      throw ApiException('Invalid data received', 0);
    }
  }

  Future<MatchModel> fetchMatchDetails(String matchId) async {
    final url =
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.matchScore(matchId)}');
    AppLogger.logApiRequest(url.toString());

    try {
      final response = await _client.get(url).timeout(_timeout);
      AppLogger.logApiResponse(url.toString(), response.statusCode);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseMatchDetail(data);
      } else {
        throw ApiException(
          'Server returned ${response.statusCode}',
          response.statusCode,
        );
      }
    } on SocketException catch (e) {
      AppLogger.logError('Network error fetching match details', e);
      throw ApiException('No internet connection', 0);
    } on TimeoutException catch (e) {
      AppLogger.logError('Timeout fetching match details', e);
      throw ApiException('Request timed out', 0);
    } on FormatException catch (e) {
      AppLogger.logError('Invalid JSON response for match details', e);
      throw ApiException('Invalid data received', 0);
    }
  }

  List<MatchModel> _parseMatchesResponse(dynamic data) {
    try {
      if (data is List) {
        return data
            .map((e) => MatchModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (data is Map<String, dynamic>) {
        if (data.containsKey('matches')) {
          final matches = data['matches'];
          if (matches is List) {
            return matches
                .map((e) => MatchModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
        }
        if (data.containsKey('data')) {
          final matchesData = data['data'];
          if (matchesData is List) {
            return matchesData
                .map((e) => MatchModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
        }
        final match = MatchModel.fromJson(data);
        if (match.id.isNotEmpty) {
          return [match];
        }
      }
      return [];
    } catch (e) {
      AppLogger.logError('Error parsing matches response', e);
      return [];
    }
  }

  MatchModel _parseMatchDetail(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        if (data.containsKey('match')) {
          return MatchModel.fromJson(
              data['match'] as Map<String, dynamic>);
        }
        return MatchModel.fromJson(data);
      }
      throw ApiException('Invalid match details format', 0);
    } catch (e) {
      if (e is ApiException) rethrow;
      AppLogger.logError('Error parsing match details', e);
      throw ApiException('Failed to parse match details', 0);
    }
  }

  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  const ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
