import 'package:alephium_wallet/api/coingecko_api/coingecko_repository.dart';
import 'package:alephium_wallet/api/utils/network.dart';
import 'package:alephium_wallet/storage/models/address_store.dart';
import 'package:alephium_wallet/storage/models/balance_store.dart';
import 'package:alephium_wallet/storage/models/token_store.dart';
import 'package:alephium_wallet/storage/models/transaction_ref_store.dart';
import 'package:alephium_wallet/storage/models/transaction_store.dart';
import 'dart:async';

import 'package:dio/dio.dart' hide Headers;

import 'package:alephium_dart/alephium_dart.dart';
import 'package:alephium_wallet/api/utils/either.dart';
import 'package:alephium_wallet/api/utils/error_handler.dart';
import 'package:alephium_wallet/api/repositories/base_api_repository.dart';
import 'package:alephium_wallet/api/repositories/alephium/utils/interceptor.dart';

part "utils/repository_mixin.dart";

class AlephiumApiRepository extends BaseApiRepository with RepositoryMixin {
  late AddressClient _addressClient;
  late TransactionClient _transactionClient;
  late ExplorerClient _explorerClient;
  late CoingeckoClient _coingeckoClient;
  late InfosClient _infosClient;
  late MultisigClient _multisigClient;
  late Dio _dio;

  Network network;

  AlephiumApiRepository(this.network) : super(network) {
    _dio = Dio(
      BaseOptions(
        connectTimeout: 10 * 1000,
        receiveTimeout: 30 * 1000,
      ),
    );
    _dio.interceptors.add(ApiInterceptor(_dio));
    _transactionClient = TransactionClient(_dio, baseUrl: network.nodeHost);
    _addressClient = AddressClient(_dio, baseUrl: network.nodeHost);
    _explorerClient = ExplorerClient(_dio, baseUrl: network.explorerApiHost);
    _coingeckoClient = CoingeckoClient(_dio);
    _infosClient = InfosClient(_dio);
    _multisigClient = MultisigClient(_dio, baseUrl: network.nodeHost);
  }

  set changeNetwork(Network network) {
    this.network = network;
    _transactionClient =
        TransactionClient(_dio, baseUrl: this.network.nodeHost);
    _addressClient = AddressClient(_dio, baseUrl: this.network.nodeHost);
    _explorerClient =
        ExplorerClient(_dio, baseUrl: this.network.explorerApiHost);
    _coingeckoClient = CoingeckoClient(_dio);
    _multisigClient = MultisigClient(_dio, baseUrl: network.nodeHost);
  }

  @override
  FutureOr<Either<BuildMultisigAddressResult>> multisigAddress(
      {required List<String> signatures, required int mrequired}) async {
    try {
      final data = await _multisigClient.postMultisigAddress(
          data: BuildMultisigAddress(
        keys: signatures,
        mrequired: mrequired,
      ));
      return Either<BuildMultisigAddressResult>(data: data);
    } on Exception catch (e, trace) {
      return Either<BuildMultisigAddressResult>(
          error: ApiError(exception: e, trace: trace));
    }
  }

  @override
  FutureOr<Either<BuildTransactionResult>> buildMultisigTx({
    required List<String> fromPublicKey,
    required String toAddress,
    required String fromAddress,
    required BigInt amount,
    int? lockTime,
    BigInt? gasPrice,
    int? gasAmount,
    List<TokenStore>? tokens,
  }) async {
    try {
      final data = await _multisigClient.postMultisigBuild(
          data: BuildMultisig(
        fromAddress: fromAddress,
        fromPublicKeys: fromPublicKey,
        destinations: [
          TransactionDestination(
            address: toAddress,
            attoAlphAmount: amount,
            lockTime: lockTime,
            tokens: tokens
                ?.map<Token>((token) => Token(
                      id: token.id,
                      amount: token.amount,
                    ))
                .toList(),
          ),
        ],
        gasPrice: gasPrice,
        gasAmount: gasAmount,
      ));
      return Either<BuildTransactionResult>(
        data: data,
      );
    } on Exception catch (e, trace) {
      return Either<BuildTransactionResult>(
          error: ApiError(exception: e, trace: trace));
    }
  }

