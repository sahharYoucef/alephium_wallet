import 'package:alephium_wallet/bloc/wallet_details/wallet_details_bloc.dart';
import 'package:alephium_wallet/main.dart';
import 'package:alephium_wallet/routes/addresses/widgets/address_tile.dart';
import 'package:alephium_wallet/routes/addresses/widgets/advanced_option_dialog.dart';
import 'package:alephium_wallet/routes/addresses/widgets/generate_address_dialog.dart';
import 'package:alephium_wallet/routes/addresses/widgets/options_floating_button.dart';
import 'package:alephium_wallet/routes/widgets/wallet_appbar.dart';
import 'package:alephium_wallet/utils/constants.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants.dart';

class AddressesPage extends StatefulWidget {
  final WalletDetailsBloc bloc;
  AddressesPage({Key? key, required this.bloc}) : super(key: key);

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  var isDialOpen = ValueNotifier<bool>(false);
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
    return WillPopScope(
      onWillPop: () async {
        if (isDialOpen.value) {
          isDialOpen.value = false;
          return false;
        }
        return true;
      },
      child: Scaffold(
        floatingActionButton: widget.bloc.wallet.mnemonic != null
            ? FloatingOptionsButton(
                isDialOpen: isDialOpen,
                bloc: widget.bloc,
              )
            : null,
        body: Stack(
          children: [
            Positioned.fill(
              child: BlocBuilder<WalletDetailsBloc, WalletDetailsState>(
                bloc: widget.bloc,
                buildWhen: (previous, current) {
                  return current is WalletDetailsCompleted;
                },
                builder: (context, state) {
                  return ListView.builder(
                      controller: controller,
                      padding: EdgeInsets.only(
                        top: 20 + 70 + context.topPadding,
                        bottom: 32,
                      ),
                      itemCount: widget.bloc.wallet.addresses.length,
                      itemBuilder: (context, index) {
                        final address = widget.bloc.wallet.addresses[index];
                        bool isMain =
                            widget.bloc.wallet.mainAddress == address.address;
                        return AddressTile(
                          address: address,
                          isMain: isMain,
                          onTap: () {
                            if (address.privateKey == null) return;
                            Navigator.pushNamed(context, Routes.send,
                                arguments: {
                                  "wallet": widget.bloc.wallet,
                                  "wallet-details": widget.bloc,
                                  "address": address,
                                });
                          },
                        );
                      });
                },
              ),
            ),
            WalletAppBar(
              controller: controller,
              label: Text(
                'Wallet Addresses',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
