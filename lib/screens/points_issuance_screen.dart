import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinirewards_merchant/config/theme.dart';
import 'package:infinirewards_merchant/providers/starknet.dart';
import 'package:starknet/starknet.dart';

class PointsIssuanceScreen extends ConsumerStatefulWidget {
  const PointsIssuanceScreen({super.key});

  @override
  ConsumerState<PointsIssuanceScreen> createState() =>
      _PointsIssuanceScreenState();
}

class _PointsIssuanceScreenState extends ConsumerState<PointsIssuanceScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  String? _selectedPointsContract;

  @override
  void initState() {
    super.initState();
    _loadPointsContracts();
  }

  Future<void> _loadPointsContracts() async {
    try {
      final contracts =
          await ref.read(starknetProvider.notifier).getPointsContracts();
      if (contracts.isNotEmpty && mounted) {
        setState(() {
          _selectedPointsContract = contracts.first.address;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error loading points contracts: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final phoneNumber =
            _formKey.currentState!.value['phoneNumber'] as String;
        final points =
            int.parse(_formKey.currentState!.value['points'] as String);

        if (_selectedPointsContract == null) {
          throw Exception('No points contract selected');
        }

        await ref.read(starknetProvider.notifier).mintPoints(
              _selectedPointsContract!,
              Felt.fromHexString(phoneNumber),
              Uint256.fromInt(points),
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Points issued successfully')),
          );
          _formKey.currentState?.reset();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Issue Points'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Select Issuance Method',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.push('/points-issuance/phone');
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('Issue to Phone Number'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.push('/points-issuance/address');
                      },
                      icon: const Icon(Icons.account_balance_wallet),
                      label: const Text('Issue to StarkNet Address'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.cardColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
