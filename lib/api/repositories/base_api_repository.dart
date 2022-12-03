import 'dart:async';

import 'package:alephium_dart/alephium_dart.dart';
import 'package:alephium_wallet/api/utils/network.dart';
import 'package:alephium_wallet/storage/models/address_store.dart';
import 'package:alephium_wallet/storage/models/token_store.dart';

import '../../storage/models/transaction_store.dart';
import '../utils/either.dart';

abstract class BaseApiRepository {
  Network network;

  BaseApiRepository(this.network);

  Future<Either<double>> getPrice({String coin, String currency = "usd"});

  Future<Either<NodeVersion>> getNodeVersion();

  Future<Either<AddressStore>> getAddressBalance({
    required AddressStore address,
  });

  FutureOr<Either<List<TransactionStore>>> getAddressTransactions({
    required String address,
    required String walletId,
  });

  FutureOr<Either<BuildTransactionResult>> createTransaction({
    required String fromPublicKey,
    required String toAddress,
    required BigInt amount,
    int? lockTime,
    BigInt? gasPrice,
    int? gasAmount,
    List<TokenStore>? tokens,
  });

  FutureOr<Either<TxResult>> sendTransaction({
    required String signature,
    required String unsignedTx,
  });

  FutureOr<Either<BuildSweepAddressTransactionsResult>> sweepTransaction({
    required String address,
    required String publicKey,
    required String toAddress,
  });

  FutureOr<Either<BuildMultisigAddressResult>> multisigAddress({
    required List<String> signatures,
    required int mrequired,
  });

  FutureOr<Either<BuildTransactionResult>> buildMultisigTx({
    required List<String> fromPublicKey,
    required String toAddress,
    required String fromAddress,
    required BigInt amount,
    int? lockTime,
    BigInt? gasPrice,
    int? gasAmount,
    List<TokenStore>? tokens,
  });

  FutureOr<Either<TxResult>> submitMultisigTx({
    required List<String> signatures,
    required String unsignedTx,
  });
}
