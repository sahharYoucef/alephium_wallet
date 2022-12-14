import 'package:alephium_dart/alephium_dart.dart';
import 'package:alephium_wallet/encryption/base_wallet_service.dart';
import 'package:alephium_wallet/storage/models/address_store.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:uuid/uuid.dart';

class AlephiumWalletService extends BaseWalletService {
  AlephiumWalletService();

  @override
  String signTransaction(String txHash, String privetKey) {
    return WalletService.signTransaction(txHash, privetKey);
  }

  @override
  String addressFromPublicKey(String publicKey) {
    return WalletService.addressFromPublicKey(publicKey);
  }

  @override
  String publicKeyFromAddress(String publicKey) {
    return WalletService.addressFromPublicKey(publicKey);
  }

  @override
  WalletStore importWallet(String mnemonic, String passphrase) {
    var wallet = WalletService.importWallet(mnemonic, passphrase);
    final String id = Uuid().v1();
    return WalletStore(
      mainAddress: wallet.addresses.first.address,
      id: id,
      mnemonic: wallet.mnemonic,
      seed: wallet.seed,
      passphrase: wallet.passphrase,
      addresses: [
        ...wallet.addresses.map(
          (address) => AddressStore(
            group: address.group,
            walletId: id,
            address: address.address,
            index: address.index,
            publicKey: address.publicKey,
            privateKey: address.privateKey,
          ),
        )
      ],
    );
  }

  @override
  WalletStore generateWallet(String passphrase) {
    var wallet = WalletService.generateWallet(passphrase);
    final String id = Uuid().v1();
    return WalletStore(
      id: id,
      mnemonic: wallet.mnemonic,
      seed: wallet.seed,
      passphrase: wallet.passphrase,
      mainAddress: wallet.addresses.first.address,
      addresses: [
        ...wallet.addresses.map(
          (address) => AddressStore(
            group: address.group,
            publicKey: address.publicKey,
            privateKey: address.privateKey,
            walletId: id,
            address: address.address,
            index: address.index,
          ),
        )
      ],
    );
  }

  @override
  AddressStore deriveNewAddress({
    required String walletId,
    required String seed,
    String? title,
    String? color,
    int forGroup = 0,
    int? index,
    List<int> skipAddressIndexes = const <int>[],
  }) {
    var address = WalletService.deriveNewAddressData(seed, forGroup,
        index: index, skipAddressIndexes: skipAddressIndexes);
    return AddressStore(
      title: title == null || title.trim().isEmpty ? null : title,
      color: color,
      group: address.group,
      privateKey: address.privateKey,
      publicKey: address.publicKey,
      address: address.address,
      index: address.index,
      walletId: walletId,
    );
  }

  List<AddressStore> generateOneAddressPerGroup({
    required WalletStore wallet,
    String? title,
    String? color,
    List<int> skipGroups = const <int>[],
  }) {
    var skipAddressIndexes = wallet.addresses.map((e) => e.index).toList();
    return List.generate(4, (index) => index)
        .where((element) => !skipGroups.contains(element))
        .map((group) => WalletService.deriveNewAddressData(wallet.seed!, group,
            skipAddressIndexes: skipAddressIndexes))
        .map((address) => AddressStore(
              title: title != null && title.trim().isEmpty ? null : title,
              color: color,
              group: address.group,
              privateKey: address.privateKey,
              publicKey: address.publicKey,
              address: address.address,
              index: address.index,
              walletId: wallet.id,
            ))
        .toList();
  }
}
