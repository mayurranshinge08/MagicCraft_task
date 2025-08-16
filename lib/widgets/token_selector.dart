import 'package:flutter/material.dart';

import '../core/models/wallet_model.dart';
import '../core/theme/app_theme.dart';

class TokenSelector extends StatelessWidget {
  final List<TokenBalance> tokens;
  final String? selectedToken;
  final Function(String) onTokenSelected;

  const TokenSelector({
    super.key,
    required this.tokens,
    required this.selectedToken,
    required this.onTokenSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.darkPurple.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.arcanePurple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children:
            tokens.map((token) {
              final isSelected = token.symbol == selectedToken;

              return GestureDetector(
                onTap: () => onTokenSelected(token.symbol),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    gradient:
                        isSelected
                            ? (token.symbol == 'MCRT'
                                ? AppTheme.goldGradient
                                : AppTheme.magicGradient)
                            : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // Token Icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              isSelected
                                  ? (token.symbol == 'MCRT'
                                      ? AppTheme.midnightBlue.withOpacity(0.2)
                                      : AppTheme.shimmeringGold.withOpacity(
                                        0.2,
                                      ))
                                  : AppTheme.arcanePurple.withOpacity(0.3),
                        ),
                        child: Center(
                          child: Text(
                            token.symbol.substring(0, 1),
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? (token.symbol == 'MCRT'
                                          ? AppTheme.midnightBlue
                                          : AppTheme.shimmeringGold)
                                      : Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Token Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              token.name,
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? (token.symbol == 'MCRT'
                                            ? AppTheme.midnightBlue
                                            : Colors.white)
                                        : Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              token.symbol,
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? (token.symbol == 'MCRT'
                                            ? AppTheme.midnightBlue.withOpacity(
                                              0.7,
                                            )
                                            : Colors.white70)
                                        : Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Balance
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            token.formattedBalance,
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? (token.symbol == 'MCRT'
                                          ? AppTheme.midnightBlue
                                          : Colors.white)
                                      : Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            token.formattedUsdValue,
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? (token.symbol == 'MCRT'
                                          ? AppTheme.midnightBlue.withOpacity(
                                            0.7,
                                          )
                                          : Colors.white70)
                                      : Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      // Selection Indicator
                      const SizedBox(width: 12),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color:
                              token.symbol == 'MCRT'
                                  ? AppTheme.midnightBlue
                                  : AppTheme.shimmeringGold,
                          size: 20,
                        )
                      else
                        Icon(
                          Icons.radio_button_unchecked,
                          color: Colors.white38,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
