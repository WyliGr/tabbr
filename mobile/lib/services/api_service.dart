import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/balance.dart';
import '../models/expense.dart';
import '../models/member.dart';
import '../models/room.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  final ApiConfig _config;
  final Dio _dio;

  ApiService(this._config)
      : _dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 10),
            contentType: 'application/json',
            responseType: ResponseType.json,
          ),
        );

  String get _base => '${_config.serverUrl}/api';

  void _rebuildDio() {
    _dio.options.baseUrl = _base;
  }

  Future<T> _wrap<T>(Future<Response<dynamic>> Function() call,
      T Function(dynamic) parse) async {
    _rebuildDio();
    try {
      final response = await call();
      return parse(response.data);
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e), statusCode: e.response?.statusCode);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> _wrapVoid(Future<Response<dynamic>> Function() call) async {
    _rebuildDio();
    try {
      await call();
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e), statusCode: e.response?.statusCode);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['detail'] != null) {
      return data['detail'].toString();
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Could not connect to server. Check the URL and try again.';
    }
    if (e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Request timed out. Please try again.';
    }
    return e.message ?? 'Network error';
  }

  Future<bool> testConnection() async {
    _rebuildDio();
    try {
      final response = await _dio.get<dynamic>('/rooms/AAAAA');
      return response.statusCode == 404 || response.statusCode == 200;
    } on DioException catch (e) {
      // Only a 404 (room not found) or 200 means the API is alive.
      // A 502/503/500 means the server is behind a proxy but the backend is down.
      if (e.response != null) {
        final code = e.response!.statusCode;
        return code == 404 || code == 200;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<Room> createRoom({String? name}) {
    return _wrap<Room>(
      () => _dio.post<dynamic>('/rooms', data: {
        if (name != null && name.isNotEmpty) 'name': name,
      }),
      (data) => Room.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<Room> getRoom(String code) {
    return _wrap<Room>(
      () => _dio.get<dynamic>('/rooms/$code'),
      (data) => Room.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> deleteRoom(String code) {
    return _wrapVoid(
      () => _dio.delete<dynamic>('/rooms/$code'),
    );
  }

  Future<List<Member>> listMembers(String code) {
    return _wrap<List<Member>>(
      () => _dio.get<dynamic>('/rooms/$code/members'),
      (data) => (data as List<dynamic>)
          .map((e) => Member.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<Member> addMember(String code, String name) {
    return _wrap<Member>(
      () => _dio.post<dynamic>('/rooms/$code/members', data: {'name': name}),
      (data) => Member.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> deleteMember(String code, int memberId) {
    return _wrapVoid(
      () => _dio.delete<dynamic>('/rooms/$code/members/$memberId'),
    );
  }

  Future<List<Expense>> listExpenses(String code) {
    return _wrap<List<Expense>>(
      () => _dio.get<dynamic>('/rooms/$code/expenses'),
      (data) => (data as List<dynamic>)
          .map((e) => Expense.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<Expense> createExpense(
    String code, {
    required double amount,
    required String description,
    required int payerId,
    DateTime? date,
    List<Map<String, num>>? splits,
  }) {
    return _wrap<Expense>(
      () => _dio.post<dynamic>('/rooms/$code/expenses', data: {
        'amount': amount,
        'description': description,
        'payer_id': payerId,
        if (date != null) 'date': date.toUtc().toIso8601String(),
        if (splits != null)
          'splits': splits
              .map((s) => {
                    'member_id': s['member_id'],
                    'share': s['share'],
                  })
              .toList(),
      }),
      (data) => Expense.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> deleteExpense(String code, int expenseId) {
    return _wrapVoid(
      () => _dio.delete<dynamic>('/rooms/$code/expenses/$expenseId'),
    );
  }

  Future<Balance> getBalance(String code) {
    return _wrap<Balance>(
      () => _dio.get<dynamic>('/rooms/$code/balance'),
      (data) => Balance.fromJson(data as Map<String, dynamic>),
    );
  }
}
