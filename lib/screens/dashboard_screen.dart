import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinirewards_merchant/config/theme.dart';
import 'package:infinirewards_merchant/providers/starknet.dart';
import 'package:infinirewards_merchant/screens/collectible_management_screen.dart';
import 'package:infinirewards_merchant/screens/collectibles_screen.dart';
import 'package:infinirewards_merchant/screens/points_management_screen.dart';
import 'package:infinirewards_merchant/screens/points_screen.dart';
import 'package:infinirewards_merchant/widgets/stat_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isLoading = true;
  int _totalPointsIssued = 0;
  int _activeVouchers = 0;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      // Get all points contracts
      final pointsContracts =
          await ref.read(starknetProvider.notifier).getPointsContracts();

      // Sum up total supply from all points contracts
      _totalPointsIssued = pointsContracts.fold(
        0,
        (sum, contract) => sum + contract.totalSupply,
      );

      // Get all collectible contracts
      final collectibleContracts =
          await ref.read(starknetProvider.notifier).getCollectibleContracts();

      // Count active vouchers (non-expired tokens across all contracts)
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      _activeVouchers = collectibleContracts.fold(
        0,
        (sum, contract) =>
            sum +
            contract.tokens
                .where((token) => token.expiry > now && !contract.isMembership)
                .length,
      );

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading stats: ${e.toString()}')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildDashboard() {
    final merchant = ref.watch(starknetProvider).merchant;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 48) / 2; // 48 = total horizontal padding
    final cardHeight = cardWidth / 1.5; // maintain 1.5 aspect ratio

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, ${merchant?.name ?? 'Merchant'}!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Here\'s your rewards program overview',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Total Points Issued',
                  value: _isLoading ? '...' : _totalPointsIssued.toString(),
                  icon: Icons.stars,
                  isLoading: _isLoading,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: 'Active Vouchers',
                  value: _isLoading ? '...' : _activeVouchers.toString(),
                  icon: Icons.card_giftcard,
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: _ActionCard(
                  title: 'Issue Points',
                  icon: Icons.add_circle,
                  color: AppTheme.secondaryColor,
                  onTap: () => context.push('/points-issuance'),
                ),
              ),
              SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: _ActionCard(
                  title: 'Create Voucher',
                  icon: Icons.card_giftcard,
                  color: AppTheme.cardColor,
                  onTap: () => context.push('/voucher-creation'),
                ),
              ),
              SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: _ActionCard(
                  title: 'Manage Points',
                  icon: Icons.stars,
                  color: Colors.orange,
                  onTap: () => setState(() => _selectedIndex = 1),
                ),
              ),
              SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: _ActionCard(
                  title: 'Manage Collectibles',
                  icon: Icons.collections_bookmark,
                  color: Colors.purple,
                  onTap: () => setState(() => _selectedIndex = 2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final merchant = ref.watch(starknetProvider).merchant;
    final List<Widget> screens = [
      _buildDashboard(),
      const PointsScreen(key: Key('points_screen')),
      const CollectiblesScreen(key: Key('collectibles_screen')),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(_selectedIndex == 0
            ? merchant?.name ?? 'Dashboard'
            : _selectedIndex == 1
                ? 'Points'
                : 'Collectibles'),
        actions: [
          if (_selectedIndex == 0)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isLoading
                  ? null
                  : () {
                      setState(() => _isLoading = true);
                      _loadStats();
                    },
            ),
          if (_selectedIndex > 0)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                if (_selectedIndex == 1) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PointsManagementScreen(),
                    ),
                  );
                } else {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CollectibleManagementScreen(),
                    ),
                  );
                }
                // Refresh stats and current screen
                _loadStats();
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(starknetProvider.notifier).logout();
              if (context.mounted) {
                context.go('/auth');
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _selectedIndex,
          children: screens,
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (_selectedIndex != index) {
              setState(() => _selectedIndex = index);
              if (index == 0) {
                _loadStats();
              }
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.stars),
              label: 'Points',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.collections_bookmark),
              label: 'Collectibles',
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.8),
                color,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 28, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
