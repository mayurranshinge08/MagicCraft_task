import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/network_provider.dart';
import '../../core/providers/wallet_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/magic_button.dart';
import '../../widgets/network_selector.dart';
import '../../widgets/transaction_item.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final networkProvider = Provider.of<NetworkProvider>(
      context,
      listen: false,
    );

    await walletProvider.refreshWalletData(networkProvider);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.magicGradient),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshData,
            color: AppTheme.shimmeringGold,
            backgroundColor: AppTheme.darkPurple,
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 120,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppTheme.goldGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.shimmeringGold.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            size: 18,
                            color: AppTheme.midnightBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'MagicCraft',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
                  ),
                  actions: [
                    // Network Selector
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Consumer<NetworkProvider>(
                        builder: (context, networkProvider, child) {
                          return NetworkSelector(
                            currentNetwork: networkProvider.currentNetworkId,
                            onNetworkChanged: (networkId) {
                              networkProvider.switchNetwork(networkId);
                              _refreshData();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),

                // Main Content
                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Wallet Address Card
                      _buildWalletAddressCard(),
                      const SizedBox(height: 24),

                      // Balance Cards
                      _buildBalanceSection(),
                      const SizedBox(height: 32),

                      // Quick Actions
                      _buildQuickActions(),
                      const SizedBox(height: 32),

                      // Recent Transactions
                      _buildTransactionsSection(),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWalletAddressCard() {
    return Consumer<WalletProvider>(
      builder: (context, walletProvider, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.darkPurple.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.arcanePurple.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet,
                    color: AppTheme.shimmeringGold,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Wallet Address',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppTheme.shimmeringGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      // TODO: Copy address to clipboard
                    },
                    icon: const Icon(
                      Icons.copy,
                      color: AppTheme.shimmeringGold,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                walletProvider.formattedAddress,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBalanceSection() {
    return Consumer<WalletProvider>(
      builder: (context, walletProvider, child) {
        if (walletProvider.isLoading && walletProvider.tokenBalances.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.shimmeringGold,
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Balances',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (walletProvider.isLoading)
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
            const SizedBox(height: 16),

            // Balance Cards
            ...walletProvider.tokenBalances.map(
              (balance) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: BalanceCard(balance: balance),
              ),
            ),

            if (walletProvider.tokenBalances.isEmpty &&
                !walletProvider.isLoading)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppTheme.darkPurple.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.arcanePurple.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Colors.white38,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No balances found',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: Colors.white60),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pull down to refresh or check your network connection',
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white38),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: MagicButton(
                text: 'Send',
                icon: Icons.send,
                onPressed: () {
                  // TODO: Navigate to send screen
                },
                isPrimary: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MagicButton(
                text: 'Receive',
                icon: Icons.qr_code,
                onPressed: () {
                  // TODO: Navigate to receive screen
                },
                isPrimary: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionsSection() {
    return Consumer<WalletProvider>(
      builder: (context, walletProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Recent Transactions',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to full transaction history
                  },
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: AppTheme.shimmeringGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (walletProvider.recentTransactions.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppTheme.darkPurple.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.arcanePurple.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.history, color: Colors.white38, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'No transactions yet',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: Colors.white60),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your transaction history will appear here',
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white38),
                    ),
                  ],
                ),
              )
            else
              ...walletProvider.recentTransactions.map(
                (transaction) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TransactionItem(transaction: transaction),
                ),
              ),
          ],
        );
      },
    );
  }
}
