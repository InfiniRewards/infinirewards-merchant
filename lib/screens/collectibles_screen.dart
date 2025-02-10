import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinirewards_merchant/models/collectible_contract.dart';
import 'package:infinirewards_merchant/providers/starknet.dart';
import 'package:infinirewards_merchant/screens/collectible_management_screen.dart';
import 'package:infinirewards_merchant/screens/voucher_creation_screen.dart';

class CollectiblesScreen extends ConsumerStatefulWidget {
  const CollectiblesScreen({super.key});

  @override
  ConsumerState<CollectiblesScreen> createState() => _CollectiblesScreenState();
}

class _CollectiblesScreenState extends ConsumerState<CollectiblesScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  List<CollectibleContract> _contracts = [];
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
    try {
      final contracts =
          await ref.read(starknetProvider.notifier).getCollectibleContracts();
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
                    const Text('No collectible contracts found'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CollectibleManagementScreen(),
                          ),
                        );
                        _loadContracts();
                      },
                      child: const Text('Create Collectible Contract'),
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
                      child: ExpansionTile(
                        title: Text(contract.name),
                        subtitle: Text(contract.metadata['description'] ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CollectibleManagementScreen(
                                      collectibleContract: contract,
                                    ),
                                  ),
                                );
                                _loadContracts();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VoucherCreationScreen(
                                      collectibleContractAddress:
                                          contract.address,
                                    ),
                                  ),
                                );
                                _loadContracts();
                              },
                            ),
                          ],
                        ),
                        children: [
                          if (contract.tokens.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('No tokens found'),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: contract.tokens.length,
                              itemBuilder: (context, tokenIndex) {
                                final token = contract.tokens[tokenIndex];
                                return ListTile(
                                  title: Text(token.metadata['name'] ??
                                      'Unnamed Token'),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Points: ${token.price}'),
                                      Text('Supply: ${token.supply}'),
                                      Text(
                                          'Expires: ${DateTime.fromMillisecondsSinceEpoch(token.expiry * 1000).toString()}'),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              VoucherCreationScreen(
                                            collectibleContractAddress:
                                                contract.address,
                                            tokenId: token.tokenId,
                                          ),
                                        ),
                                      );
                                      _loadContracts();
                                    },
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    );
                  },
                ),
              );
  }
}
