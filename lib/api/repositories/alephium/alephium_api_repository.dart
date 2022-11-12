import 'package:alephium_wallet/api/coingecko_api/coingecko_repository.dart';
import 'package:alephium_wallet/api/utils/network.dart';
import 'package:alephium_wallet/storage/models/address_store.dart';
import 'package:alephium_wallet/storage/models/balance_store.dart';
import 'package:alephium_wallet/storage/models/transaction_ref_store.dart';
import 'package:alephium_wallet/storage/models/transaction_store.dart';
import 'dart:async';

import 'package:dio/dio.dart' hide Headers;

import 'package:alephium_dart/alephium_dart.dart';

import 'package:alephium_wallet/api/dto_models/sweep_result_dto.dart';
import 'package:alephium_wallet/api/dto_models/transaction_build_dto.dart';
import 'package:alephium_wallet/api/dto_models/transaction_result_dto.dart';
import 'package:alephium_wallet/api/utils/either.dart';
import 'package:alephium_wallet/api/utils/error_handler.dart';
import 'package:alephium_wallet/api/repositories/base_api_repository.dart';
import 'package:alephium_wallet/api/repositories/alephium/utils/interceptor.dart';

class AlephiumApiRepository extends BaseApiRepository {
  late AddressClient _addressClient;
  late TransactionClient _transactionClient;
  late ExplorerClient _explorerClient;
  late CoingeckoClient _coingeckoClient;
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
  }

  set changeNetwork(Network network) {
    this.network = network;
    _transactionClient =
        TransactionClient(_dio, baseUrl: this.network.nodeHost);
    _addressClient = AddressClient(_dio, baseUrl: this.network.nodeHost);
    _explorerClient =
        ExplorerClient(_dio, baseUrl: this.network.explorerApiHost);
    _coingeckoClient = CoingeckoClient(_dio);
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
      final addressData = AddressStore(
        group: address.group,
        privateKey: address.privateKey,
        publicKey: address.publicKey,
        address: address.address,
        walletId: address.walletId,
        index: address.index,
        warning: data.warning,
        balance: BalanceStore(
          balance: double.tryParse("${data.balance}") ?? 0,
          balanceHint: double.tryParse("${data.balanceHint}") ?? 0,
          lockedBalance: double.tryParse("${data.lockedBalance}") ?? 0,
          address: address.address,
          network: network,
        ),
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
      List<TransactionStore> transactions = data
          .map((transaction) => TransactionStore(
                address: address,
                walletId: walletId,
                txStatus: TXStatus.completed,
                network: network,
                refsIn: transaction.inputs
                        ?.map((e) => TransactionRefStore(
                              transactionId: '$address${transaction.hash}',
                              address: e.address,
                              amount: e.amount,
                              txHashRef: e.txHashRef,
                              unlockScript: e.unlockScript,
                              type: "in",
                            ))
                        .toList() ??
                    [],
                refsOut: transaction.outputs
                        ?.map((e) => TransactionRefStore(
                              transactionId: '$address${transaction.hash}',
                              address: e.address,
                              amount: e.amount,
                              type: "out",
                            ))
                        .toList() ??
                    [],
                txHash: transaction.hash!,
                blockHash: transaction.blockHash,
                timeStamp: transaction.timeStamp!.toInt(),
                transactionGas: transaction.gasPrice,
                transactionAmount: transaction.gasAmount?.toInt(),
              ))
          .toList();
      return Either<List<TransactionStore>>(data: transactions);
    } on Exception catch (e, trace) {
      return Either<List<TransactionStore>>(
          error: ApiError(exception: e, trace: trace));
    }
  }

  @override
  Future<Either<TransactionBuildDto>> createTransaction(
      {required String fromPublicKey,
      required List<String> toAddresses,
      required String amount,
      num? gas,
      int? lockTime,
      String? gasPrice,
      String? gasAmount}) async {
    try {
      var data = await _transactionClient.postTransactionsBuild(
        BuildTransaction(
          fromPublicKey: fromPublicKey,
          destinations: [
            ...toAddresses.map(
              (toAddress) => TransactionDestination(
                address: toAddress,
                attoAlphAmount:
                    (double.parse(amount) * 10e17).toStringAsFixed(0),
                lockTime: lockTime,
              ),
            ),
          ],
          gasPrice: gasPrice != null && gasPrice.isNotEmpty ? gasPrice : null,
          gas: gas,
        ),
      );
      return Either<TransactionBuildDto>(
          data: TransactionBuildDto(
        unsignedTx: data.unsignedTx,
        fromGroup: data.fromGroup,
        toGroup: data.toGroup,
        txId: data.txId,
        gasAmount: data.gasAmount,
        gasPrice: data.gasPrice,
      ));
    } on Exception catch (e, trace) {
      print(trace);
      return Either<TransactionBuildDto>(
          error: ApiError(exception: e, trace: trace));
    }
  }

  @override
  Future<Either<TransactionResultDTO>> sendTransaction(
      {required String signature, required String unsignedTx}) async {
    try {
      var data = await _transactionClient.postTransactionsSubmit(
          SubmitTransaction(signature: signature, unsignedTx: unsignedTx));
      return Either<TransactionResultDTO>(
          data: TransactionResultDTO(
        txId: data.txId,
        fromGroup: data.fromGroup,
        toGroup: data.toGroup,
      ));
    } on Exception catch (e, trace) {
      return Either<TransactionResultDTO>(
          error: ApiError(exception: e, trace: trace));
    }
  }

  @override
  Future<Either<SweepResultDTO>> sweepTransaction({
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
      return Either<SweepResultDTO>(
          data: SweepResultDTO(
        unsignedTxs: data.unsignedTxs
            ?.map((e) => TransactionBuildDto.fromSweep(
                  unsignedTx: e.unsignedTx,
                  txId: e.txId,
                  gasAmount: e.gasAmount.toString(),
                  gasPrice: e.gasPrice,
                ))
            .toList(),
        fromGroup: data.fromGroup,
        toGroup: data.toGroup,
      ));
    } on Exception catch (e, trace) {
      return Either<SweepResultDTO>(
          error: ApiError(exception: e, trace: trace));
    }
  }
}
