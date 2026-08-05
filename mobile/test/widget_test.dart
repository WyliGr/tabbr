import 'package:flutter_test/flutter_test.dart';

import 'package:tabbr/models/balance.dart';
import 'package:tabbr/models/expense.dart';
import 'package:tabbr/models/member.dart';
import 'package:tabbr/models/room.dart';

void main() {
  test('Room parses JSON', () {
    final room = Room.fromJson({
      'id': 1,
      'code': 'ABCDE',
      'name': 'Trip',
      'created_at': '2024-01-01T00:00:00',
    });
    expect(room.code, 'ABCDE');
    expect(room.name, 'Trip');
  });

  test('Member parses JSON', () {
    final m = Member.fromJson({
      'id': 2,
      'room_id': 1,
      'name': 'Alice',
      'created_at': '2024-01-01T00:00:00',
    });
    expect(m.name, 'Alice');
  });

  test('Expense parses JSON with splits', () {
    final e = Expense.fromJson({
      'id': 3,
      'amount': 25.5,
      'description': 'Dinner',
      'payer_id': 1,
      'payer_name': 'Bob',
      'date': '2024-01-02T00:00:00',
      'created_at': '2024-01-02T00:00:00',
      'splits': [
        {'member_id': 1, 'share': 12.75},
        {'member_id': 2, 'share': 12.75},
      ],
    });
    expect(e.amount, 25.5);
    expect(e.splits.length, 2);
  });

  test('Balance parses JSON', () {
    final b = Balance.fromJson({
      'balances': [
        {
          'from_person': 1,
          'from_person_name': 'Alice',
          'to_person': 2,
          'to_person_name': 'Bob',
          'amount': 10.0,
        }
      ],
    });
    expect(b.entries.first.amount, 10.0);
  });
}
