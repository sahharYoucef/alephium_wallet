import 'package:alephium_wallet/api/utils/constants.dart';
import 'package:bloc/bloc.dart';
import 'package:alephium_wallet/api/repositories/base_api_repository.dart';
import 'package:alephium_wallet/encryption/base_wallet_service.dart';
import 'package:alephium_wallet/main.dart';
import 'package:alephium_wallet/storage/base_db_helper.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../storage/models/wallet_store.dart';

part 'create_wallet_event.dart';
part 'create_wallet_state.dart';

class CreateWalletBloc extends Bloc<CreateWalletEvent, CreateWalletState> {
  late BaseApiRepository apiRepository;
  late BaseWalletService walletService;

  CreateWalletBloc() : super(CreateWalletInitial()) {
    apiRepository = getIt.get<BaseApiRepository>();
    walletService = getIt.get<BaseWalletService>();
    on<CreateWalletEvent>((event, emit) async {
      if (event is CreateWalletMultisigWallet) {
        try {
          emit(GenerateWalletLoading());
          final data = await apiRepository.multisigAddress(
            signatures: event.signatures,
            mrequired: event.mrequired,
          );
          if (data.hasException || data.data?.address == null) {
            emit(CreateWalletFailure(
              error: kErrorMessageGenericError,
            ));
            return;
          }
          final wallet = WalletStore.multisig(
            signatures: [...event.signatures],
            mrequired: event.mrequired,
            address: data.data!.address!,
            title: event.title,
          );
          add(SaveWalletToDatabase(wallet: wallet));
        } catch (e) {
          emit(CreateWalletFailure(error: e.toString()));
        }
      } else if (event is CreateWalletGenerateMnemonic) {
        emit(GenerateWalletLoading());
        var wallet = await compute<String, WalletStore>(
            walletService.generateWallet, event.passphrase);
        emit(
          CreateWalletGenerateMnemonicSuccess(
            wallet: wallet,
          ),
        );
      } else if (event is SaveWalletToDatabase) {
        try {
          await getIt.get<BaseDBHelper>().insertWallet(
                event.wallet,
                event.wallet.addresses,
              );
          final box = await Hive.openBox("settings");
          var firstRun = box.get("firstRun");
          if (firstRun) {
            box.put("firstRun", false);
          }
          emit(
            SaveWalletToDatabaseSuccess(
              wallet: event.wallet,
            ),
          );
        } catch (e) {
          emit(CreateWalletFailure(error: e.toString()));
        }
      } else if (event is CreateWalletRestore) {
        try {
          emit(GenerateWalletLoading());
          var wallet = walletService.importWallet(event.mnemonic, "");
          add(SaveWalletToDatabase(wallet: wallet));
        } on Exception catch (e) {
          emit(CreateWalletFailure(error: e.toString()));
        }
      } else if (event is AddReadOnlyWallet) {
        try {
          var validator = RegExp(r'^[1-9A-HJ-NP-Za-km-z]+$');
          late final String address;
          late final String publicKey;
          if (validator.hasMatch(event.value)) {
            address = event.value;
            publicKey = walletService.addressFromPublicKey(event.value);
          } else {
            address = walletService.addressFromPublicKey(event.value);
            publicKey = event.value;
          }
          add(
            SaveWalletToDatabase(
              wallet: WalletStore.redOnly(
                address: address,
                publicKey: publicKey,
                title: event.title,
              ),
            ),
          );
        } on Exception catch (e) {
          emit(CreateWalletFailure(error: e.toString()));
        }
      }
    });
  }
}
