import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../models/room.dart';
import '../services/api_service.dart';

enum RoomStatus { idle, loading, ready, error }

class RoomProvider extends ChangeNotifier {
  final ApiService api;
  final ApiConfig config;

  Room? _room;
  RoomStatus _status = RoomStatus.idle;
  String? _errorMessage;

  RoomProvider({required this.api, required this.config}) {
    _room = null;
    final saved = config.currentRoomCode;
    if (saved != null) {
      _room = Room(
        id: 0,
        code: saved,
        name: null,
        createdAt: DateTime.now(),
      );
      _status = RoomStatus.ready;
    }
  }

  Room? get room => _room;
  RoomStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get hasRoom => _room != null;

  Future<bool> createRoom({String? name}) async {
    _setStatus(RoomStatus.loading);
    try {
      final created = await api.createRoom(name: name);
      _room = created;
      await config.setCurrentRoomCode(created.code);
      _setStatus(RoomStatus.ready);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _setStatus(RoomStatus.error);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _setStatus(RoomStatus.error);
      return false;
    }
  }

  Future<bool> joinRoom(String code) async {
    final trimmed = code.trim().toUpperCase();
    if (trimmed.isEmpty) {
      _errorMessage = 'Please enter a room code';
      _setStatus(RoomStatus.error);
      return false;
    }
    _setStatus(RoomStatus.loading);
    try {
      final room = await api.getRoom(trimmed);
      _room = room;
      await config.setCurrentRoomCode(room.code);
      _setStatus(RoomStatus.ready);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _setStatus(RoomStatus.error);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _setStatus(RoomStatus.error);
      return false;
    }
  }

  Future<bool> verifyRoom(String code) async {
    try {
      final room = await api.getRoom(code);
      _room = room;
      await config.setCurrentRoomCode(room.code);
      _setStatus(RoomStatus.ready);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _setStatus(RoomStatus.error);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _setStatus(RoomStatus.error);
      return false;
    }
  }

  Future<void> leaveRoom() async {
    _room = null;
    await config.setCurrentRoomCode(null);
    _setStatus(RoomStatus.idle);
  }

  Future<bool> deleteCurrentRoom() async {
    final r = _room;
    if (r == null) return false;
    try {
      await api.deleteRoom(r.code);
      _room = null;
      await config.setCurrentRoomCode(null);
      _setStatus(RoomStatus.idle);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _setStatus(RoomStatus.error);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _setStatus(RoomStatus.error);
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    if (_status == RoomStatus.error) {
      _status = _room != null ? RoomStatus.ready : RoomStatus.idle;
    }
    notifyListeners();
  }

  void _setStatus(RoomStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }
}
