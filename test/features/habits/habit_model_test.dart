import 'package:flutter_test/flutter_test.dart';
import 'package:warder_do_mobile/features/habits/data/models/habit_log_model.dart';
import 'package:warder_do_mobile/features/habits/data/models/habit_model.dart';
import 'package:warder_do_mobile/features/habits/domain/entities/habit.dart';
import 'package:warder_do_mobile/features/habits/domain/entities/repeat_rule.dart';

void main() {
  group('RepeatRuleMapper', () {
    test('daily', () {
      expect(RepeatRuleMapper.fromJson({'type': 'daily'}), const DailyRepeat());
    });

    test('weekly — 1=Dushanba, DateTime.weekday bilan bir xil', () {
      final rule =
          RepeatRuleMapper.fromJson({
                'type': 'weekly',
                'days': [1, 3, 5],
              })
              as WeeklyRepeat;

      expect(rule.days, [1, 3, 5]);
      // 2026-09-07 — dushanba.
      expect(
        rule.occursOn(DateTime(2026, 9, 7), startedAt: DateTime(2026, 1, 1)),
        isTrue,
      );
      // 2026-09-08 — seshanba, jadvalda yo'q.
      expect(
        rule.occursOn(DateTime(2026, 9, 8), startedAt: DateTime(2026, 1, 1)),
        isFalse,
      );
    });

    test('interval — sanoq yaratilgan kundan boshlanadi', () {
      final rule = RepeatRuleMapper.fromJson({
        'type': 'interval',
        'every_n_days': 2,
      });
      final start = DateTime(2026, 9, 1);

      expect(rule.occursOn(DateTime(2026, 9, 1), startedAt: start), isTrue);
      expect(rule.occursOn(DateTime(2026, 9, 2), startedAt: start), isFalse);
      expect(rule.occursOn(DateTime(2026, 9, 3), startedAt: start), isTrue);
      // Yaratilishidan oldingi kunlar hisobga olinmaydi.
      expect(rule.occursOn(DateTime(2026, 8, 30), startedAt: start), isFalse);
    });

    test('noma’lum tur — ilova qulamaydi, daily deb o‘qiladi', () {
      expect(RepeatRuleMapper.fromJson({'type': 'lunar'}), const DailyRepeat());
      expect(RepeatRuleMapper.fromJson(null), const DailyRepeat());
    });

    test('toJson backend formatiga mos', () {
      expect(RepeatRuleMapper.toJson(const DailyRepeat()), {'type': 'daily'});
      expect(RepeatRuleMapper.toJson(const WeeklyRepeat([2, 4])), {
        'type': 'weekly',
        'days': [2, 4],
      });
      expect(RepeatRuleMapper.toJson(const IntervalRepeat(3)), {
        'type': 'interval',
        'every_n_days': 3,
      });
    });
  });

  group('DailyHabitModel.fromJson', () {
    final json = {
      'id': 'h1',
      'group_id': null,
      'title': 'Suv ichish',
      'icon': 'water_drop',
      'color': '#4FC3F7',
      'type': 'good',
      'goal_value': 2.0,
      'goal_unit': 'liter',
      'goal_type': 'at_least',
      'repeat_rule': {'type': 'daily'},
      'reminders': [
        {'time': '08:00'},
        {'time': '20:30'},
      ],
      'order': 0,
      'is_archived': false,
      'created_at': '2026-09-01T05:20:12.128606Z',
      'date': '2026-09-03',
      'log': {
        'id': 'log-1',
        'habit_id': 'h1',
        'date': '2026-09-03',
        'value': 1.2,
        'duration_seconds': null,
        'completed': false,
      },
    };

    test('odat va kunlik log birga o‘qiladi', () {
      final item = DailyHabitModel.fromJson(json);

      expect(item.habit.title, 'Suv ichish');
      expect(item.habit.goalType, GoalType.atLeast);
      expect(item.habit.reminders.map((r) => r.json), ['08:00', '20:30']);
      expect(item.date, DateTime(2026, 9, 3));
      expect(item.log?.value, 1.2);
      expect(item.isCompleted, isFalse);
      expect(item.progress, closeTo(0.6, 0.0001));
      expect(item.progressLabel, '1,2/2 liter');
    });

    test('log null bo‘lsa — hali hech nima qilinmagan', () {
      final item = DailyHabitModel.fromJson({...json, 'log': null});

      expect(item.log, isNull);
      expect(item.isCompleted, isFalse);
      expect(item.currentValue, 0);
      expect(item.progress, 0);
    });
  });

  group('HabitModel JSON yozish', () {
    test('goal_value bo‘lmasa unit va type yuborilmaydi', () {
      final body = HabitModel.toCreateJson(
        Habit(
          id: '',
          title: 'Kitob',
          icon: 'book',
          color: '#E8C94F',
          type: HabitType.good,
          repeatRule: const DailyRepeat(),
          order: 0,
          isArchived: false,
          createdAt: DateTime(2026, 1, 1),
        ),
      );

      // Server `goal_value` siz kelgan `goal_unit` uchun 422 qaytaradi.
      expect(body.containsKey('goal_unit'), isFalse);
      expect(body.containsKey('goal_type'), isFalse);
      expect(body['goal_value'], isNull);
    });

    test('goal_type berilmasa at_least qo‘yiladi', () {
      final body = HabitModel.toCreateJson(
        Habit(
          id: '',
          title: 'Suv',
          icon: 'water_drop',
          color: '#4FA8E8',
          type: HabitType.good,
          repeatRule: const DailyRepeat(),
          order: 0,
          isArchived: false,
          createdAt: DateTime(2026, 1, 1),
          goalValue: 2,
          goalUnit: 'liter',
        ),
      );

      expect(body['goal_type'], 'at_least');
    });

    test('log body — sana YYYY-MM-DD, null maydonlar tushib qoladi', () {
      final body = HabitLogModel.toLogJson(
        date: DateTime(2026, 9, 3, 14, 30),
        value: 0.5,
      );

      expect(body['date'], '2026-09-03');
      expect(body['value'], 0.5);
      expect(body.containsKey('completed'), isFalse);
      expect(body.containsKey('duration_seconds'), isFalse);
    });

    test('reorder body — massiv, indeks bo‘yicha order', () {
      final body = HabitModel.toReorderJson(['a', 'b', 'c']);

      expect(body, [
        {'id': 'a', 'order': 0},
        {'id': 'b', 'order': 1},
        {'id': 'c', 'order': 2},
      ]);
    });
  });
}
