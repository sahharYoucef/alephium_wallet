import 'package:alephium_wallet/bloc/contacts/contacts_bloc.dart';
import 'package:alephium_wallet/routes/contacts/widgets/add_contact_dialog.dart';
import 'package:alephium_wallet/routes/contacts/widgets/contact_tile.dart';
import 'package:alephium_wallet/routes/wallet_details/widgets/alephium_icon.dart';
import 'package:alephium_wallet/routes/widgets/appbar_icon_button.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage>
    with AutomaticKeepAliveClientMixin {
  late final ScrollController controller;
  @override
  void initState() {
    controller = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: BlocBuilder<ContactsBloc, ContactsState>(
        buildWhen: (previous, current) => current is! ContactsErrorState,
        bloc: BlocProvider.of<ContactsBloc>(context),
        builder: (context, state) {
          if (state is ContactsLoadingState) {
            return Center(
              child: AlephiumIcon(
                spinning: true,
              ),
            );
          } else if (state is ContactsCompletedState &&
              state.contacts.isNotEmpty)
            return ListView.builder(
              padding: EdgeInsets.only(
                top: 16,
                bottom: 70 + context.bottomPadding,
                left: 16,
                right: 16,
              ),
              controller: controller,
              itemCount: state.contacts.length,
              itemBuilder: (context, index) {
                final contact = state.contacts[index];
                return ContactTile(
                  contact: contact,
                );
              },
            );
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "Addresses book is empty, Add new one to your addresses book"
                        .tr(),
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                AppBarIconButton(
                  icon: Icon(CupertinoIcons.add),
                  label: "Add contact",
                  onPressed: () {
                    showGeneralDialog(
                      barrierDismissible: true,
                      barrierLabel: "AddContactDialog",
                      context: context,
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          AddContactDialog(
                        bloc: context.read<ContactsBloc>(),
                      ),
                      transitionDuration: const Duration(milliseconds: 200),
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
                )
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
