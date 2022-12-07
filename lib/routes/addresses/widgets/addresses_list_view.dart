import 'package:alephium_wallet/routes/addresses/widgets/address_tile.dart';
import 'package:alephium_wallet/storage/models/address_store.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:flutter/material.dart';

class AddressesListView extends StatelessWidget {
  final List<AddressStore> addresses;
  final String? mainAddress;
  final void Function(AddressStore) onTap;
  const AddressesListView({
    super.key,
    required this.addresses,
    required this.onTap,
    this.mainAddress,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: EdgeInsets.only(
          top: 20 + 70 + context.topPadding,
          bottom: 32,
        ),
        itemCount: addresses.length,
        itemBuilder: (context, index) {
          final address = addresses[index];
          bool isMain = mainAddress == address.address;
          return AddressTile(
            address: address,
            isMain: isMain,
            onTap: () {
              onTap(address);
            },
          );
        });
  }
}
