import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../core/providers/network_provider.dart';
import '../../core/providers/wallet_provider.dart';
import '../../core/services/wallet_service.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/magic_app_bar.dart';
import '../../widgets/magic_button.dart';
import '../../widgets/token_selector.dart';
import '../transaction/transaction_confirmation_screen.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  late TabController _tabController;
  String? _selectedToken;
  BigInt? _estimatedGas;
  bool _isEstimatingGas = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Set default token to native currency
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final networkProvider = Provider.of<NetworkProvider>(
        context,
        listen: false,
      );
      _selectedToken = networkProvider.currentNetwork.nativeCurrency.symbol;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _recipientController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _estimateGas() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isEstimatingGas = true);

    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final networkProvider = Provider.of<NetworkProvider>(
      context,
      listen: false,
    );

    final gasEstimate = await walletProvider.estimateGas(
      toAddress: _recipientController.text.trim(),
      amount: _amountController.text.trim(),
      networkProvider: networkProvider,
      tokenContractAddress:
          _selectedToken == networkProvider.currentNetwork.nativeCurrency.symbol
              ? null
              : _getTokenContractAddress(),
    );

    setState(() {
      _estimatedGas = gasEstimate;
      _isEstimatingGas = false;
    });
  }

  String? _getTokenContractAddress() {
    // TODO: Get contract address for selected token
    return null;
  }

  void _proceedToConfirmation() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => TransactionConfirmationScreen(
              recipientAddress: _recipientController.text.trim(),
              amount: _amountController.text.trim(),
              tokenSymbol: _selectedToken!,
              tokenContractAddress: _getTokenContractAddress(),
              estimatedGas: _estimatedGas,
              note: _noteController.text.trim(),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MagicAppBar(title: 'Send'),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.magicGradient),
        child: Column(
          children: [
            // Tab Bar
            Container(
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.darkPurple.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.arcanePurple.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: AppTheme.goldGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppTheme.midnightBlue,
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(icon: Icon(Icons.edit), text: 'Manual Entry'),
                  Tab(icon: Icon(Icons.qr_code_scanner), text: 'Scan QR'),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildManualEntryTab(), _buildQRScannerTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualEntryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Token Selector
            Text(
              'Select Token',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.shimmeringGold,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Consumer2<WalletProvider, NetworkProvider>(
              builder: (context, walletProvider, networkProvider, child) {
                return TokenSelector(
                  tokens: walletProvider.tokenBalances,
                  selectedToken: _selectedToken,
                  onTokenSelected: (token) {
                    setState(() {
                      _selectedToken = token;
                      _estimatedGas = null;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 24),

            // Recipient Address
            Text(
              'Recipient Address',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.shimmeringGold,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _recipientController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: '0x...',
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () async {
                        final clipboardData = await Clipboard.getData(
                          'text/plain',
                        );
                        if (clipboardData?.text != null) {
                          _recipientController.text = clipboardData!.text!;
                        }
                      },
                      icon: const Icon(
                        Icons.paste,
                        color: AppTheme.shimmeringGold,
                        size: 20,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _tabController.animateTo(1);
                      },
                      icon: const Icon(
                        Icons.qr_code_scanner,
                        color: AppTheme.shimmeringGold,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter recipient address';
                }
                if (!WalletService.isValidAddress(value.trim())) {
                  return 'Invalid Ethereum address';
                }
                return null;
              },
              onChanged: (_) {
                setState(() => _estimatedGas = null);
              },
            ),
            const SizedBox(height: 24),

            // Amount
            Text(
              'Amount',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.shimmeringGold,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Consumer<WalletProvider>(
              builder: (context, walletProvider, child) {
                final selectedBalance =
                    walletProvider.tokenBalances
                        .where((b) => b.symbol == _selectedToken)
                        .firstOrNull;

                return Column(
                  children: [
                    TextFormField(
                      controller: _amountController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        hintText: '0.0',
                        suffixText: _selectedToken,
                        suffixStyle: const TextStyle(
                          color: AppTheme.shimmeringGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter amount';
                        }
                        final amount = double.tryParse(value.trim());
                        if (amount == null || amount <= 0) {
                          return 'Please enter valid amount';
                        }
                        if (selectedBalance != null) {
                          final balance =
                              double.tryParse(selectedBalance.balance) ?? 0;
                          if (amount > balance) {
                            return 'Insufficient balance';
                          }
                        }
                        return null;
                      },
                      onChanged: (_) {
                        setState(() => _estimatedGas = null);
                      },
                    ),
                    if (selectedBalance != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Balance: ${selectedBalance.formattedBalance} ${selectedBalance.symbol}',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              _amountController.text = selectedBalance.balance;
                            },
                            child: const Text(
                              'Max',
                              style: TextStyle(
                                color: AppTheme.shimmeringGold,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Note (Optional)
            Text(
              'Note (Optional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.shimmeringGold,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add a note for this transaction...',
              ),
            ),
            const SizedBox(height: 32),

            // Gas Estimation
            if (_estimatedGas != null || _isEstimatingGas) ...[
              Container(
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
                    const Icon(
                      Icons.local_gas_station,
                      color: AppTheme.shimmeringGold,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Estimated Gas Fee',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (_isEstimatingGas)
                            const Text(
                              'Calculating...',
                              style: TextStyle(color: Colors.white60),
                            )
                          else if (_estimatedGas != null)
                            Text(
                              '${WalletService.weiToEther(_estimatedGas!)} ETH',
                              style: const TextStyle(color: Colors.white60),
                            ),
                        ],
                      ),
                    ),
                    if (_isEstimatingGas)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.shimmeringGold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: MagicButton(
                    text: 'Estimate Gas',
                    onPressed: _estimateGas,
                    isLoading: _isEstimatingGas,
                    isPrimary: false,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MagicButton(
                    text: 'Review Transaction',
                    onPressed: _proceedToConfirmation,
                    isPrimary: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRScannerTab() {
    return QRScannerWidget(
      onQRScanned: (address) {
        _recipientController.text = address;
        _tabController.animateTo(0);
      },
    );
  }
}

class QRScannerWidget extends StatefulWidget {
  final Function(String) onQRScanned;

  const QRScannerWidget({super.key, required this.onQRScanned});

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isFlashOn = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        controller.pauseCamera();
        _processScannedData(scanData.code!);
      }
    });
  }

  void _processScannedData(String data) {
    // Extract address from various QR formats
    String address = data;

    // Handle ethereum: URI format
    if (data.startsWith('ethereum:')) {
      final uri = Uri.parse(data);
      address = uri.path;
    }

    // Validate address
    if (WalletService.isValidAddress(address)) {
      widget.onQRScanned(address);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid wallet address in QR code'),
          backgroundColor: Colors.red,
        ),
      );
      controller?.resumeCamera();
    }
  }

  void _toggleFlash() async {
    if (controller != null) {
      await controller!.toggleFlash();
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.arcanePurple.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                  borderColor: AppTheme.shimmeringGold,
                  borderRadius: 16,
                  borderLength: 30,
                  borderWidth: 4,
                  cutOutSize: 250,
                ),
              ),
            ),
          ),
        ),

        // Controls
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                'Scan QR Code',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Point your camera at a wallet address QR code',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Flash Toggle
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.darkPurple.withOpacity(0.6),
                      border: Border.all(
                        color: AppTheme.arcanePurple.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      onPressed: _toggleFlash,
                      icon: Icon(
                        _isFlashOn ? Icons.flash_on : Icons.flash_off,
                        color:
                            _isFlashOn
                                ? AppTheme.shimmeringGold
                                : Colors.white70,
                        size: 24,
                      ),
                    ),
                  ),

                  // Resume Camera
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.darkPurple.withOpacity(0.6),
                      border: Border.all(
                        color: AppTheme.arcanePurple.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () => controller?.resumeCamera(),
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white70,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
