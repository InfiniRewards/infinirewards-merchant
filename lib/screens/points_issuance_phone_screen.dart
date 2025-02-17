import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinirewards_merchant/config/theme.dart';
import 'package:infinirewards_merchant/providers/starknet.dart';
import 'package:starknet/starknet.dart';

class PointsIssuancePhoneScreen extends ConsumerStatefulWidget {
  const PointsIssuancePhoneScreen({super.key});

  @override
  ConsumerState<PointsIssuancePhoneScreen> createState() =>
      _PointsIssuancePhoneScreenState();
}

class _PointsIssuancePhoneScreenState
    extends ConsumerState<PointsIssuancePhoneScreen> {
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
        title: const Text('Issue Points to Phone'),
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
                        name: 'phoneNumber',
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone),
                          hintText: 'Enter phone number',
                        ),
                        keyboardType: TextInputType.phone,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.numeric(),
                          FormBuilderValidators.minLength(8),
                          FormBuilderValidators.maxLength(15),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: 'points',
                        decoration: const InputDecoration(
                          labelText: 'Points',
                          prefixIcon: Icon(Icons.stars),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.numeric(),
                          FormBuilderValidators.min(1),
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
                              : const Text(
                                  'Issue Points',
                                  style: TextStyle(fontSize: 16),
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
