import 'package:flutter/material.dart';

import '../core/models/wallet_model.dart';
import '../core/theme/app_theme.dart';

class BalanceCard extends StatelessWidget {
  final TokenBalance balance;

  const BalanceCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient:
            balance.symbol == 'MCRT'
                ? AppTheme.goldGradient
                : LinearGradient(
                  colors: [
                    AppTheme.arcanePurple.withOpacity(0.8),
                    AppTheme.darkPurple.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              balance.symbol == 'MCRT'
                  ? AppTheme.shimmeringGold.withOpacity(0.5)
                  : AppTheme.arcanePurple.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (balance.symbol == 'MCRT'
                    ? AppTheme.shimmeringGold
                    : AppTheme.arcanePurple)
                .withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Token Info Row
          Row(
            children: [
              // Token Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      balance.symbol == 'MCRT'
                          ? AppTheme.midnightBlue.withOpacity(0.2)
                          : AppTheme.shimmeringGold.withOpacity(0.2),
                ),
                child: Center(
                  child: Text(
                    balance.symbol.substring(0, 1),
                    style: TextStyle(
                      color:
                          balance.symbol == 'MCRT'
                              ? AppTheme.midnightBlue
                              : AppTheme.shimmeringGold,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Token Name and Symbol
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      balance.name,
                      style: TextStyle(
                        color:
                            balance.symbol == 'MCRT'
                                ? AppTheme.midnightBlue
                                : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      balance.symbol,
                      style: TextStyle(
                        color:
                            balance.symbol == 'MCRT'
                                ? AppTheme.midnightBlue.withOpacity(0.7)
                                : Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // More Options
              IconButton(
                onPressed: () {
                  // TODO: Show token options (send, receive, etc.)
                },
                icon: Icon(
                  Icons.more_vert,
                  color:
                      balance.symbol == 'MCRT'
                          ? AppTheme.midnightBlue.withOpacity(0.7)
                          : Colors.white70,
                  size: 20,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Balance Amount
          Text(
            balance.formattedBalance,
            style: TextStyle(
              color:
                  balance.symbol == 'MCRT'
                      ? AppTheme.midnightBlue
                      : Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 4),

          // USD Value
          Text(
            balance.formattedUsdValue,
            style: TextStyle(
              color:
                  balance.symbol == 'MCRT'
                      ? AppTheme.midnightBlue.withOpacity(0.7)
                      : Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
