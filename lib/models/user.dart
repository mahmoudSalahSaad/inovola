import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'user.g.dart';

@HiveType(typeId: 2)
class User extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? profileImagePath;

  @HiveField(4)
  final String baseCurrency;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImagePath,
    this.baseCurrency = 'USD',
    required this.createdAt,
    required this.updatedAt,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImagePath,
    String? baseCurrency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        profileImagePath,
        baseCurrency,
        createdAt,
        updatedAt,
      ];
}

enum FilterPeriod {
  thisMonth,
  lastSevenDays,
  lastThirtyDays,
  thisYear,
  all;

  String get displayName {
    switch (this) {
      case FilterPeriod.thisMonth:
        return 'This month';
      case FilterPeriod.lastSevenDays:
        return 'Last 7 days';
      case FilterPeriod.lastThirtyDays:
        return 'Last 30 days';
      case FilterPeriod.thisYear:
        return 'This year';
      case FilterPeriod.all:
        return 'All time';
    }
  }

  DateRange get dateRange {
    final now = DateTime.now();
    switch (this) {
      case FilterPeriod.thisMonth:
        return DateRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0),
        );
      case FilterPeriod.lastSevenDays:
        return DateRange(
          start: now.subtract(const Duration(days: 7)),
          end: now,
        );
      case FilterPeriod.lastThirtyDays:
        return DateRange(
          start: now.subtract(const Duration(days: 30)),
          end: now,
        );
      case FilterPeriod.thisYear:
        return DateRange(
          start: DateTime(now.year, 1, 1),
          end: DateTime(now.year, 12, 31),
        );
      case FilterPeriod.all:
        return DateRange(
          start: DateTime(2000, 1, 1),
          end: DateTime(2099, 12, 31),
        );
    }
  }
}

class DateRange extends Equatable {
  final DateTime start;
  final DateTime end;

  const DateRange({
    required this.start,
    required this.end,
  });

  @override
  List<Object?> get props => [start, end];
}
