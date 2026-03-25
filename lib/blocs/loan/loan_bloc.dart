import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import 'loan_event.dart';
import 'loan_state.dart';
import '../../models/loan_decision_model.dart';
import '../../models/transaction_model.dart';
import '../../services/loan_decision_service.dart';
import '../transaction/transaction_bloc.dart';
import '../transaction/transaction_event.dart';
import '../transaction/transaction_state.dart';

class LoanBloc extends Bloc<LoanEvent, LoanState> {
  final TransactionBloc transactionBloc;
  final LoanDecisionService service;
  final Box<LoanDecisionModel> loanBox;
  final Box<TransactionModel> txBox;

  StreamSubscription<TransactionState>? _txSub;

  LoanBloc({
    required this.transactionBloc,
    required this.service,
    required this.loanBox,
    required this.txBox,
  }) : super(LoanInitial()) {
    on<ApplyForLoan>(_onApplyForLoan);
  }

  Future<void> _onApplyForLoan(
    ApplyForLoan event,
    Emitter<LoanState> emit,
  ) async {
    
    await _txSub?.cancel();
    _txSub = null;

    emit(LoanLoading());

   
    final existing = loanBox.get('decision');
    if (existing != null && existing.approved == true) {
      emit(const LoanDeclined(
        'ALREADY_APPROVED',
        'You already have an approved loan.',
      ));
      return;
    }

    final accountBalance = _computeBalance();
    final decisionCode = await _safeDecide(
      balance: accountBalance,
      salary: event.salary,
      expenses: event.expenses,
      amount: event.amount,
      term: event.termMonths,
      emit: emit,
    );

    if (decisionCode == null) return; 

    if (decisionCode == 'APPROVED') {
      await _approveAndCredit(event.amount, emit);
      return;
    }


    final declinedMsg = _declineMessage(decisionCode);
    await loanBox.put(
      'decision',
      LoanDecisionModel(approved: false, message: declinedMsg),
    );
    emit(LoanDeclined(decisionCode, declinedMsg));

   
   if (decisionCode == 'DECLINED_RULE_1' || decisionCode == 'DECLINED_RULE_2') {
      _startRetryOnNewTransactions(event, emit);
    }
  }

  
  void _startRetryOnNewTransactions(
    ApplyForLoan event,
    Emitter<LoanState> emit,
  ) {
   
    _txSub?.cancel();
    _txSub = transactionBloc.stream.listen((state) async {
      final balance = _computeBalance();
      try {
        final code = await service.decideLoan(
          accountBalance: balance,
          monthlySalary: event.salary,
          monthlyExpenses: event.expenses,
          loanAmount: event.amount,
          loanTerm: event.termMonths,
        );

        if (code == 'APPROVED') {
          await _approveAndCredit(event.amount, emit);
          await _txSub?.cancel();
          _txSub = null;
        }
      } catch (_) {
      
      }
    });
  }

  Future<String?> _safeDecide({
    required double balance,
    required double salary,
    required double expenses,
    required double amount,
    required int term,
    required Emitter<LoanState> emit,
  }) async {
    try {
      final code = await service.decideLoan(
        accountBalance: balance,
        monthlySalary: salary,
        monthlyExpenses: expenses,
        loanAmount: amount,
        loanTerm: term,
      );
      return code;
    } catch (e, st) {
      print('LoanDecisionService error: $e');
      print(st);

      emit(const LoanDeclined('API_ERROR', 'Error fetching loan decision.'));
      return null;
    }
  }

  Future<void> _approveAndCredit(double amount, Emitter<LoanState> emit) async {
    const msg =
        "Yeeeyyy !! Congrats. Your application has been approved. Don’t tell your friends you have money!";
    await loanBox.put('decision', LoanDecisionModel(approved: true, message: msg));

    final tx = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Loan',
      amount: amount,
      type: TransactionType.loan, 
      createdAt: DateTime.now(),
    );
    await txBox.add(tx);
    transactionBloc.add(AddTransaction(tx));

    emit(const LoanApproved(
        "Yeeeyyy !! Congrats. Your application has been approved. Don’t tell your friends you have money!"));
  }

  double _computeBalance() {
    double bal = 0;
    for (final t in txBox.values) {
      if (t.type == TransactionType.topup || t.type == TransactionType.loan) {
        bal += t.amount;
      } else {
        bal -= t.amount;
      }
    }
    return bal;
  }

  String _declineMessage(String code) {
    switch (code) {
      case 'DECLINED_RULE_1':
        return "Application declined due to system check. We'll try again when the situation changes.";
      case 'DECLINED_RULE_2':
        return "You don’t have enough money in your account. We'll try again after your next top-up.";
      case 'DECLINED_RULE_3':
        return "Sorry. Your monthly salary is too low to qualify for a loan.";
      case 'DECLINED_RULE_4':
        return "Your expenses are too high compared to your salary. Try to reduce them and reapply.";
      case 'DECLINED_RULE_5':
        return "Requested loan is too expensive based on your income. Please adjust the amount or term.";
      default:
        return "Ooopsss. Your application has been declined. It’s not your fault, it’s a financial crisis.";
    }
  }

  @override
  Future<void> close() async {
    await _txSub?.cancel();
    return super.close();
  }
}
