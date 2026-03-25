import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
enum TransactionType {
  @HiveField(0)
  topup,
  @HiveField(1)
  payment,
  @HiveField(2)
  loan,
}

@HiveType(typeId: 3)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final TransactionType type;

  @HiveField(4)
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.createdAt,
  });

    TransactionModel copyWith({
    String? id,
    String? name,
    double? amount,
    TransactionType? type,
    DateTime? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
