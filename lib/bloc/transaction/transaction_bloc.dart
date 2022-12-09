import 'package:alephium_dart/alephium_dart.dart';
import 'package:alephium_wallet/api/utils/constants.dart';
import 'package:alephium_wallet/api/utils/error_handler.dart';
import 'package:alephium_wallet/api/utils/network.dart';
import 'package:alephium_wallet/main.dart';
import 'package:alephium_wallet/services/authentication_service.dart';
import 'package:alephium_wallet/storage/app_storage.dart';
import 'package:alephium_wallet/storage/base_db_helper.dart';
import 'package:alephium_wallet/storage/models/token_store.dart';
import 'package:alephium_wallet/utils/format.dart';
import 'package:bloc/bloc.dart';
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
  AddressStore? fromAddress;
  double? amount;
  int? gasAmount;
  BigInt? gasPrice;
  String? toAddress;
  String? txId;
  String? signature;
  BuildTransactionResult? transaction;
  List<TokenStore> tokens = [];
  final AuthenticationService authenticationService;

  bool get activateButton {
    return (tokens.isNotEmpty || amount != null) &&
        toAddress != null &&
        fromAddress != null;
  }

  String get formattedAmount {
    return "${Format.formatNumber(amount)} ℵ";
  }

  String? get balance {
    final _balance = fromAddress?.formattedBalance;
    return _balance;
  }

  String get expectedFees {
    var _gasPrice = transaction?.gasPrice?.toDouble();
    var _gasAmount = transaction?.gasAmount?.toDouble();
    if (_gasAmount == null || _gasPrice == null) {
      return "0 ℵ";
    }
    final value = (_gasAmount * _gasPrice / 10e17).toStringAsFixed(3);
    return "$value ℵ";
  }

  final WalletStore wallet;
  final BaseApiRepository apiRepository;
  final BaseWalletService walletService;
  late final NetworkType network;
  TransactionBloc(
    this.authenticationService,
    this.apiRepository,
    this.walletService,
    this.wallet,
  )   : network = apiRepository.network,
        super(TransactionStatusState()) {
    on<TransactionEvent>((event, emit) async {
      if (event is TransactionValuesChangedEvent) {
        if (event.fromAddress != null) {
          fromAddress = event.fromAddress!;
        }
        if (event.amount != null) {
          amount = double.tryParse(event.amount!);
          if (event.amount!.isEmpty) amount = null;
        }
        if (event.gas != null) {
          gasAmount = int.tryParse(event.gas!);
          if (event.gas!.isEmpty) gasAmount = null;
        }
        if (event.gasPrice != null) {
          gasPrice = BigInt.tryParse(event.gasPrice!);
          if (event.gasPrice!.isEmpty) gasPrice = null;
        }
        if (event.toAddress != null) {
          toAddress = event.toAddress;
          if (event.toAddress!.isEmpty) toAddress = null;
        }
        transaction = null;
        emit(TransactionStatusState(
          fromAddress: fromAddress?.address,
          amount: amount,
          toAddress: toAddress,
          tokens: List.from(tokens),
        ));
      } else if (event is AddTokenTransactionEvent) {
        final index = tokens.indexWhere((element) => element.id == event.id);
        final token =
            TokenStore(id: event.id, amount: BigInt.tryParse(event.amount));
        if (index == -1)
          tokens.add(token);
        else
          tokens[index] = token;
        transaction = null;
        emit(TransactionStatusState(
          fromAddress: fromAddress?.address,
          amount: amount,
          toAddress: toAddress,
          tokens: List.from(tokens),
        ));
      } else if (event is DeleteTokenTransactionEvent) {
        tokens.removeWhere((element) => element.id == event.id);
        transaction = null;
        emit(TransactionStatusState(
          fromAddress: fromAddress?.address,
          amount: amount,
          toAddress: toAddress,
          transaction: transaction,
          tokens: List.from(tokens),
        ));
      } else if (event is CheckTransactionEvent) {
        try {
          emit(TransactionLoading());
          if (!activateButton) {
            return;
          }
          if (wallet.type == WalletType.normal) {
            var data = await apiRepository.createTransaction(
              amount: amount?.parseToAlphValue ?? BigInt.zero,
              fromPublicKey: fromAddress!.publicKey!,
              toAddress: toAddress!,
              gasAmount: gasAmount,
              gasPrice: gasPrice,
              tokens: tokens.isEmpty ? null : tokens,
            );
            if (data.hasException || data.data == null) {
              emit(TransactionError(
                message: data.exception?.message ?? 'Unknown error',
              ));
              return;
            }
            transaction = data.data;
          } else if (wallet.type == WalletType.multisig) {
            var data = await apiRepository.buildMultisigTx(
              fromAddress: fromAddress!.address,
              amount: amount?.parseToAlphValue ?? BigInt.zero,
              fromPublicKey: [...wallet.signatures!],
              toAddress: toAddress!,
              gasAmount: gasAmount,
              gasPrice: gasPrice,
              tokens: tokens.isEmpty ? null : tokens,
            );
            if (data.hasException || data.data == null) {
              emit(TransactionError(
                message: data.exception?.message ?? 'Unknown error',
              ));
              return;
            }
            transaction = data.data;
          }
          emit(TransactionStatusState(
            transaction: transaction,
            tokens: tokens,
          ));
        } catch (e, trace) {
          emit(TransactionError(
            message: ApiError(exception: e, trace: trace).message,
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
            sending.data == null ||
            sending.data?.unsignedTxs == null) {
          emit(TransactionError(
            message: sending.exception?.message ?? 'Unknown error',
          ));
          return;
        }
        var transactions = await Future.wait<Either<TxResult>>([
          ...sending.data!.unsignedTxs!.map((value) async {
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
          if (value.hasException || value.data == null) {
            emit(TransactionError(
              message: sending.exception?.message ?? 'Unknown error',
            ));
            return;
          }
          data.add(_createTransaction(
              value.data!, event.fromAddress, event.toAddress.address));
        }
        await getIt.get<BaseDBHelper>().insertTransactions(wallet.id, data);
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
          if (sending.hasException || sending.data == null) {
            emit(TransactionError(
              message: sending.exception?.message ?? 'Unknown error',
            ));
            return;
          }
          var data =
              _createTransaction(sending.data!, fromAddress!, toAddress!);
          await getIt.get<BaseDBHelper>().insertTransactions(wallet.id, [data]);
          emit(
            TransactionSendingCompleted(
              transactions: [data],
            ),
          );
        } catch (e, trace) {
          emit(TransactionError(
            message: ApiError(exception: e, trace: trace).message,
          ));
        }
      } else if (event is CheckSignMultisigTransaction) {
        try {
          emit(TransactionLoading());
          var addresses = <String>[];
          for (final signature in wallet.signatures!) {
            addresses.add(walletService.addressFromPublicKey(signature));
          }
          emit(
            WaitForOtherSignatureState(
              addresses: addresses,
              txId: transaction!.txId!,
            ),
          );
        } catch (e, trace) {
          emit(TransactionError(
            message: ApiError(exception: e, trace: trace).message,
          ));
        }
      } else if (event is SendMultisigTransaction) {
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
          emit(TransactionLoading());
          var sending = await apiRepository.submitMultisigTx(
            signatures: event.signatures,
            unsignedTx: transaction!.unsignedTx!,
          );
          if (sending.hasException || sending.data == null) {
            emit(TransactionError(
              message: sending.exception?.message ?? 'Unknown error',
            ));
            return;
          }
          var data =
              _createTransaction(sending.data!, fromAddress!, toAddress!);
          await getIt.get<BaseDBHelper>().insertTransactions(wallet.id, [data]);
          emit(
            TransactionSendingCompleted(
              transactions: [data],
            ),
          );
        } catch (e, trace) {
          emit(TransactionError(
            message: ApiError(exception: e, trace: trace).message,
          ));
        }
      }
    });
  }

  TransactionStore _createTransaction(
      TxResult value, AddressStore _fromAddress, String _toAddress) {
    var data = TransactionStore(
      transactionID: value.txId ?? "",
      address: _fromAddress.address,
      walletId: wallet.id,
      timeStamp: DateTime.now().millisecondsSinceEpoch,
      status: TXStatus.pending,
      txHash: value.txId!,
      gasPrice: transaction?.gasPrice,
      gasAmount: transaction?.gasAmount,
      network: network,
    );
    var fee = data.feeValue;
    data = data.copyWith(
      refsIn: [
        TransactionRefStore(
          address: _fromAddress.address,
          amount: amount?.parseToAlphValue,
          tokens: tokens,
        ),
        TransactionRefStore(
          address: _fromAddress.address,
          amount: fee,
        )
      ],
      refsOut: [
        TransactionRefStore(
          address: _toAddress,
          amount: amount?.parseToAlphValue,
          tokens: tokens,
        ),
      ],
    );
    return data;
  }
}

extension _Parser on double {
  BigInt get parseToAlphValue {
    return BigInt.from(this * 10e17);
  }
}
