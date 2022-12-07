import 'package:alephium_wallet/storage/models/address_store.dart';

import '../storage/models/wallet_store.dart';

abstract class BaseWalletService {
  BaseWalletService();

  WalletStore generateWallet(String passphrase);
  String addressFromPublicKey(String publicKey);
  String publicKeyFromAddress(String publicKey);
  WalletStore importWallet(String mnemonic, String passphrase);
  AddressStore deriveNewAddress({
    required String walletId,
    required String seed,
    String? title,
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
}
