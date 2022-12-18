import 'package:alephium_dart/alephium_dart.dart';
import 'package:alephium_wallet/api/repositories/base_api_repository.dart';
import 'package:alephium_wallet/api/utils/constants.dart';
import 'package:alephium_wallet/api/utils/error_handler.dart';
import 'package:alephium_wallet/encryption/base_wallet_service.dart';
import 'package:alephium_wallet/services/authentication_service.dart';
import 'package:alephium_wallet/storage/app_storage.dart';
import 'package:alephium_wallet/storage/models/address_store.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:easy_localization/easy_localization.dart';

part 'sign_tx_event.dart';
part 'sign_tx_state.dart';

class SignTxBloc extends Bloc<SignTxEvent, SignTxState> {
  final BaseWalletService walletService;
  final BaseApiRepository repository;
  String? txId;
  String? unsignedTx;
  AddressStore? addressStore;
  final AuthenticationService authenticationService;

  bool get activateButton {
    return txId != null && addressStore != null;
  }

  SignTxBloc(
    this.walletService,
    this.authenticationService,
    this.repository,
  ) : super(SignTxUpdateStatus()) {
    on<SignTxEvent>((event, emit) async {
      if (event is UpdateSignTxDataEvent) {
        txId = event.txId;
        unsignedTx = event.unsignedTx;
        addressStore = event.address;
        emit(SignTxUpdateStatus(
          walletStore: event.walletStore,
          txId: txId,
          address: addressStore,
        ));
      } else if (event is ResetSignTxEvent) {
        emit(SignTxUpdateStatus(
          txId: txId,
          address: addressStore,
          reset: true,
        ));
      } else if (event is VerifyMultisigTransaction) {
        try {
          emit(SignTxLoading());
          final data =
              await repository.decodeTransaction(unsignedTx: unsignedTx!);
          if (data.hasException || data.data == null) {
            emit(SignTxError(
              message: data.exception?.message ?? 'Unknown error',
            ));
            return;
          }
          if (data.data!.unsignedTx!.txId != txId) {
            emit(SignTxError(
              message: "invalidTransactionDetails".tr(),
            ));
            return;
          }
          emit(
            TxIdVerifyCompleted(
              tx: data.data!,
              unsignedTx: unsignedTx!,
            ),
          );
        } catch (e, trace) {
          emit(SignTxError(
            message: ApiError(exception: e, trace: trace).message,
          ));
        }
      } else if (event is SignMultisigTransaction) {
        try {
          emit(SignTxLoading());
          if (AppStorage.instance.localAuth) {
            final didAuthenticate = await authenticationService.authenticate(
              "authenticateToSignTransaction".tr(),
            );
            if (!didAuthenticate) {
              emit(SignTxError(
                message: kErrorMessageGenericError,
              ));
              return;
            }
          }
          if (addressStore?.privateKey == null || txId == null) {
            emit(SignTxError(
              message: kErrorMessageGenericError,
            ));
            return;
          }
          var signature = walletService.signTransaction(
            txId!,
            addressStore!.privateKey!,
          );
          emit(
            SignTxCompleted(
              signature: signature,
            ),
          );
        } catch (e, trace) {
          emit(SignTxError(
            message: ApiError(exception: e, trace: trace).message,
          ));
        }
      }
    });
  }
}
