import 'package:flutter/material.dart';

/// "You Will Get" summary card displayed inside the gradient header on the
/// customer detail screen.
///
/// [balance] is the net outstanding amount (positive = owed to vendor, zero or
/// negative = customer is settled / has credit).
/// [totalGave] and [totalGot] are cumulative totals shown on the right side.
class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.balance,
    required this.totalGave,
    required this.totalGot,
  });

  final int balance;
  final int totalGave;
  final int totalGot;

  @override
  Widget build(BuildContext context) {
    final settled = balance <= 0;
    final amountColor = settled
        ? const Color(0xFF6EE7B7) // soft green when settled
        : const Color(0xFFFBBF24); // amber when outstanding

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'You Will Get',
                style: TextStyle(
                  color: Color(0xFFB0C6FF),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '₹${balance.abs()}',
                style: TextStyle(
                  color: amountColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 12, color: Color(0xFFB0C6FF)),
                  children: [
                    const TextSpan(text: 'Gave: '),
                    TextSpan(
                      text: '₹$totalGave',
                      style: const TextStyle(color: Color(0xFFFCA5A5)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 12, color: Color(0xFFB0C6FF)),
                  children: [
                    const TextSpan(text: 'Got: '),
                    TextSpan(
                      text: '₹$totalGot',
                      style: const TextStyle(color: Color(0xFF6EE7B7)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
