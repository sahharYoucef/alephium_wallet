import 'package:alephium_wallet/routes/wallet_details/widgets/address_text.dart';
import 'package:alephium_wallet/storage/models/contact_store.dart';
import 'package:flutter/material.dart';

class ContactTile extends StatelessWidget {
  final ContactStore contact;
  const ContactTile({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        contact.firstName,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...contact.addresses
              .take(2)
              .map((address) => AddressText(address: address))
              .toList()
        ],
      ),
    );
  }
}
