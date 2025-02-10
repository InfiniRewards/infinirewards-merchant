import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinirewards_merchant/config/theme.dart';
import 'package:infinirewards_merchant/models/points_contract.dart';
import 'package:infinirewards_merchant/providers/starknet.dart';

class PointsManagementScreen extends ConsumerStatefulWidget {
  final PointsContract? pointsContract;

  const PointsManagementScreen({super.key, this.pointsContract});

  @override
  ConsumerState<PointsManagementScreen> createState() =>
      _PointsManagementScreenState();
}

class _PointsManagementScreenState
    extends ConsumerState<PointsManagementScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isUpdate = widget.pointsContract != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            isUpdate ? 'Update Points Contract' : 'Create Points Contract'),
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
                          'name': widget.pointsContract!.name,
                          'symbol': widget.pointsContract!.symbol,
                          'description':
                              widget.pointsContract!.metadata['description'] ??
                                  '',
                          'decimals':
                              widget.pointsContract!.decimals.toString(),
                        }
                      : {},
                  child: Column(
                    children: [
                      FormBuilderTextField(
                        name: 'name',
                        enabled: !isUpdate,
                        decoration: const InputDecoration(
                          labelText: 'Points Name',
                          prefixIcon: Icon(Icons.stars),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.minLength(3),
                          FormBuilderValidators.maxLength(50),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: 'symbol',
                        enabled: !isUpdate,
                        decoration: const InputDecoration(
                          labelText: 'Symbol',
                          prefixIcon: Icon(Icons.label),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.minLength(1),
                          FormBuilderValidators.maxLength(10),
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
                      if (!isUpdate) ...[
                        const SizedBox(height: 16),
                        FormBuilderTextField(
                          name: 'decimals',
                          decoration: const InputDecoration(
                            labelText: 'Decimals',
                            prefixIcon: Icon(Icons.numbers),
                          ),
                          keyboardType: TextInputType.number,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.numeric(),
                            FormBuilderValidators.min(0),
                            FormBuilderValidators.max(18),
                          ]),
                        ),
                      ],
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
                                      ? 'Update Points Contract'
                                      : 'Create Points Contract',
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
        final symbol = _formKey.currentState!.value['symbol'] as String;
        final description =
            _formKey.currentState!.value['description'] as String;

        if (widget.pointsContract != null) {
          // Update existing contract
          await ref.read(starknetProvider.notifier).updateMetadata(
            widget.pointsContract!.address,
            {'description': description},
          );
        } else {
          // Create new contract
          final decimals =
              int.parse(_formKey.currentState!.value['decimals'] as String);
          await ref.read(starknetProvider.notifier).createPointsContract(
                name,
                symbol,
                {'description': description},
                decimals,
              );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.pointsContract != null
                  ? 'Points contract updated successfully'
                  : 'Points contract created successfully'),
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
