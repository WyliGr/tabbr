import 'package:flutter/foundation.dart';

import '../models/balance.dart';
import '../models/expense.dart';
import '../models/member.dart';
import '../models/room.dart';
import '../services/api_service.dart';

enum LoadStatus { idle, loading, ready, error }

class ExpenseProvider extends ChangeNotifier {
  final ApiService api;

  Room? _room;
  List<Member> _members = const [];
  List<Expense> _expenses = const [];
  Balance _balance = const Balance(entries: []);
  LoadStatus _status = LoadStatus.idle;
  String? _errorMessage;

  ExpenseProvider({required this.api});

  Room? get room => _room;
  List<Member> get members => _members;
  List<Expense> get expenses => _expenses;
  Balance get balance => _balance;
  LoadStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == LoadStatus.loading;

  void setRoom(Room? room) {
    _room = room;
    _members = const [];
    _expenses = const [];
    _balance = const Balance(entries: []);
    _status = LoadStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> refresh() async {
    final room = _room;
    if (room == null) return;
    _setStatus(LoadStatus.loading);
    try {
      final results = await Future.wait([
        api.listMembers(room.code),
        api.listExpenses(room.code),
        api.getBalance(room.code),
      ]);
      _members = results[0] as List<Member>;
      _expenses = results[1] as List<Expense>;
      _balance = results[2] as Balance;
      _setStatus(LoadStatus.ready);
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _setStatus(LoadStatus.error);
    } catch (e) {
      _errorMessage = e.toString();
      _setStatus(LoadStatus.error);
    }
  }

  Future<bool> addMember(String name) async {
    final room = _room;
    if (room == null) return false;
    try {
      final member = await api.addMember(room.code, name.trim());
      _members = [..._members, member];
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMember(int memberId) async {
    final room = _room;
    if (room == null) return false;
    try {
      await api.deleteMember(room.code, memberId);
      _members = _members.where((m) => m.id != memberId).toList();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addExpense({
    required double amount,
    required String description,
    required int payerId,
    DateTime? date,
    List<Map<String, num>>? splits,
  }) async {
    final room = _room;
    if (room == null) return false;
    try {
      final expense = await api.createExpense(
        room.code,
        amount: amount,
        description: description,
        payerId: payerId,
        date: date,
        splits: splits,
      );
      _expenses = [expense, ..._expenses];
      notifyListeners();
      await refresh();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteExpense(int expenseId) async {
    final room = _room;
    if (room == null) return false;
    try {
      await api.deleteExpense(room.code, expenseId);
      _expenses = _expenses.where((e) => e.id != expenseId).toList();
      notifyListeners();
      await refresh();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setStatus(LoadStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }
}
