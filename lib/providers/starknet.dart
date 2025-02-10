import 'package:cbor/cbor.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:infinirewards_merchant/models/collectible_contract.dart';
import 'package:infinirewards_merchant/models/merchant.dart';
import 'package:infinirewards_merchant/models/points_contract.dart';
import 'package:infinirewards_merchant/utils/bytearray.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:starknet/starknet.dart';
import 'package:starknet_provider/starknet_provider.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part 'starknet.g.dart';
part 'starknet.freezed.dart';

const _privateKeyStorageKey = 'private_key';
const _accountAddressStorageKey = 'account_address';
const _storage = FlutterSecureStorage();

@freezed
class StarknetProviderData with _$StarknetProviderData {
  factory StarknetProviderData({
    required JsonRpcProvider provider,
    Account? signerAccount,
    Merchant? merchant,
  }) = _StarknetProviderData;
}

@Riverpod(keepAlive: true)
class Starknet extends _$Starknet {
  static const String _infiniRewardsFactoryAddress =
      '0x6c0b75d53c757cc1979d3aaa9482ac449ae0dfd1e5a9807b24478cf4da2d5f8';

  static const String _infiniRewardsMerchantClassHash =
      "0x5e8a8feaf3c6c071347158da11ea32db4fe8939cab7448b31063646ee25f58f";

  static const String _strkAddress =
      '0x4718F5A0FC34CC1AF16A1CDEE98FFB20C31F5CD61D6AB07201858F4287C938D';

  @override
  StarknetProviderData build() {
    return StarknetProviderData(
      provider: JsonRpcProvider(
          nodeUri: Uri.parse(
              'https://starknet-sepolia.public.blastapi.io/rpc/v0_7')),
      signerAccount: null,
      merchant: null,
    );
  }

  Future<void> loadCredentials() async {
    try {
      print("Loading credentials");
      final privateKey = await _storage.read(key: _privateKeyStorageKey);
      final accountAddress =
          await _storage.read(key: _accountAddressStorageKey);

      if (privateKey != null && accountAddress != null) {
        print("Credentials loaded");
        // Create signer account
        final account = getAccount(
          accountAddress: Felt.fromHexString(accountAddress),
          privateKey: Felt.fromHexString(privateKey),
          nodeUri:
              Uri.parse('https://starknet-sepolia.public.blastapi.io/rpc/v0_7'),
        );

        // Get merchant details
        final result = (await state.provider.call(
          request: FunctionCall(
            contractAddress: Felt.fromHexString(accountAddress),
            entryPointSelector: getSelectorByName("get_metadata"),
            calldata: [],
          ),
          blockId: BlockId.latest,
        ))
            .when(
          result: (result) => result,
          error: (error) => throw Exception("Failed to get merchant details"),
        );

        int currentIndex = 0;
        int count = result[currentIndex++].toInt();
        final metadataBytes = ByteArray(
          data: result.sublist(currentIndex, currentIndex + count),
          pendingWord: result[currentIndex + count],
          pendingWordLen: result[currentIndex + count + 1].toInt(),
        ).toBytes();

        final metadata =
            cborDecode(metadataBytes).toJson() as Map<String, dynamic>;

        // Create merchant object
        final merchant = Merchant(
          address: accountAddress,
          name: metadata["name"],
        );

        // Update state with both account and merchant
        state = state.copyWith(
          signerAccount: account,
          merchant: merchant,
        );
      }
    } catch (e) {
      // Handle initialization error
      print('Failed to initialize Starknet provider: $e');
    }
  }

  Future<String> generateNewAccount() async {
    final privateKey = await Future(() {
      final mnemonic = bip39.generateMnemonic();
      final privateKey = derivePrivateKey(mnemonic: mnemonic);
      return privateKey;
    });
    final accountAddress = await computeMerchantAddress(privateKey);
    state = state.copyWith(
      signerAccount: getAccount(
        accountAddress: Felt.fromHexString(accountAddress),
        privateKey: privateKey,
        nodeUri:
            Uri.parse('https://starknet-sepolia.public.blastapi.io/rpc/v0_7'),
      ),
    );
    return accountAddress;
  }

  Future<String> computeMerchantAddress(
    Felt privateKey,
  ) async {
    return Future(() {
      final publicKey = Signer(privateKey: privateKey).publicKey;
      final accountAddress = Contract.computeAddress(
          classHash: Felt.fromHexString(_infiniRewardsMerchantClassHash),
          calldata: [publicKey],
          salt: publicKey);
      return accountAddress.toHexString();
    });
  }

