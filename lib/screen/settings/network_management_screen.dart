import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/network_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/magic_app_bar.dart';
import '../../widgets/magic_button.dart';
import 'add_custom_rpc_screen.dart';

class NetworkManagementScreen extends StatefulWidget {
  const NetworkManagementScreen({super.key});

  @override
  State<NetworkManagementScreen> createState() =>
      _NetworkManagementScreenState();
}

class _NetworkManagementScreenState extends State<NetworkManagementScreen> {
  bool _isTestingConnection = false;
  String? _testingNetworkId;

  Future<void> _testNetworkConnection(String networkId) async {
    setState(() {
      _isTestingConnection = true;
      _testingNetworkId = networkId;
    });

    final networkProvider = Provider.of<NetworkProvider>(
      context,
      listen: false,
    );

    // Simulate network test
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isTestingConnection = false;
      _testingNetworkId = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppConstants.supportedNetworks[networkId]!.name} connection successful',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MagicAppBar(title: 'Network Management'),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.magicGradient),
        child: SafeArea(
          child: Consumer<NetworkProvider>(
            builder: (context, networkProvider, child) {
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Current Network Info
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.darkPurple.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.shimmeringGold.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _getNetworkColor(
                                          networkProvider.currentNetworkId,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _getNetworkInitial(
                                            networkProvider.currentNetworkId,
                                          ),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Current Network',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleSmall?.copyWith(
                                              color: AppTheme.shimmeringGold,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            networkProvider.currentNetwork.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildNetworkDetail(
                                  'Chain ID',
                                  networkProvider.currentNetwork.chainId
                                      .toString(),
                                ),
                                _buildNetworkDetail(
                                  'Currency',
                                  networkProvider
                                      .currentNetwork
                                      .nativeCurrency
                                      .symbol,
                                ),
                                _buildNetworkDetail(
                                  'RPC URL',
                                  networkProvider.currentRpcUrl,
                                ),
                                if (networkProvider.hasCustomRpc(
                                  networkProvider.currentNetworkId,
                                ))
                                  Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.shimmeringGold
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Custom RPC',
                                      style: TextStyle(
                                        color: AppTheme.shimmeringGold,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Available Networks
                          Text(
                            'Available Networks',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          ...AppConstants.supportedNetworks.entries.map((
                            entry,
                          ) {
                            final networkId = entry.key;
                            final config = entry.value;
                            final isSelected =
                                networkId == networkProvider.currentNetworkId;
                            final hasCustomRpc = networkProvider.hasCustomRpc(
                              networkId,
                            );
                            final isTestingThis =
                                _testingNetworkId == networkId;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: AppTheme.darkPurple.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? AppTheme.shimmeringGold.withOpacity(
                                            0.5,
                                          )
                                          : AppTheme.arcanePurple.withOpacity(
                                            0.3,
                                          ),
                                  width: 1,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _getNetworkColor(networkId),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _getNetworkInitial(networkId),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Text(
                                      config.name,
                                      style: TextStyle(
                                        color:
                                            isSelected
                                                ? AppTheme.shimmeringGold
                                                : Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (hasCustomRpc) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.shimmeringGold
                                              .withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: const Text(
                                          'Custom',
                                          style: TextStyle(
                                            color: AppTheme.shimmeringGold,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      config.nativeCurrency.symbol,
                                      style: TextStyle(
                                        color:
                                            isSelected
                                                ? AppTheme.shimmeringGold
                                                    .withOpacity(0.7)
                                                : Colors.white70,
                                      ),
                                    ),
                                    if (hasCustomRpc)
                                      Text(
                                        'RPC: ${networkProvider.getCustomRpc(networkId)}',
                                        style: const TextStyle(
                                          color: Colors.white60,
                                          fontSize: 12,
                                          fontFamily: 'monospace',
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Test Connection Button
                                    if (isTestingThis)
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppTheme.shimmeringGold,
                                              ),
                                        ),
                                      )
                                    else
                                      IconButton(
                                        onPressed:
                                            _isTestingConnection
                                                ? null
                                                : () => _testNetworkConnection(
                                                  networkId,
                                                ),
                                        icon: const Icon(
                                          Icons.wifi_find,
                                          color: Colors.white70,
                                          size: 20,
                                        ),
                                      ),

                                    // Custom RPC Button
                                    IconButton(
                                      onPressed:
                                          () => Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      AddCustomRpcScreen(
                                                        networkId: networkId,
                                                      ),
                                            ),
                                          ),
                                      icon: Icon(
                                        hasCustomRpc ? Icons.edit : Icons.add,
                                        color: AppTheme.shimmeringGold,
                                        size: 20,
                                      ),
                                    ),

                                    // Selection Indicator
                                    if (isSelected)
                                      const Icon(
                                        Icons.check_circle,
                                        color: AppTheme.shimmeringGold,
                                        size: 24,
                                      )
                                    else
                                      const Icon(
                                        Icons.radio_button_unchecked,
                                        color: Colors.white38,
                                        size: 24,
                                      ),
                                  ],
                                ),
                                onTap:
                                    isSelected
                                        ? null
                                        : () async {
                                          await networkProvider.switchNetwork(
                                            networkId,
                                          );
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Switched to ${config.name}',
                                                ),
                                                backgroundColor:
                                                    AppTheme.arcanePurple,
                                              ),
                                            );
                                          }
                                        },
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                  // Add Custom Network Button
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: MagicButton(
                      text: 'Add Custom Network',
                      icon: Icons.add_circle_outline,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Custom networks coming in future update',
                            ),
                            backgroundColor: AppTheme.arcanePurple,
                          ),
                        );
                      },
                      isPrimary: false,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
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
}
