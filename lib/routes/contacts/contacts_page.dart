import 'package:alephium_wallet/bloc/contacts/contacts_bloc.dart';
import 'package:alephium_wallet/routes/contacts/widgets/add_contact_dialog.dart';
import 'package:alephium_wallet/routes/contacts/widgets/contact_tile.dart';
import 'package:alephium_wallet/routes/wallet_details/widgets/alephium_icon.dart';
import 'package:alephium_wallet/routes/widgets/appbar_icon_button.dart';
import 'package:alephium_wallet/routes/widgets/wallet_appbar.dart';
import 'package:alephium_wallet/utils/helpers.dart';
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
          } else if (state is ContactsCompletedState)
            return ListView.builder(
              padding: EdgeInsets.only(
                top: 16,
                bottom: 16,
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
          return SizedBox();
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
