import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';

class NetworkSelector extends StatelessWidget {
  final String currentNetwork;
  final Function(String) onNetworkChanged;

  const NetworkSelector({
    super.key,
    required this.currentNetwork,
    required this.onNetworkChanged,
  });

  @override
  Widget build(BuildContext context) {
    final networkConfig = AppConstants.supportedNetworks[currentNetwork]!;

    return GestureDetector(
      onTap: () => _showNetworkSelector(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.darkPurple.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.arcanePurple.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Network Icon
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getNetworkColor(currentNetwork),
              ),
              child: Center(
                child: Text(
                  _getNetworkInitial(currentNetwork),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Network Name
            Text(
              _getShortNetworkName(networkConfig.name),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),

            // Dropdown Arrow
            const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showNetworkSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.magicGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.white38,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Title
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Select Network',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Network List
                ...AppConstants.supportedNetworks.entries.map((entry) {
                  final networkId = entry.key;
                  final config = entry.value;
                  final isSelected = networkId == currentNetwork;

                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getNetworkColor(networkId),
                      ),
                      child: Center(
                        child: Text(
                          _getNetworkInitial(networkId),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      config.name,
                      style: TextStyle(
                        color:
                            isSelected ? AppTheme.shimmeringGold : Colors.white,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      config.nativeCurrency.symbol,
                      style: TextStyle(
                        color:
                            isSelected
                                ? AppTheme.shimmeringGold.withOpacity(0.7)
                                : Colors.white60,
                      ),
                    ),
                    trailing:
                        isSelected
                            ? const Icon(
                              Icons.check_circle,
                              color: AppTheme.shimmeringGold,
                            )
                            : null,
                    onTap: () {
                      Navigator.pop(context);
                      if (!isSelected) {
                        onNetworkChanged(networkId);
                      }
                    },
                  );
                }),

                const SizedBox(height: 24),
              ],
            ),
          ),
    );
  }

  Color _getNetworkColor(String networkId) {
    switch (networkId) {
      case 'ethereum':
        return const Color(0xFF627EEA);
      case 'bsc':
        return const Color(0xFFF3BA2F);
      case 'polygon':
        return const Color(0xFF8247E5);
      default:
        return AppTheme.arcanePurple;
    }
  }

  String _getNetworkInitial(String networkId) {
    switch (networkId) {
      case 'ethereum':
        return 'E';
      case 'bsc':
        return 'B';
      case 'polygon':
        return 'P';
      default:
        return 'N';
    }
  }

  String _getShortNetworkName(String fullName) {
    switch (fullName) {
      case 'Binance Smart Chain':
        return 'BSC';
      default:
        return fullName;
    }
  }
}
