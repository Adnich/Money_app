import 'package:hive/hive.dart';

part 'loan_decision_model.g.dart';

@HiveType(typeId: 2) 
class LoanDecisionModel extends HiveObject {
  @HiveField(0)
  final bool approved;

  @HiveField(1)
  final String message;

  LoanDecisionModel({
    required this.approved,
    required this.message,
  });
}
