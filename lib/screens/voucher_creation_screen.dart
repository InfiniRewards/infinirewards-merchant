import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinirewards_merchant/config/theme.dart';
import 'package:infinirewards_merchant/models/points_contract.dart';
import 'package:infinirewards_merchant/providers/starknet.dart';
import 'package:intl/intl.dart';

class VoucherCreationScreen extends ConsumerStatefulWidget {
  final String? collectibleContractAddress;
  final BigInt? tokenId;

  const VoucherCreationScreen({
    super.key,
    this.collectibleContractAddress,
    this.tokenId,
  });

  @override
  ConsumerState<VoucherCreationScreen> createState() =>
      _VoucherCreationScreenState();
}

class _VoucherCreationScreenState extends ConsumerState<VoucherCreationScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  String? _selectedPointsContract;
  List<PointsContract> _pointsContracts = [];

  @override
  void initState() {
    super.initState();
    _loadPointsContracts();
  }

  Future<void> _loadPointsContracts() async {
    try {
      final contracts =
          await ref.read(starknetProvider.notifier).getPointsContracts();
      if (mounted) {
        setState(() {
          _pointsContracts = contracts;
          if (contracts.isNotEmpty) {
            _selectedPointsContract = contracts.first.address;
          }
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
        final name = _formKey.currentState!.value['name'] as String;
        final points =
            int.parse(_formKey.currentState!.value['points'] as String);
        final expirationDate =
            _formKey.currentState!.value['expirationDate'] as DateTime;

        if (_selectedPointsContract == null) {
          throw Exception('No points contract selected');
        }

        final metadata = {
          'name': name,
          'description': 'Voucher for $points points',
        };

        String collectibleAddress = widget.collectibleContractAddress ?? '';
        BigInt tokenId = widget.tokenId ??
            BigInt.from(DateTime.now().millisecondsSinceEpoch);

        // Create collectible contract if not exists
        if (collectibleAddress.isEmpty) {
          final contract = await ref
              .read(starknetProvider.notifier)
              .createCollectibleContract(
                name,
                metadata,
              );
          collectibleAddress = contract.address;
        }

        // Set token data for the voucher
        await ref.read(starknetProvider.notifier).setTokenData(
              collectibleAddress,
              tokenId,
              _selectedPointsContract!,
              BigInt.from(points),
              expirationDate,
              metadata,
            );

        // Mint the voucher
        await ref.read(starknetProvider.notifier).mintCollectible(
              collectibleAddress,
              _selectedPointsContract!,
              tokenId,
              BigInt.one,
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Voucher created successfully')),
          );
          Navigator.of(context).pop();
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
    final isUpdate =
        widget.collectibleContractAddress != null && widget.tokenId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isUpdate ? 'Update Voucher' : 'Create Voucher'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    children: [
                      FormBuilderTextField(
                        name: 'name',
                        decoration: const InputDecoration(
                          labelText: 'Voucher Name',
                          prefixIcon: Icon(Icons.card_giftcard),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.minLength(3),
                          FormBuilderValidators.maxLength(50),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      if (_pointsContracts.isNotEmpty)
                        DropdownButtonFormField<String>(
                          value: _selectedPointsContract,
                          decoration: const InputDecoration(
                            labelText: 'Points Contract',
                            prefixIcon: Icon(Icons.account_balance_wallet),
                          ),
                          items: _pointsContracts.map((contract) {
                            return DropdownMenuItem(
                              value: contract.address,
                              child:
                                  Text('${contract.name} (${contract.symbol})'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPointsContract = value;
                            });
                          },
                        ),
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: 'points',
                        decoration: const InputDecoration(
                          labelText: 'Point Value',
                          prefixIcon: Icon(Icons.stars),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.numeric(),
                          FormBuilderValidators.min(0),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      FormBuilderDateTimePicker(
                        name: 'expirationDate',
                        decoration: const InputDecoration(
                          labelText: 'Expiration Date',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        inputType: InputType.date,
                        format: DateFormat('yyyy-MM-dd'),
                        initialDate:
                            DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          (value) {
                            if (value != null &&
                                value.isBefore(DateTime.now())) {
                              return 'Expiration date must be in the future';
                            }
                            return null;
                          },
                        ]),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  isUpdate
                                      ? 'Update Voucher'
                                      : 'Create Voucher',
                                  style: const TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
