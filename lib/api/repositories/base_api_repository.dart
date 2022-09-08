import 'dart:async';

import 'package:alephium_wallet/storage/models/address_store.dart';

import '../../storage/models/transaction_store.dart';
import '../dto_models/sweep_result_dto.dart';
import '../dto_models/transaction_build_dto.dart';
import '../dto_models/transaction_result_dto.dart';
import '../utils/either.dart';

abstract class BaseApiRepository {
  Future<Either<double>> getPrice({String coin, String currency = "usd"});
  Future<Either<AddressStore>> getAddressBalance({
    required AddressStore address,
  });
  FutureOr<Either<List<TransactionStore>>> getAddressTransactions(
      {required String address, required String walletId});
  FutureOr<Either<TransactionBuildDto>> createTransaction(
      {required String fromPublicKey,
      required String toAddress,
      required String amount,
      num? gas,
      int? lockTime,
      String? gasPrice,
      String? gasAmount});
  FutureOr<Either<TransactionResultDTO>> sendTransaction(
      {required String signature, required String unsignedTx});
  FutureOr<Either<SweepResultDTO>> sweepTransaction({
    required String address,
    required String publicKey,
    required String toAddress,
  });
}
