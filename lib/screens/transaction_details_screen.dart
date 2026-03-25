import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';

import '../models/transaction_model.dart';
import '../blocs/transaction/transaction_bloc.dart';
import '../blocs/transaction/transaction_event.dart';

class TransactionDetailsScreen extends StatefulWidget {
  const TransactionDetailsScreen({Key? key, required this.transaction})
      : super(key: key);

  final TransactionModel transaction;

  @override
  State<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  bool _repeatSwitch = false;

  String _formattedDate(DateTime dt) {
    final s = DateFormat('dd MMMM yyyy hh:mm a').format(dt);
    return s.toUpperCase();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _splitBill() async {
    final tx = widget.transaction;
    if (tx.type != TransactionType.payment) return;

    final half = (tx.amount / 2).abs();

    final box = Hive.box<TransactionModel>('transactions');
    final list = box.values.toList();
    final idx = list.indexWhere((t) => t.id == tx.id);
    if (idx == -1) {
      _showSnack('Could not find transaction to update.');
      return;
    }
    final key = box.keys.elementAt(idx);
    final updatedPayment = tx.copyWith(amount: half);
    await box.put(key, updatedPayment);

    final topup = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Top Up',
      amount: half,
      type: TransactionType.topup,
      createdAt: DateTime.now(),
    );
    await box.add(topup);

    if (!mounted) return;
    final bloc = context.read<TransactionBloc>();
    bloc.add(UpdateTransaction(updatedPayment));
    bloc.add(AddTransaction(topup));

    _showSnack('Bill split in half and Top Up added.');
  }

  Future<void> _toggleRepeat(bool value) async {
    setState(() => _repeatSwitch = value);
    if (!value) return;

    final tx = widget.transaction;
    if (tx.type != TransactionType.payment) return;

    final repeated = tx.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
    );

    final box = Hive.box<TransactionModel>('transactions');
    await box.add(repeated);

    if (!mounted) return;
    context.read<TransactionBloc>().add(AddTransaction(repeated));

    _showSnack('Repeating payment added.');
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Help is on the way'),
        content: const Text('Help is on the way, stay put!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tx = widget.transaction;
    final isPayment = tx.type == TransactionType.payment;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE10098),
        elevation: 0,
        title: const Text('MoneyApp'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE10098),
                        borderRadius: BorderRadius.circular(8),
                        
                      ),
                      child: const Icon(
                        Icons.shopping_bag,
                        color: Colors.white,
                        size: 45,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tx.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formattedDate(tx.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  tx.amount.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),

          const _DividerGap(),

          _PlainTile(
            leadingIcon: Icons.receipt_long,
            title: 'Add receipt',
            onTap: () {},
          ),

          const _SectionHeader('SHARE THE COST'),
          if (isPayment)
            _PlainTile(
              leadingIcon: Icons.call_split,
              title: 'Split this bill',
              onTap: _splitBill,
            )
          else
            const _PlainTile(
              leadingIcon: Icons.call_split,
              title: 'Split this bill',
              disabled: true,
            ),

          const _SectionHeader('SUBSCRIPTION'),
          if (isPayment)
            _SwitchTile(
              title: 'Repeating payment',
              value: _repeatSwitch,
              onChanged: _toggleRepeat,
            )
          else
            const _SwitchTile(
              title: 'Repeating payment',
              value: false,
              onChanged: null,
            ),

          const SizedBox(height: 55),
          GestureDetector(
            onTap: _showHelpDialog,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: const Text(
                'Something wrong? Get help',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
            child: Center(
              child: Text(
                'Transaction ID ${tx.id}\n${tx.name} • Merchant ID #XXXX',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.grey,
        ),
      ),
    );
  }
}

class _PlainTile extends StatelessWidget {
  const _PlainTile({
    required this.leadingIcon,
    required this.title,
    this.onTap,
    this.disabled = false,
  });

  final IconData leadingIcon;
  final String title;
  final VoidCallback? onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final color = disabled ? Colors.grey : const Color(0xFFE10098);
    return InkWell(
      onTap: disabled ? null : onTap,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(leadingIcon, color: color),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: disabled ? Colors.grey : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _DividerGap extends StatelessWidget {
  const _DividerGap();

  @override
  Widget build(BuildContext context) {
    return Container(height: 8, color: Colors.grey.shade100);
  }
}
