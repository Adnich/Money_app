import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/loan/loan_bloc.dart';
import '../blocs/loan/loan_event.dart';
import '../blocs/loan/loan_state.dart';

class LoanScreen extends StatefulWidget {
  const LoanScreen({super.key});

  @override
  State<LoanScreen> createState() => _LoanScreenState();
}

class _LoanScreenState extends State<LoanScreen> {
  final salaryController = TextEditingController();
  final expensesController = TextEditingController();
  final amountController = TextEditingController();
  final termController = TextEditingController();

  bool acceptedTerms = false;

  @override
  void dispose() {
    salaryController.dispose();
    expensesController.dispose();
    amountController.dispose();
    termController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoanBloc, LoanState>(
      listener: (context, state) {
        if (state is LoanApproved) {
          _showDialog(state.message);
        } else if (state is LoanDeclined) {
          _showDialog(state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Loan Application'),
          backgroundColor: const Color(0xFFE10098),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildField("Monthly Salary", salaryController),
              _buildField("Monthly Expenses", expensesController),
              _buildField("Loan Amount", amountController),
              _buildField("Loan Term (months)", termController),
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: acceptedTerms,
                    onChanged: (val) => setState(() => acceptedTerms = val ?? false),
                  ),
                  const Expanded(child: Text("I accept the Terms & Conditions")),
                ],
              ),
              const SizedBox(height: 20),
              BlocBuilder<LoanBloc, LoanState>(
                builder: (context, state) {
                  final isLoading = state is LoanLoading;
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE10098),
                    ),
                    onPressed: (!acceptedTerms || isLoading) ? null : () {
                      final salary = double.tryParse(salaryController.text) ?? 0;
                      final expenses = double.tryParse(expensesController.text) ?? 0;
                      final amount = double.tryParse(amountController.text) ?? 0;
                      final term = int.tryParse(termController.text) ?? 1;

                      context.read<LoanBloc>().add(
                        ApplyForLoan(
                          salary: salary,
                          expenses: expenses,
                          amount: amount,
                          termMonths: term,
                        ),
                      );
                    },
                    child: Text(isLoading ? 'Applying...' : 'Apply for loan'),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  void _showDialog(String text) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(text),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }
}
