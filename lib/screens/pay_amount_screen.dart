import 'package:flutter/material.dart';
import 'pay_who_screen.dart';

class PayAmountScreen extends StatefulWidget {
  const PayAmountScreen({super.key});

  @override
  State<PayAmountScreen> createState() => _PayAmountScreenState();
}

class _PayAmountScreenState extends State<PayAmountScreen> {
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

  void _goNext() {
    final amount = double.tryParse(_input);
    if (amount != null && amount > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PayWhoScreen(amount: amount),
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE10098),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              'MoneyApp',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              "How much?",
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
                onPressed: _goNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                ),
                child: const Text(
                  "Next",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatInput(String input) {
    try {
      final parsed = double.parse(input);
      return parsed.toStringAsFixed(2);
    } catch (_) {
      return input;
    }
  }
}
