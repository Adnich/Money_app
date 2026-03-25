import 'package:equatable/equatable.dart';

abstract class LoanEvent extends Equatable {
  const LoanEvent();
  @override
  List<Object?> get props => [];
}

class ApplyForLoan extends LoanEvent {
  final double salary;
  final double expenses;
  final double amount;
  final int termMonths;

  const ApplyForLoan({
    required this.salary,
    required this.expenses,
    required this.amount,
    required this.termMonths,
  });

  @override
  List<Object?> get props => [salary, expenses, amount, termMonths];
}
