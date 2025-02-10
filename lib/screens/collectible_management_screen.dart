import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinirewards_merchant/config/theme.dart';
import 'package:infinirewards_merchant/models/collectible_contract.dart';
import 'package:infinirewards_merchant/providers/starknet.dart';

class CollectibleManagementScreen extends ConsumerStatefulWidget {
  final CollectibleContract? collectibleContract;

  const CollectibleManagementScreen({super.key, this.collectibleContract});

  @override
  ConsumerState<CollectibleManagementScreen> createState() =>
      _CollectibleManagementScreenState();
}

class _CollectibleManagementScreenState
    extends ConsumerState<CollectibleManagementScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isUpdate = widget.collectibleContract != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isUpdate
            ? 'Update Collectible Contract'
            : 'Create Collectible Contract'),
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
                  initialValue: isUpdate
                      ? {
                          'name': widget.collectibleContract!.name,
                          'description': widget.collectibleContract!
                                  .metadata['description'] ??
                              '',
                        }
                      : {},
                  child: Column(
                    children: [
                      FormBuilderTextField(
                        name: 'name',
                        decoration: const InputDecoration(
                          labelText: 'Collectible Name',
                          prefixIcon: Icon(Icons.card_giftcard),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.minLength(3),
                          FormBuilderValidators.maxLength(50),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: 'description',
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          prefixIcon: Icon(Icons.description),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.minLength(3),
                          FormBuilderValidators.maxLength(200),
                        ]),
                        maxLines: 3,
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
                                      ? 'Update Collectible Contract'
                                      : 'Create Collectible Contract',
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

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final name = _formKey.currentState!.value['name'] as String;
        final description =
            _formKey.currentState!.value['description'] as String;
        final metadata = {'description': description};

        if (widget.collectibleContract != null) {
          // Update existing contract
          await ref.read(starknetProvider.notifier).setCollectibleDetails(
                widget.collectibleContract!.address,
                name,
                metadata,
              );
        } else {
          // Create new contract
          await ref.read(starknetProvider.notifier).createCollectibleContract(
                name,
                metadata,
              );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.collectibleContract != null
                  ? 'Collectible contract updated successfully'
                  : 'Collectible contract created successfully'),
            ),
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
}
