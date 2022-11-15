import 'package:alephium_wallet/api/dto_models/balance_dto.dart';
import 'package:alephium_wallet/storage/models/address_store.dart';

import '../storage/models/wallet_store.dart';

abstract class BaseWalletService {
  BaseWalletService(this.blockchain);

  WalletStore generateWallet(String passphrase);
  String addressFromPublicKey(String publicKey);
  WalletStore importWallet(String mnemonic, String passphrase);
  AddressStore deriveNewAddress({
    required String walletId,
    required String seed,
    int forGroup,
    int index,
    List<int> skipAddressIndexes = const <int>[],
  });
  String signTransaction(String txHash, String privetKey);
  List<AddressStore> generateOneAddressPerGroup({
    required WalletStore wallet,
    String? title,
    String? color,
    List<int> skipGroups = const <int>[],
  });

  final Blockchain blockchain;
}
