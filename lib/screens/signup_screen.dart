import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinirewards_merchant/config/theme.dart';
import 'package:infinirewards_merchant/providers/starknet.dart';
import 'package:flutter/services.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isCheckingBalance = false;
  String? _merchantAddress;
  String _merchantName = '';
  String _merchantSymbol = '';
  int _decimals = 18;
  Timer? _balanceCheckTimer;

  @override
  void dispose() {
    _balanceCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _generateKeys() async {
    setState(() => _isLoading = true);
    try {
      _merchantAddress =
          await ref.read(starknetProvider.notifier).generateNewAccount();
      // _merchantAddress = await ref
      //     .read(starknetProvider.notifier)
      //     .computeMerchantAddress(_privateKey!);

      // ref.read(starknetProvider.notifier).setSignerAccount(
      //       getAccount(
      //         accountAddress: Felt.fromHexString(_merchantAddress!),
      //         privateKey: _privateKey!,
      //         nodeUri: Uri.parse(
      //             'https://starknet-sepolia.public.blastapi.io/rpc/v0_7'),
      //       ),
      //     );
      setState(() => _currentStep = 1);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating keys: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkBalance() async {
    if (_merchantAddress == null) return;

    setState(() => _isCheckingBalance = true);
    try {
      final balance =
          await ref.read(starknetProvider.notifier).getStrkBalance();

      if (balance.toBigInt() > BigInt.zero) {
        _balanceCheckTimer?.cancel();
        setState(() => _currentStep = 2);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'No funds detected yet. Please add funds and try again.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking balance: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isCheckingBalance = false);
    }
  }

  void _startBalanceCheck() {
    _balanceCheckTimer?.cancel();
    _checkBalance();
    _balanceCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkBalance();
    });
  }

  Future<void> _deployAccount() async {
    if (_merchantAddress == null ||
        _merchantName.isEmpty ||
        _merchantSymbol.isEmpty) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(starknetProvider.notifier).deployMerchantAccount(
            _merchantName,
            _merchantSymbol,
            _decimals,
          );

      if (mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deploying account: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: Stepper(
        currentStep: _currentStep,
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              children: [
                if (_currentStep == 0)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _generateKeys,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Generate Keys'),
                    ),
                  ),
                if (_currentStep == 2) ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _deployAccount,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Deploy Account'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Back'),
                  ),
                ],
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Generate Keys'),
            content: const Text(
                'Click the button below to generate your merchant account keys.'),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Fund Account'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    'Please send some STRK tokens to your merchant address to continue:'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          _merchantAddress ?? '',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        tooltip: 'Copy address',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(
                            text: _merchantAddress ?? '',
                          )).then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Address copied to clipboard'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isCheckingBalance ? null : _startBalanceCheck,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isCheckingBalance
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Check Balance'),
                  ),
                ),
              ],
            ),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Setup Merchant'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Merchant Name',
                    hintText: 'Enter your merchant name',
                  ),
                  onChanged: (value) => setState(() => _merchantName = value),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Points Symbol',
                    hintText: 'Enter your points symbol (e.g. PTS)',
                  ),
                  onChanged: (value) => setState(() => _merchantSymbol = value),
                ),
              ],
            ),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }
}
