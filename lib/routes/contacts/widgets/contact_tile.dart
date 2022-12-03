import 'package:alephium_wallet/bloc/contacts/contacts_bloc.dart';
import 'package:alephium_wallet/routes/constants.dart';
import 'package:alephium_wallet/routes/contacts/widgets/add_contact_dialog.dart';
import 'package:alephium_wallet/routes/wallet_details/widgets/address_text.dart';
import 'package:alephium_wallet/storage/models/contact_store.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContactTile extends StatelessWidget {
  final ContactStore contact;
  const ContactTile({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: PhysicalModel(
        elevation: 1,
        color: WalletTheme.instance.primary,
        borderRadius: BorderRadius.circular(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ExpansionTile(
            iconColor: WalletTheme.instance.textColor,
            collapsedIconColor: WalletTheme.instance.textColor,
            backgroundColor: WalletTheme.instance.secondary,
            collapsedBackgroundColor: WalletTheme.instance.secondary,
            title: Text(
              "${contact.firstName.capitalize} ${contact.lastName?.capitalize ?? ''}",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            subtitle: AddressText(
              address: contact.address,
            ),
            children: [
              Row(
                children: [
                  Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                    ),
                    onPressed: () {
                      context
                          .read<ContactsBloc>()
                          .add(DeleteContactEvent(id: contact.id!));
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.send,
                    ),
                    onPressed: () async {
                      final wallet = await showChooseWalletDialog(
                        context,
                        address: contact.address,
                      );
                      if (wallet != null)
                        Navigator.pushNamed(context, Routes.send, arguments: {
                          "wallet": wallet,
                          "initial-data": {"address": contact.address}
                        });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                    ),
                    onPressed: () {
                      showGeneralDialog(
                        barrierDismissible: true,
                        barrierLabel: "AddContactDialog",
                        context: context,
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            AddContactDialog(
                          contact: contact,
                          bloc: context.read<ContactsBloc>(),
                        ),
                        transitionDuration: const Duration(milliseconds: 300),
                        transitionBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: animation.drive(
                              Tween<Offset>(
                                begin: Offset(0, 1),
                                end: Offset.zero,
                              ),
                            ),
                            child: child,
                          );
                        },
                      );
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
