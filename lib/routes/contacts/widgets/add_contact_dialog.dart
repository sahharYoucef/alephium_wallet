import 'package:alephium_wallet/bloc/contacts/contacts_bloc.dart';
import 'package:alephium_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:alephium_wallet/routes/send/widgets/shake_form_field.dart';
import 'package:alephium_wallet/routes/send/widgets/to_address_field.dart';
import 'package:alephium_wallet/storage/models/contact_store.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:alephium_wallet/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AddContactDialog extends StatefulWidget {
  final ContactsBloc bloc;
  final ContactStore? contact;
  AddContactDialog({
    Key? key,
    required this.bloc,
    this.contact,
  }) : super(key: key);

  @override
  State<AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<AddContactDialog>
    with InputValidators {
  final GlobalKey<ShakeFormState> _formKey = GlobalKey<ShakeFormState>();
  String? firstName;
  String? lastName;
  String? address;

  @override
  void initState() {
    firstName = widget.contact?.firstName;
    lastName = widget.contact?.lastName;
    address = widget.contact?.address;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: MediaQuery.of(context).viewInsets,
        width: MediaQuery.of(context).size.width * .70,
        child: Material(
            elevation: 3,
            borderRadius: BorderRadius.circular(16.0),
            color: WalletTheme.instance.background,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ShakeForm(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "addNewAddress".tr(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(),
                    const SizedBox(
                      height: 10,
                    ),
                    ShakeTextFormField(
                      validator: nameValidator,
                      initialValue: firstName,
                      onChanged: (value) {
                        firstName = value;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      autofocus: true,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: InputDecoration(
                        label: Text(
                          "firstName".tr(),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ShakeTextFormField(
                      validator: nameValidator,
                      initialValue: lastName,
                      onChanged: (value) {
                        lastName = value;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: InputDecoration(
                        label: Text(
                          "lastName".tr(),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ToAddressField(
                      validator: addressToValidator,
                      initialValue: address,
                      label: "address".tr(),
                      onChanged: (value) {
                        address = value;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Hero(
                      tag: "button",
                      child: OutlinedButton(
                        onPressed: () {
                          final isValid =
                              _formKey.currentState?.validate(shake: true);
                          if (isValid ?? false) {
                            if (widget.contact != null) {
                              widget.bloc.add(UpdateContactEvent(
                                  id: widget.contact!.id!,
                                  contact: ContactStore(
                                      firstName: firstName!,
                                      address: address!,
                                      lastName: lastName!)));
                            } else {
                              widget.bloc.add(AddNewContactEvent(
                                  contact: ContactStore(
                                      firstName: firstName!,
                                      address: address!,
                                      lastName: lastName!)));
                            }
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          widget.contact != null
                              ? "updateContact".tr()
                              : "addContact".tr(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }

  @override
  TransactionBloc? get bloc => null;

  @override
  WalletStore? get wallet => null;
}
