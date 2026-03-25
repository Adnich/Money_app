import 'package:equatable/equatable.dart';
import '../../../../models/transaction_model.dart';

class TransactionState extends Equatable {
  final List<TransactionModel> transactions;
  final double balance;

  const TransactionState({
    required this.transactions,
    required this.balance,
  });

  factory TransactionState.initial() {
    return const TransactionState(transactions: [], balance: 0.0);
  }

  TransactionState copyWith({
    List<TransactionModel>? transactions,
    double? balance,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      balance: balance ?? this.balance,
    );
  }

  @override
  List<Object?> get props => [transactions, balance];
}
