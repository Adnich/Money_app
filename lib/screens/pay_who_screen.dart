import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/transaction_model.dart';
import '../blocs/transaction/transaction_bloc.dart';
import '../blocs/transaction/transaction_event.dart';

class PayWhoScreen extends StatefulWidget {
  final double amount;

  const PayWhoScreen({Key? key, required this.amount}) : super(key: key);

  @override
  State<PayWhoScreen> createState() => _PayWhoScreenState();
}

class _PayWhoScreenState extends State<PayWhoScreen> {
  final TextEditingController _nameController = TextEditingController();

  void _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final newTransaction = TransactionModel(
      id: const Uuid().v4(),
      name: name,
      amount: widget.amount,
      type: TransactionType.payment,
      createdAt: DateTime.now(),
    );

    final box = Hive.box<TransactionModel>('transactions');
    await box.add(newTransaction);

    if (!mounted) return;
    context.read<TransactionBloc>().add(AddTransaction(newTransaction));

    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE10098),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 80),
            const Center(
              child: Text(
                'To whom?',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: 'Enter name',
                  hintStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                cursorColor: Colors.white,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Center(
                child: TextButton(
                  onPressed: _submit,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.white.withOpacity(0.3),
                  ),
                  child: const Text(
                    'Pay',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
