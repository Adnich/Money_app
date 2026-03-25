import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocs/transaction/transaction_bloc.dart';
import '../blocs/transaction/transaction_state.dart';
import '../models/transaction_model.dart';
import 'pay_amount_screen.dart';
import 'topup_screen.dart';
import 'loan_screen.dart';
import 'transaction_details_screen.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  String _groupTitle(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'TODAY';
    if (d == yesterday) return 'YESTERDAY';
    return DateFormat('d MMMM').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), 
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          final Map<String, List<TransactionModel>> grouped = {};
          for (final tx in state.transactions) {
            final key = _groupTitle(tx.createdAt);
            grouped.putIfAbsent(key, () => []).add(tx);
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 250,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 270,
                        width: double.infinity,
                        color: const Color(0xFFE10098),
                        padding: const EdgeInsets.only(top: 40),
                        child: Column(
                          children: [
                            const Text(
                              'MoneyApp',
                              style: TextStyle(
                                color: Colors.white,
                                
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 34),
                            _Balance(amount: state.balance),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Transform.translate(
                          offset: const Offset(0, 120),
                          child: Card(
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            margin: const EdgeInsets.symmetric(horizontal: 25, vertical:80),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 3,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _Action(
                                    icon: Icons.mobile_screen_share,
                                    label: 'Pay',
                                    iconColor: Colors.pink,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const PayAmountScreen(),
                                      ),
                                    ),
                                  ),
                                  _Action(
                                    icon: Icons.account_balance_wallet,
                                    label: 'Top up',
                                    iconColor: Colors.purple,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const TopUpScreen(),
                                      ),
                                    ),
                                  ),
                                  _Action(
                                    icon: Icons.money_outlined,
                                    label: 'Loan',
                                    iconColor: Colors.black,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const LoanScreen(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 56)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade900,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverList(
                delegate: SliverChildListDelegate(
                  grouped.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          color: Colors.grey.shade200,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        ...entry.value.map((tx) {
                          final isTopUp = tx.type == TransactionType.topup;
                          final isLoan = tx.type == TransactionType.loan;
                          final sign = isTopUp || isLoan ? '+' : '';
                          final trailingColor =
                              isTopUp || isLoan ? Colors.pink : Colors.black87;
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.pink.shade50,
                              child: Icon(
                                isTopUp || isLoan
                                    ? Icons.add_circle_outline
                                    : Icons.shopping_bag_outlined,
                                color: Colors.pink,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              isTopUp && tx.name.trim().isEmpty
                                  ? 'Top Up'
                                  : tx.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            trailing: Text(
                              '$sign${NumberFormat.currency(
                                symbol: '£',
                                decimalDigits: 2,
                              ).format(tx.amount)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: trailingColor,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TransactionDetailsScreen(
                                    transaction: tx,
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }
}
class _Balance extends StatelessWidget {
  const _Balance({required this.amount});
  final double amount;

  @override
  Widget build(BuildContext context) {
    final parts = NumberFormat.currency(symbol: '£', decimalDigits: 2)
        .format(amount)
        .replaceAll(',', '')
        .split('.');
    final whole = parts[0].replaceFirst('£', '');
    final dec = parts.length > 1 ? parts[1] : '00';

    return RichText(
      text: TextSpan(
        children: [
          const TextSpan(
            text: '£',
            style: TextStyle(fontSize: 22, color: Colors.white),
          ),
          TextSpan(
            text: whole,
            style: const TextStyle(
              fontSize: 44,
              height: 1.1,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          TextSpan(
            text: '.$dec',
            style: const TextStyle(
              fontSize: 20,
              height: 2.2,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: IconButton(
            icon: Icon(icon, color: iconColor),
            onPressed: onTap,
            iconSize: 28,
            splashRadius: 26,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ],
    );
  }
}
