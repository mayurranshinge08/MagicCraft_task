import 'package:flutter/material.dart';

import '../core/models/wallet_model.dart';
import '../core/theme/app_theme.dart';

class TransactionItem extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkPurple.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.arcanePurple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Transaction Type Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  transaction.isIncoming
                      ? Colors.green.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
            ),
            child: Icon(
              transaction.isIncoming ? Icons.call_received : Icons.call_made,
              color: transaction.isIncoming ? Colors.green : Colors.orange,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          // Transaction Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transaction Type and Status
                Row(
                  children: [
                    Text(
                      transaction.isIncoming ? 'Received' : 'Sent',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        transaction.status,
                        style: TextStyle(
                          color: _getStatusColor(),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Address and Hash
                Text(
                  '${transaction.isIncoming ? 'From' : 'To'}: ${transaction.shortAddress}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white60,
                    fontFamily: 'monospace',
                  ),
                ),

                const SizedBox(height: 2),

                // Transaction Hash
                Text(
                  'Hash: ${transaction.shortHash}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white38,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),

          // Amount and Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Amount
              Text(
                '${transaction.isIncoming ? '+' : '-'}${transaction.formattedValue} ${transaction.symbol}',
                style: TextStyle(
                  color: transaction.isIncoming ? Colors.green : Colors.orange,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              // Time
              Text(
                _formatTime(transaction.timestamp),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.white60),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (transaction.status.toLowerCase()) {
      case 'confirmed':
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
