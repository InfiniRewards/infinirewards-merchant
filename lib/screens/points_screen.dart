import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinirewards_merchant/models/points_contract.dart';
import 'package:infinirewards_merchant/providers/starknet.dart';
import 'package:infinirewards_merchant/screens/points_management_screen.dart';

class PointsScreen extends ConsumerStatefulWidget {
  const PointsScreen({super.key});

  @override
  ConsumerState<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends ConsumerState<PointsScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  List<PointsContract> _contracts = [];
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadContracts();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadContracts();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadContracts();
  }

  Future<void> _loadContracts() async {
    setState(() => _isLoading = true);
    print("Loading contracts");
    try {
      final contracts =
          await ref.read(starknetProvider.notifier).getPointsContracts();
      print("Points Contracts: $contracts");
      if (mounted) {
        setState(() {
          _contracts = contracts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading contracts: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _contracts.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No points contracts found'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const PointsManagementScreen(),
                          ),
                        );
                        _loadContracts();
                      },
                      child: const Text('Create Points Contract'),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadContracts,
                child: ListView.builder(
                  padding: EdgeInsets.only(bottom: bottomPadding),
                  itemCount: _contracts.length,
                  itemBuilder: (context, index) {
                    final contract = _contracts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(contract.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Symbol: ${contract.symbol}'),
                            Text('Total Supply: ${contract.totalSupply}'),
                            Text('Decimals: ${contract.decimals}'),
                            Text(contract.metadata['description'] ?? ''),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PointsManagementScreen(
                                  pointsContract: contract,
                                ),
                              ),
                            );
                            _loadContracts();
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
  }
}
