import 'package:equatable/equatable.dart';

abstract class LoanState extends Equatable {
  const LoanState();
  @override
  List<Object?> get props => [];
}

class LoanInitial extends LoanState {}

class LoanLoading extends LoanState {}

class LoanApproved extends LoanState {
  final String message;
  const LoanApproved(this.message);
  @override
  List<Object?> get props => [message];
}

class LoanDeclined extends LoanState {
  final String code;     
  final String message;  
  const LoanDeclined(this.code, this.message);
  @override
  List<Object?> get props => [code, message];
}