  Future<void> authenticate(String privateKey) async {
    try {
      final privateKeyFelt = Felt.fromHexString(privateKey);
      final accountAddress = await computeMerchantAddress(privateKeyFelt);

      // Create signer account
      final account = getAccount(
        accountAddress: Felt.fromHexString(accountAddress),
        privateKey: privateKeyFelt,
        nodeUri:
            Uri.parse('https://starknet-sepolia.public.blastapi.io/rpc/v0_7'),
      );

      if (!(await account.isValid)) {
        throw Exception("Account not deployed");
      }

      // Get merchant details
      final result = (await state.provider.call(
        request: FunctionCall(
          contractAddress: Felt.fromHexString(accountAddress),
          entryPointSelector: getSelectorByName("get_metadata"),
          calldata: [],
        ),
        blockId: BlockId.latest,
      ))
          .when(
        result: (result) => result,
        error: (error) => throw Exception("Failed to get merchant details"),
      );

      int currentIndex = 0;
      int count = result[currentIndex++].toInt();
      final metadataBytes = ByteArray(
        data: result.sublist(currentIndex, currentIndex + count),
        pendingWord: result[currentIndex + count],
        pendingWordLen: result[currentIndex + count + 1].toInt(),
      ).toBytes();
      final metadata =
          cborDecode(metadataBytes).toJson() as Map<String, dynamic>;

      // Create merchant object
      final merchant = Merchant(
        address: accountAddress,
        name: metadata["name"],
      );

      // Store credentials securely
      await _storage.write(key: _privateKeyStorageKey, value: privateKey);
      await _storage.write(
          key: _accountAddressStorageKey, value: accountAddress);

      // Update state with both account and merchant
      state = state.copyWith(
        signerAccount: account,
        merchant: merchant,
      );
    } catch (e) {
      print('Failed to authenticate: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: _privateKeyStorageKey);
    await _storage.delete(key: _accountAddressStorageKey);
    state = state.copyWith(
      signerAccount: null,
      merchant: null,
    );
  }

  bool get isAuthenticated => state.signerAccount != null;

  // void setSignerAccount(Account signerAccount) {
  //   state = state.copyWith(signerAccount: signerAccount);
  // }

  Future<void> deployMerchantAccount(
      String name, String symbol, int decimals) async {
    if (state.signerAccount == null) {
      throw Exception("Signer account is not initialized");
    }

    final res = await Account.deployAccount(
      signer: state.signerAccount!.signer,
      provider: state.provider,
      constructorCalldata: [
        state.signerAccount!.signer.publicKey,
      ],
      classHash: Felt.fromHexString(_infiniRewardsMerchantClassHash),
      contractAddressSalt: state.signerAccount!.signer.publicKey,
      useSTRKFee: true,
      l1MaxAmount: Felt.fromDouble(1800),
      l1MaxPricePerUnit: Felt.fromDouble(1E14),
    );

    final result = res.when(
      result: (result) => result,
      error: (error) => throw Exception(
          "Failed to deploy merchant account, ${error.toString()}"),
    );
    await Future.delayed(const Duration(seconds: 1));

    await waitForAcceptance(
        transactionHash: result.transactionHash.toHexString(),
        provider: state.provider);

    while (true) {
      final finalityStatus = (await state.provider.getTransactionReceipt(
              Felt.fromHexString(result.transactionHash.toHexString())))
          .when(
        result: (result) => result.map(
          declareTxnReceipt: (receipt) => receipt.finality_status,
          deployTxnReceipt: (receipt) => receipt.finality_status,
          deployAccountTxnReceipt: (receipt) => receipt.finality_status,
          l1HandlerTxnReceipt: (receipt) => receipt.finality_status,
          pendingDeployTxnReceipt: (receipt) => 'PENDING',
          pendingCommonReceiptProperties: (receipt) => 'PENDING',
          invokeTxnReceipt: (receipt) => receipt.finality_status,
        ),
        error: (error) =>
            throw Exception("Failed to get transaction finality status"),
      );
      if (finalityStatus == 'ACCEPTED_ON_L2') {
        break;
      }
      await Future.delayed(const Duration(seconds: 3));
    }

    print("Deployed merchant account");
    while (true) {
      try {
        final nonce = (await state.provider.getNonce(
                contractAddress: state.signerAccount!.accountAddress,
                blockId: BlockId.latest))
            .when(
          result: (result) => result,
          error: (error) => throw Exception("Failed to get nonce"),
        );
        print("Nonce: $nonce");
        break;
      } catch (e) {
        print("Failed to get nonce: $e");
      }
      await Future.delayed(const Duration(seconds: 3));
    }

    await updateMerchantMetadata({
      "name": name,
    });

    print("Updated merchant metadata");

    await createPointsContract(
        name, symbol, {'description': 'Default Points'}, decimals);

    print("Created points contract");

    final merchant = Merchant(
      address: state.signerAccount!.accountAddress.toHexString(),
      name: name,
    );

    // Store credentials securely
    await _storage.write(
        key: _privateKeyStorageKey,
        value: state.signerAccount!.signer.privateKey.toHexString());
    await _storage.write(
        key: _accountAddressStorageKey,
        value: state.signerAccount!.accountAddress.toHexString());

    // Update state with both account and merchant
    state = state.copyWith(
      merchant: merchant,
    );
  }

  Future<Uint256> getStrkBalance() async {
    if (state.signerAccount == null) {
      throw Exception("Signer account is not initialized");
    }
    final balance = await ERC20(
            account: state.signerAccount!,
            address: Felt.fromHexString(_strkAddress))
        .balanceOf(state.signerAccount!.accountAddress);
    return balance;
  }

  // Factory Contract

  Future<PointsContract> createPointsContract(String name, String symbol,
      Map<String, dynamic> metadata, int decimals) async {
    final receipt = await _executeTransaction(
        contractAddress: _infiniRewardsFactoryAddress,
        functionName: "create_points_contract",
        calldata: [
          ...ByteArray.fromString(name).toCallData(),
          ...ByteArray.fromString(symbol).toCallData(),
          ...ByteArray.fromBytes(cborEncode(CborValue(metadata))).toCallData(),
          Felt.fromInt(decimals),
        ]);
    final pointsContractAddress = receipt.events[0].fromAddress;
    if (pointsContractAddress == null) {
      throw Exception("Failed to get points contract address");
    }
    while (true) {
      try {
        (await state.provider.getClassHashAt(
                contractAddress: pointsContractAddress,
                blockId: BlockId.latest))
            .when(
          result: (result) => result,
          error: (error) => throw Exception("Failed to get class hash"),
        );
        break;
      } catch (e) {
        print("Failed to get class hash: $e");
      }
      await Future.delayed(const Duration(seconds: 3));
    }
    return getPointsContractDetails(pointsContractAddress.toHexString());
  }

  Future<CollectibleContract> createCollectibleContract(
      String name, Map<String, dynamic> metadata) async {
    final receipt = await _executeTransaction(
        contractAddress: _infiniRewardsFactoryAddress,
        functionName: "create_collectible_contract",
        calldata: [
          ...ByteArray.fromString(name).toCallData(),
          ...ByteArray.fromBytes(cborEncode(CborValue(metadata))).toCallData(),
        ]);
    final collectibleContractAddress = receipt.events[0].fromAddress;
    if (collectibleContractAddress == null) {
      throw Exception("Failed to get collectible contract address");
    }
    while (true) {
      try {
        (await state.provider.getClassHashAt(
                contractAddress: collectibleContractAddress,
                blockId: BlockId.latest))
            .when(
          result: (result) => result,
          error: (error) => throw Exception("Failed to get class hash"),
        );
        break;
      } catch (e) {
        print("Failed to get class hash: $e");
      }
      await Future.delayed(const Duration(seconds: 3));
    }
    return getCollectibleContractDetails(
        collectibleContractAddress.toHexString());
  }

  // Merchant Contract
  Future<List<PointsContract>> getPointsContracts() async {
    if (state.signerAccount == null) {
      throw Exception("Signer account is not initialized");
    }
    final result = (await state.provider.call(
            request: FunctionCall(
                contractAddress: state.signerAccount!.accountAddress,
                entryPointSelector: getSelectorByName("get_points_contracts"),
                calldata: []),
            blockId: BlockId.latest))
        .when(
      result: (result) => result,
      error: (error) => throw Exception(
          "Failed to get points contracts for ${state.signerAccount!.accountAddress.toHexString()}"),
    );
    print("Result: $result");
    final length = result[0].toInt();
    if (length == 0) {
      return [];
    }
    final pointsContractAddresses =
        result.sublist(1, length + 1).map((e) => e.toHexString()).toList();
    print("Points contract addresses: $pointsContractAddresses");
    return Future.wait<PointsContract>(pointsContractAddresses
        .map((address) => getPointsContractDetails(address)));
  }

  Future<List<CollectibleContract>> getCollectibleContracts() async {
    if (state.signerAccount == null) {
      throw Exception("Signer account is not initialized");
    }
    final result = (await state.provider.call(
            request: FunctionCall(
                contractAddress: state.signerAccount!.accountAddress,
                entryPointSelector:
                    getSelectorByName("get_collectible_contracts"),
                calldata: []),
            blockId: BlockId.latest))
        .when(
      result: (result) => result,
      error: (error) => throw Exception("Failed to get collectible contracts"),
    );
    final length = result[0].toInt();
    if (length == 0) {
      return [];
    }
    final collectibleContractAddresses =
        result.sublist(1, length + 1).map((e) => e.toHexString()).toList();
    return Future.wait(collectibleContractAddresses
        .map((address) => getCollectibleContractDetails(address)));
  }

  Future<void> updateMerchantMetadata(Map<String, dynamic> metadata) async {
    await _executeTransaction(
        contractAddress: state.signerAccount!.accountAddress.toHexString(),
        functionName: "set_metadata",
        calldata: [
          ...ByteArray.fromBytes(cborEncode(CborValue(metadata))).toCallData()
        ]);
  }

  // Points Contract
  Future<void> mintPoints(
      String pointsContractAddress, Felt to, Uint256 amount) async {
    await _executeTransaction(
        contractAddress: pointsContractAddress,
        functionName: "mint",
        calldata: [to, amount.high, amount.low]);
  }

  Future<void> updateMetadata(
      String pointsContractAddress, Map<String, dynamic> metadata) async {
    await _executeTransaction(
        contractAddress: pointsContractAddress,
        functionName: "update_metadata",
        calldata: [
          ...ByteArray.fromBytes(cborEncode(CborValue(metadata))).toCallData()
        ]);
  }

  Future<PointsContract> getPointsContractDetails(
      String pointsContractAddress) async {
    print("Getting details for $pointsContractAddress");
    final result = (await state.provider.call(
            request: FunctionCall(
                contractAddress: Felt.fromHexString(pointsContractAddress),
                entryPointSelector: getSelectorByName("get_details"),
                calldata: []),
            blockId: BlockId.latest))
        .when(
      result: (result) => result,
      error: (error) =>
          throw Exception("Failed to get details for $pointsContractAddress"),
    );
    int currentIndex = 0;
    int count = result[currentIndex++].toInt();
    String name = ByteArray(
      data: result.sublist(currentIndex, currentIndex + count),
      pendingWord: result[currentIndex + count],
      pendingWordLen: result[currentIndex + count + 1].toInt(),
    ).toString();
    currentIndex += count + 2;
    count = result[currentIndex++].toInt();
    String symbol = ByteArray(
      data: result.sublist(currentIndex, currentIndex + count),
      pendingWord: result[currentIndex + count],
      pendingWordLen: result[currentIndex + count + 1].toInt(),
    ).toString();
    currentIndex += count + 2;
    count = result[currentIndex++].toInt();
    List<int> metadata = ByteArray(
      data: result.sublist(currentIndex, currentIndex + count),
      pendingWord: result[currentIndex + count],
      pendingWordLen: result[currentIndex + count + 1].toInt(),
    ).toBytes();
    currentIndex += count + 2;
    int decimals = result[currentIndex++].toInt();
    int totalSupply = result[currentIndex++].toInt();
    return PointsContract(
        address: pointsContractAddress,
        name: name,
        symbol: symbol,
        metadata: cborDecode(metadata).toJson() as Map<String, dynamic>,
        decimals: decimals,
        totalSupply: totalSupply);
  }

  Future<void> updatePointContract(
      String pointsContractAddress, String newClassHash) async {
    await _executeTransaction(
        contractAddress: pointsContractAddress,
        functionName: "update",
        calldata: [Felt.fromHexString(newClassHash)]);
  }

  // Collectible Contract
  Future<void> mintCollectible(String collectibleContractAddress, String to,
      BigInt tokenId, BigInt value) async {
    final tokenIdU256 = Uint256.fromBigInt(tokenId);
    final valueU256 = Uint256.fromBigInt(value);
    await _executeTransaction(
        contractAddress: collectibleContractAddress,
        functionName: "mint",
        calldata: [
          Felt.fromHexString(to),
          tokenIdU256.high,
          tokenIdU256.low,
          valueU256.high,
          valueU256.low,
          Felt.zero,
        ]);
  }

  Future<void> setTokenData(
    String collectibleContractAddress,
    BigInt tokenId,
    String pointsContractAddress,
    BigInt price,
    DateTime expirationDate,
    Map<String, dynamic> metadata,
  ) async {
    final expirationDateFelt =
        Felt.fromInt(expirationDate.millisecondsSinceEpoch ~/ 1000);
    final priceU256 = Uint256.fromBigInt(price);
    final tokenIdU256 = Uint256.fromBigInt(tokenId);
    await _executeTransaction(
        contractAddress: collectibleContractAddress,
        functionName: "set_token_data",
        calldata: [
          tokenIdU256.high,
          tokenIdU256.low,
          Felt.fromHexString(pointsContractAddress),
          priceU256.high,
          priceU256.low,
          expirationDateFelt,
          ...ByteArray.fromBytes(cborEncode(CborValue(metadata))).toCallData(),
        ]);
  }

  Future<CollectibleToken> getTokenData(
      String collectibleContractAddress, BigInt tokenId) async {
    final tokenIdU256 = Uint256.fromBigInt(tokenId);
    final result = (await state.provider.call(
            request: FunctionCall(
                contractAddress: Felt.fromHexString(collectibleContractAddress),
                entryPointSelector: getSelectorByName("get_token_data"),
                calldata: [tokenIdU256.high, tokenIdU256.low]),
            blockId: BlockId.latest))
        .when(
      result: (result) => result,
      error: (error) => throw Exception("Failed to get token data"),
    );
    int currentIndex = 0;
    final pointsContractAddress = result[currentIndex++].toHexString();
    final price =
        Uint256.fromFeltList(result.sublist(currentIndex, currentIndex + 2))
            .toBigInt();
    currentIndex += 2;
    final expirationDate = result[currentIndex++].toInt();
    int count = result[currentIndex++].toInt();
    List<int> metadata = ByteArray(
      data: result.sublist(currentIndex, currentIndex + count),
      pendingWord: result[currentIndex + count],
      pendingWordLen: result[currentIndex + count + 1].toInt(),
    ).toBytes();
    currentIndex += count + 2;
    final supply =
        Uint256.fromFeltList(result.sublist(currentIndex, currentIndex + 2))
            .toBigInt();
    return CollectibleToken(
      tokenId: tokenId,
      pointsContract: pointsContractAddress,
      price: price,
      expiry: expirationDate,
      metadata: cborDecode(metadata).toJson() as Map<String, dynamic>,
      supply: supply,
    );
  }

  Future<void> redeemCollectible(String collectibleContractAddress, String user,
      BigInt tokenId, BigInt amount) async {
    final tokenIdU256 = Uint256.fromBigInt(tokenId);
    final amountU256 = Uint256.fromBigInt(amount);
    await _executeTransaction(
        contractAddress: collectibleContractAddress,
        functionName: "redeem",
        calldata: [
          Felt.fromHexString(user),
          tokenIdU256.high,
          tokenIdU256.low,
          amountU256.high,
          amountU256.low,
        ]);
  }

  Future<CollectibleContract> getCollectibleContractDetails(
      String collectibleContractAddress) async {
    final result = (await state.provider.call(
            request: FunctionCall(
                contractAddress: Felt.fromHexString(collectibleContractAddress),
                entryPointSelector: getSelectorByName("get_details"),
                calldata: []),
            blockId: BlockId.latest))
        .when(
      result: (result) => result,
      error: (error) => throw Exception("Failed to get details"),
    );
    int currentIndex = 0;
    int count = result[currentIndex++].toInt();
    String name = ByteArray(
      data: result.sublist(currentIndex, currentIndex + count),
      pendingWord: result[currentIndex + count],
      pendingWordLen: result[currentIndex + count + 1].toInt(),
    ).toString();
    currentIndex += count + 2;
    count = result[currentIndex++].toInt();
    List<int> metadata = ByteArray(
      data: result.sublist(currentIndex, currentIndex + count),
      pendingWord: result[currentIndex + count],
      pendingWordLen: result[currentIndex + count + 1].toInt(),
    ).toBytes();
    currentIndex += count + 2;
    String pointsContractAddress = result[currentIndex++].toHexString();
    count = result[currentIndex++].toInt();
    List<BigInt> tokenIds = [];
    for (int i = 0; i < count; i++) {
      tokenIds.add(
          Uint256.fromFeltList(result.sublist(currentIndex, currentIndex + 2))
              .toBigInt());
      currentIndex += 2;
    }
    count = result[currentIndex++].toInt();
    List<BigInt> tokenPrices = [];
    for (int i = 0; i < count; i++) {
      tokenPrices.add(
          Uint256.fromFeltList(result.sublist(currentIndex, currentIndex + 2))
              .toBigInt());
      currentIndex += 2;
    }
    count = result[currentIndex++].toInt();
    List<int> tokenExpiries = [];
    for (int i = 0; i < count; i++) {
      tokenExpiries.add(result[currentIndex++].toInt());
    }
    count = result[currentIndex++].toInt();
    List<Map<String, dynamic>> tokenMetadatas = [];
    for (int i = 0; i < count; i++) {
      final fullWordsCount = result[currentIndex++].toInt();
      final fullWords =
          result.sublist(currentIndex, currentIndex + fullWordsCount);
      final metadataBytes = ByteArray(
              data: fullWords,
              pendingWord: result[currentIndex + fullWordsCount],
              pendingWordLen: result[currentIndex + fullWordsCount + 1].toInt())
          .toBytes();
      tokenMetadatas
          .add(cborDecode(metadataBytes).toJson() as Map<String, dynamic>);
      currentIndex += fullWordsCount + 2;
    }
    count = result[currentIndex++].toInt();
    List<BigInt> tokenSupplies = [];
    for (int i = 0; i < count; i++) {
      tokenSupplies.add(
          Uint256.fromFeltList(result.sublist(currentIndex, currentIndex + 2))
              .toBigInt());
      currentIndex += 2;
    }
    final tokens = tokenIds.map((id) => CollectibleToken(
          tokenId: id,
          pointsContract: pointsContractAddress,
          price: tokenPrices[tokenIds.indexOf(id)],
          expiry: tokenExpiries[tokenIds.indexOf(id)],
          metadata: tokenMetadatas[tokenIds.indexOf(id)],
          supply: tokenSupplies[tokenIds.indexOf(id)],
        ));
    return CollectibleContract(
      address: collectibleContractAddress,
      name: name,
      metadata: cborDecode(metadata).toJson() as Map<String, dynamic>,
      pointsContract: pointsContractAddress,
      tokens: tokens.toList(),
    );
  }

  Future<void> setCollectibleDetails(String collectibleContractAddress,
      String name, Map<String, dynamic> metadata) async {
    await _executeTransaction(
        contractAddress: collectibleContractAddress,
        functionName: "set_details",
        calldata: [
          ...ByteArray.fromString(name).toCallData(),
          ...ByteArray.fromBytes(cborEncode(CborValue(metadata))).toCallData()
        ]);
  }

  Future<TxnReceipt> _executeTransaction({
    required String contractAddress,
    required String functionName,
    List<Felt> calldata = const [],
    Felt? nonce,
  }) async {
    if (state.signerAccount == null) {
      throw Exception("Signer account is not initialized");
    }
    final res = await state.signerAccount!.execute(
      useSTRKFee: true,
      functionCalls: [
        FunctionCall(
          contractAddress: Felt.fromHexString(contractAddress),
          entryPointSelector: getSelectorByName(functionName),
          calldata: calldata,
        ),
      ],
      nonce: nonce,
      l1MaxAmount: Felt.fromDouble(1800),
      l1MaxPricePerUnit: Felt.fromDouble(1E14),
    );
    final result = res.when(
      result: (result) => result,
      error: (error) =>
          throw Exception("Failed to execute transaction: $error"),
    );
    await waitForAcceptance(
        transactionHash: result.transaction_hash, provider: state.provider);

    TxnReceipt receipt;
    while (true) {
      receipt = (await state.provider.getTransactionReceipt(
              Felt.fromHexString(result.transaction_hash)))
          .when(
        result: (result) => result,
        error: (error) =>
            throw Exception("Failed to get transaction finality status"),
      );
      final finalityStatus = receipt.map(
        declareTxnReceipt: (receipt) => receipt.finality_status,
        deployTxnReceipt: (receipt) => receipt.finality_status,
        deployAccountTxnReceipt: (receipt) => receipt.finality_status,
        l1HandlerTxnReceipt: (receipt) => receipt.finality_status,
        pendingDeployTxnReceipt: (receipt) => 'PENDING',
        pendingCommonReceiptProperties: (receipt) => 'PENDING',
        invokeTxnReceipt: (receipt) => receipt.finality_status,
      );
      if (finalityStatus == 'ACCEPTED_ON_L2') {
        break;
      }
      await Future.delayed(const Duration(seconds: 3));
    }

    return receipt;
  }
}
