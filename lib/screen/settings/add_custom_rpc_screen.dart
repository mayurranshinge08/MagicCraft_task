import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/network_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/magic_app_bar.dart';
import '../../widgets/magic_button.dart';

class AddCustomRpcScreen extends StatefulWidget {
  final String networkId;

  const AddCustomRpcScreen({super.key, required this.networkId});

  @override
  State<AddCustomRpcScreen> createState() => _AddCustomRpcScreenState();
}

class _AddCustomRpcScreenState extends State<AddCustomRpcScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rpcUrlController = TextEditingController();
  bool _isTestingRpc = false;
  bool _rpcTestPassed = false;
  String? _rpcTestError;

  @override
  void initState() {
    super.initState();
    final networkProvider = Provider.of<NetworkProvider>(
      context,
      listen: false,
    );
    final existingRpc = networkProvider.getCustomRpc(widget.networkId);
    if (existingRpc != null) {
      _rpcUrlController.text = existingRpc;
    }
  }

  @override
  void dispose() {
    _rpcUrlController.dispose();
    super.dispose();
  }

  Future<void> _testRpcConnection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isTestingRpc = true;
      _rpcTestPassed = false;
      _rpcTestError = null;
    });

    try {
      final rpcUrl = _rpcUrlController.text.trim();
      final networkConfig = AppConstants.supportedNetworks[widget.networkId]!;

      // Test RPC connection with eth_chainId call
      final response = await http
          .post(
            Uri.parse(rpcUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'jsonrpc': '2.0',
              'method': 'eth_chainId',
              'params': [],
              'id': 1,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] != null) {
          final chainId = int.parse(data['result'], radix: 16);

          if (chainId == networkConfig.chainId) {
            setState(() {
              _rpcTestPassed = true;
              _rpcTestError = null;
            });
          } else {
            setState(() {
              _rpcTestError =
                  'Chain ID mismatch. Expected ${networkConfig.chainId}, got $chainId';
            });
          }
        } else {
          setState(() {
            _rpcTestError =
                'Invalid RPC response: ${data['error']?['message'] ?? 'Unknown error'}';
          });
        }
      } else {
        setState(() {
          _rpcTestError =
              'HTTP ${response.statusCode}: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        _rpcTestError = 'Connection failed: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isTestingRpc = false;
      });
    }
  }

  Future<void> _saveCustomRpc() async {
    if (!_formKey.currentState!.validate() || !_rpcTestPassed) return;

    final networkProvider = Provider.of<NetworkProvider>(
      context,
      listen: false,
    );
    await networkProvider.setCustomRpc(
      widget.networkId,
      _rpcUrlController.text.trim(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Custom RPC saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _removeCustomRpc() async {
    final networkProvider = Provider.of<NetworkProvider>(
      context,
      listen: false,
    );
    await networkProvider.removeCustomRpc(widget.networkId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Custom RPC removed'),
          backgroundColor: AppTheme.arcanePurple,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final networkConfig = AppConstants.supportedNetworks[widget.networkId]!;
    final networkProvider = Provider.of<NetworkProvider>(context);
    final hasExistingRpc = networkProvider.hasCustomRpc(widget.networkId);

    return Scaffold(
      appBar: MagicAppBar(
        title: hasExistingRpc ? 'Edit Custom RPC' : 'Add Custom RPC',
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.magicGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Network Info
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.darkPurple.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.arcanePurple.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getNetworkColor(widget.networkId),
                          ),
                          child: Center(
                            child: Text(
                              _getNetworkInitial(widget.networkId),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                networkConfig.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Chain ID: ${networkConfig.chainId}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // RPC URL Input
                  Text(
                    'Custom RPC URL',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.shimmeringGold,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _rpcUrlController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'https://your-custom-rpc-url.com',
                      prefixIcon: Icon(
                        Icons.link,
                        color: AppTheme.shimmeringGold,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter RPC URL';
                      }
                      if (!Uri.tryParse(value.trim())!.hasAbsolutePath ==
                          true) {
                        return 'Please enter a valid URL';
                      }
                      return null;
                    },
                    onChanged: (_) {
                      setState(() {
                        _rpcTestPassed = false;
                        _rpcTestError = null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Default RPC Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.midnightBlue.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.arcanePurple.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Default RPC URL',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          networkConfig.rpcUrl,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Test Connection Button
                  MagicButton(
                    text: 'Test Connection',
                    icon: Icons.wifi_find,
                    onPressed: _isTestingRpc ? null : _testRpcConnection,
                    isLoading: _isTestingRpc,
                    isPrimary: false,
                  ),
                  const SizedBox(height: 16),

                  // Test Result
                  if (_rpcTestPassed || _rpcTestError != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _rpcTestPassed
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _rpcTestPassed
                              ? Colors.green.withOpacity(0.3)
                              : Colors.red.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _rpcTestPassed ? Icons.check_circle : Icons.error,
                            color: _rpcTestPassed ? Colors.green : Colors.red,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _rpcTestPassed
                                  ? 'Connection successful! RPC is working correctly.'
                                  : _rpcTestError!,
                              style: TextStyle(
                                color:
                                    _rpcTestPassed ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  const Spacer(),

                  // Action Buttons
                  Column(
                    children: [
                      MagicButton(
                        text: hasExistingRpc ? 'Update RPC' : 'Save Custom RPC',
                        onPressed: _rpcTestPassed ? _saveCustomRpc : null,
                        isPrimary: true,
                      ),
                      if (hasExistingRpc) ...[
                        const SizedBox(height: 16),
                        MagicButton(
                          text: 'Remove Custom RPC',
                          onPressed: _removeCustomRpc,
                          isPrimary: false,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
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
}
