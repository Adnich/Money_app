import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/transaction_model.dart';
import '../blocs/transaction/transaction_bloc.dart';
import '../blocs/transaction/transaction_event.dart';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  String _input = "";

  void _append(String value) {
    setState(() {
      if (value == '.' && _input.contains('.')) return;
      if (_input == "0" && value != '.') {
        _input = value;
      } else {
        _input += value;
      }
    });
  }

  void _backspace() {
    setState(() {
      if (_input.isNotEmpty) {
        _input = _input.substring(0, _input.length - 1);
      }
    });
  }

  double get _amount {
    final parsed = double.tryParse(_input);
    if (parsed == null) return 0;
    return parsed;
  }

  String _formatInput(String input) {
    try {
      final parsed = double.parse(input);
      return parsed.toStringAsFixed(2);
    } catch (_) {
      return input;
    }
  }

  Widget _buildKey(String value, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () => _append(value),
      child: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Text(
          value,
          style: const TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }

  void _submit() async {
    final box = Hive.box<TransactionModel>('transactions');

    final newTransaction = TransactionModel(
      id: const Uuid().v4(),
      name: 'Top Up',
      amount: _amount,
      type: TransactionType.topup,
      createdAt: DateTime.now(),
    );

    await box.add(newTransaction);

    if (!mounted) return;
    context.read<TransactionBloc>().add(AddTransaction(newTransaction));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE10098),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE10098),
        elevation: 0,
        centerTitle: true,
        title: const Text('MoneyApp', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          const Text(
            'How much?',
            style: TextStyle(color: Colors.white, fontSize: 22),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.center,
            child: Text(
              _input.isEmpty
                  ? '£0.00'
                  : '£${_input.endsWith('.') ? _input : _formatInput(_input)}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ...['1', '2', '3', '4', '5', '6', '7', '8', '9']
                      .map((e) => _buildKey(e)),
                  _buildKey('.', onTap: () => _append('.')),
                  _buildKey('0'),
                  _buildKey('⌫', onTap: _backspace),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: ElevatedButton(
              onPressed: _amount > 0 ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
              ),
              child: const Text(
                "Next",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