  @override
  FutureOr<Either<TxResult>> submitMultisigTx({
    required List<String> signatures,
    required String unsignedTx,
  }) async {
    try {
      final data = await _multisigClient.postMultisigSubmit(
          data: SubmitMultisig(
        signatures: signatures,
        unsignedTx: unsignedTx,
      ));
      return Either<TxResult>(
        data: data,
      );
    } on Exception catch (e, trace) {
      return Either<TxResult>(error: ApiError(exception: e, trace: trace));
    }
  }

  @override
  Future<Either<NodeVersion>> getNodeVersion() async {
    try {
      final data = await _infosClient.getNodeVersion();
      return Either<NodeVersion>(data: data);
    } on Exception catch (e, trace) {
      return Either<NodeVersion>(error: ApiError(exception: e, trace: trace));
    }
  }

  @override
  Future<Either<double>> getPrice(
      {String coin = "alephium", String currency = "usd"}) async {
    try {
      final data = await _coingeckoClient.getPrice(coin, currency);
      final price = double.parse("${data?[coin]?[currency]}");
      return Either<double>(data: price);
    } on Exception catch (e, trace) {
      return Either<double>(error: ApiError(exception: e, trace: trace));
    }
  }

  @override
  Future<Either<AddressStore>> getAddressBalance(
      {required AddressStore address}) async {
    try {
      var data = await _addressClient.getAddressBalance(address.address);
      final addressData = updateAddressBalance(
        data,
        address: address,
      );
      return Either<AddressStore>(data: addressData);
    } on Exception catch (e, trace) {
      return Either<AddressStore>(error: ApiError(exception: e, trace: trace));
    }
  }

  @override
  FutureOr<Either<List<TransactionStore>>> getAddressTransactions(
      {required String address, required String walletId}) async {
    try {
      var data = await _explorerClient.getAddressTransactions(address: address);
      List<TransactionStore> transactions = parseAddressTransactions(
        data,
        address: address,
        walletId: walletId,
      );
      return Either<List<TransactionStore>>(data: transactions);
    } on Exception catch (e, trace) {
      return Either<List<TransactionStore>>(
          error: ApiError(exception: e, trace: trace));
    }
  }

  @override
  Future<Either<BuildTransactionResult>> createTransaction({
    required String fromPublicKey,
    required String toAddress,
    required BigInt amount,
    int? lockTime,
    BigInt? gasPrice,
    int? gasAmount,
    List<TokenStore>? tokens,
  }) async {
    try {
      var data =
          await _transactionClient.postTransactionsBuild(BuildTransaction(
        fromPublicKey: fromPublicKey,
        destinations: [
          TransactionDestination(
            address: toAddress,
            attoAlphAmount: amount,
            lockTime: lockTime,
            tokens: tokens
                ?.map<Token>((token) => Token(
                      id: token.id,
                      amount: token.amount,
                    ))
                .toList(),
          ),
        ],
        gasPrice: gasPrice,
        gasAmount: gasAmount,
      ));
      return Either<BuildTransactionResult>(data: data);
    } on Exception catch (e, trace) {
      return Either<BuildTransactionResult>(
          error: ApiError(exception: e, trace: trace));
    }
  }

  @override
  Future<Either<TxResult>> sendTransaction(
      {required String signature, required String unsignedTx}) async {
    try {
      var data = await _transactionClient.postTransactionsSubmit(
          SubmitTransaction(signature: signature, unsignedTx: unsignedTx));
      return Either<TxResult>(data: data);
    } on Exception catch (e, trace) {
      return Either<TxResult>(error: ApiError(exception: e, trace: trace));
    }
  }

  @override
  Future<Either<BuildSweepAddressTransactionsResult>> sweepTransaction({
    required String address,
    required String publicKey,
    required String toAddress,
  }) async {
    try {
      var data = await _transactionClient
          .postTransactionsSweepAddressBuild(BuildSweepAddressTransactions(
        toAddress: toAddress,
        fromPublicKey: publicKey,
      ));
      return Either<BuildSweepAddressTransactionsResult>(data: data);
    } on Exception catch (e, trace) {
      return Either<BuildSweepAddressTransactionsResult>(
          error: ApiError(exception: e, trace: trace));
    }
  }
}
