import 'package:alephium_wallet/main.dart';
import 'package:alephium_wallet/services/authentication_service.dart';
import 'package:alephium_wallet/storage/app_storage.dart';
import 'package:alephium_wallet/storage/base_db_helper.dart';
import 'package:bloc/bloc.dart';
import 'package:alephium_wallet/api/dto_models/transaction_build_dto.dart';
import 'package:alephium_wallet/api/dto_models/transaction_result_dto.dart';
import 'package:alephium_wallet/api/repositories/base_api_repository.dart';
import 'package:alephium_wallet/api/utils/either.dart';
import 'package:alephium_wallet/encryption/base_wallet_service.dart';
import 'package:alephium_wallet/storage/models/address_store.dart';
import 'package:alephium_wallet/storage/models/transaction_ref_store.dart';
import 'package:alephium_wallet/storage/models/transaction_store.dart';
import 'package:equatable/equatable.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../storage/models/wallet_store.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  String? amount;
  AddressStore? fromAddress;
  String? _gas;
  String? gasPrice;
  List<String> toAddresses = <String>[];
  String? txId;
  String? signature;
  String? unsignedTx;
  TransactionBuildDto? transaction;
  final AuthenticationService authenticationService;

  bool get activateButton {
    return amount != null && toAddresses.isNotEmpty && fromAddress != null;
  }

  double? get gas {
    return double.tryParse("${_gas}");
  }

  String get balance {
    var _balance = fromAddress?.formattedBalance ?? "";
    return _balance;
  }

  String get total {
    var _amount = double.tryParse("${amount}");
    if (_amount == null) {
      return '???';
    }
    return (expectedFeesValue + _amount).toStringAsFixed(3);
  }

  double get expectedFeesValue {
    var _gasPrice = double.tryParse("${transaction?.gasPrice}");
    var _gasAmount = double.tryParse("${transaction?.gasAmount}");
    if (_gasAmount == null || _gasPrice == null) {
      return 0;
    }
    return (_gasAmount * _gasPrice) / 10e17;
  }

  String get expectedFees {
    var _gasPrice = double.tryParse("${transaction?.gasPrice}");
    var _gasAmount = double.tryParse("${transaction?.gasAmount}");
    if (_gasAmount == null || _gasPrice == null) {
      return "0";
    }
    return ((_gasAmount * _gasPrice) / 10e17).toStringAsFixed(3);
  }

  final WalletStore wallet;
  final BaseApiRepository apiRepository;
  final BaseWalletService walletService;
  TransactionBloc(
    this.authenticationService,
    this.apiRepository,
    this.walletService,
    this.wallet,
  ) : super(TransactionStatusState(
          toAddresses: [],
        )) {
    on<TransactionEvent>((event, emit) async {
      if (event is TransactionValuesChangedEvent) {
        if (event.fromAddress != null) {
          fromAddress = event.fromAddress!;
        }
        if (event.amount != null) {
          amount = event.amount;
          if (event.amount!.isEmpty) amount = null;
        }
        if (event.gas != null) {
          _gas = event.gas;
          if (event.gas!.isEmpty) _gas = null;
        }
        if (event.gasPrice != null) {
          gasPrice = event.gasPrice;
          if (event.gasPrice!.isEmpty) gasPrice = null;
        }
        if (event.toAddresses != null) {
          toAddresses = event.toAddresses!;
        }
        transaction = null;
        emit(TransactionStatusState(
          fromAddress: fromAddress?.address,
          amount: amount,
          toAddresses: toAddresses,
        ));
      } else if (event is CheckTransactionEvent) {
        try {
          emit(TransactionLoading());
          if (!activateButton) {
            return;
          }
          var data = await apiRepository.createTransaction(
            amount: amount!,
            fromPublicKey: fromAddress!.publicKey!,
            toAddresses: toAddresses,
            gas: gas,
            gasPrice: gasPrice,
          );
          if (data.hasException || data.getData == null) {
            emit(TransactionError(
              message: data.getException?.message ?? 'Unknown error',
            ));
            return;
          }
          transaction = data.getData;
          emit(TransactionStatusState(
            transaction: data.getData!,
            toAddresses: toAddresses,
          ));
        } catch (e) {
          emit(TransactionError(
            message: e.toString(),
          ));
        }
      } else if (event is SweepTransaction) {
        emit(TransactionLoading());
        var sending = await apiRepository.sweepTransaction(
          publicKey: event.fromAddress.publicKey!,
          address: event.fromAddress.address,
          toAddress: event.toAddress.address,
        );
        if (sending.hasException ||
            sending.getData == null ||
            sending.getData?.unsignedTxs == null) {
          emit(TransactionError(
            message: sending.getException?.message ?? 'Unknown error',
          ));
          return;
        }
        var transactions = await Future.wait<Either<TransactionResultDTO>>([
          ...sending.getData!.unsignedTxs!.map((value) async {
            var signature = walletService.signTransaction(
                value.txId!, event.fromAddress.privateKey!);
            var data = await apiRepository.sendTransaction(
              signature: signature,
              unsignedTx: value.unsignedTx!,
            );
            return data;
          })
        ]);
        var data = <TransactionStore>[];
        for (var value in transactions) {
          if (value.hasException || value.getData == null) {
            emit(TransactionError(
              message: sending.getException?.message ?? 'Unknown error',
            ));
            return;
          }
          data.add(_createTransaction(
              value.getData!, event.fromAddress, [event.toAddress.address]));
        }
        emit(
          TransactionSendingCompleted(
            transactions: data,
          ),
        );
      } else if (event is SignAndSendTransaction) {
        try {
          if (AppStorage.instance.localAuth) {
            final didAuthenticate = await authenticationService.authenticate(
              "authenticateToSendTransaction".tr(),
            );
            if (!didAuthenticate) {
              emit(TransactionError(
                message: 'Unknown error',
              ));
              return;
            }
          }
          if (fromAddress?.privateKey == null) return;
          emit(TransactionLoading());
          var signature = walletService.signTransaction(
            transaction!.txId!,
            fromAddress!.privateKey!,
          );
          var sending = await apiRepository.sendTransaction(
            signature: signature,
            unsignedTx: transaction!.unsignedTx!,
          );
          if (sending.hasException || sending.getData == null) {
            emit(TransactionError(
              message: sending.getException?.message ?? 'Unknown error',
            ));
            return;
          }
          var data =
              _createTransaction(sending.getData!, fromAddress!, toAddresses);
          if (getIt.get<BaseDBHelper>().transactions[apiRepository.network.name]
                  ?[wallet.id] ==
              null) {
            getIt.get<BaseDBHelper>().transactions[apiRepository.network.name]
                ?[wallet.id] = [data];
          } else
            getIt
                .get<BaseDBHelper>()
                .transactions[apiRepository.network.name]?[wallet.id]
                ?.addAll([data]);
          getIt.get<BaseDBHelper>().insertTransactions(wallet.id, [data]);
          emit(
            TransactionSendingCompleted(
              transactions: [data],
            ),
          );
        } catch (e) {
          emit(TransactionError(
            message: e.toString(),
          ));
        }
      }
    });
  }

  TransactionStore _createTransaction(TransactionResultDTO value,
      AddressStore _fromAddress, List<String> _toAddresses) {
    var data = TransactionStore(
      address: _fromAddress.address,
      walletId: wallet.id,
      timeStamp: DateTime.now().millisecondsSinceEpoch,
      txStatus: TXStatus.pending,
      txHash: value.txId!,
      transactionAmount: int.tryParse("${transaction?.gasPrice}"),
      transactionGas: transaction?.gasAmount,
      network: apiRepository.network,
    );
    var fee = data.fee.parseToAlphValue;
    data = data.copyWith(
      refsIn: [
        TransactionRefStore(
          address: _fromAddress.address,
          amount: amount?.parseToAlphValue.toString(),
          transactionId: data.id,
          type: "in",
        ),
        TransactionRefStore(
          address: _fromAddress.address,
          amount: fee.toString(),
          transactionId: data.id,
          type: "in",
        )
      ],
      refsOut: [
        ..._toAddresses.map(
          (_toAddress) => TransactionRefStore(
            address: _toAddress,
            amount: amount?.parseToAlphValue.toString(),
            transactionId: data.id,
            type: "out",
          ),
        ),
      ],
    );
    return data;
  }
}

extension _Parser on String {
  int get parseToAlphValue {
    return ((double.tryParse('${this}') ?? 0.0) * 10e17).toInt();
  }
}
