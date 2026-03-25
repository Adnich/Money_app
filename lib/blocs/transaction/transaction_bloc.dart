import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../models/transaction_model.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc()
      : super(const TransactionState(transactions: [], balance: 0.0)) {
    on<LoadTransactions>((event, emit) {
      final box = Hive.box<TransactionModel>('transactions');
      final list = box.values.toList();
      emit(TransactionState(
        transactions: list,
        balance: _calculateBalance(list),
      ));
    });

    on<AddTransaction>((event, emit) {
      final updated = [...state.transactions, event.transaction];
      emit(TransactionState(
        transactions: updated,
        balance: _calculateBalance(updated),
      ));
    });

    on<UpdateTransaction>((event, emit) async {
      final box = Hive.box<TransactionModel>('transactions');
      final list = [...state.transactions];
      final idx = list.indexWhere((t) => t.id == event.transaction.id);
      if (idx == -1) return;

     
      final key = box.keys.elementAt(idx);
      await box.put(key, event.transaction);

      list[idx] = event.transaction;
      emit(TransactionState(
        transactions: list,
        balance: _calculateBalance(list),
      ));
    });
  }

  double _calculateBalance(List<TransactionModel> txs) {
    double bal = 0;
    for (final t in txs) {
      if (t.type == TransactionType.topup || t.type == TransactionType.loan) {
        bal += t.amount;   
      } else {
        bal -= t.amount;   
      }
    }
    return bal;
  }
}
