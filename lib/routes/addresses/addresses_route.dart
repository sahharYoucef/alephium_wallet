import 'package:alephium_wallet/bloc/wallet_details/wallet_details_bloc.dart';
import 'package:alephium_wallet/routes/addresses/widgets/addresses_list_view.dart';
import 'package:alephium_wallet/routes/addresses/widgets/options_floating_button.dart';
import 'package:alephium_wallet/routes/widgets/wallet_appbar.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../constants.dart';

class AddressesPage extends StatefulWidget {
  final WalletDetailsBloc? bloc;
  final WalletStore? wallet;
  AddressesPage({Key? key, this.bloc, this.wallet}) : super(key: key);

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
        floatingActionButton:
            widget.bloc != null && widget.bloc!.wallet.type == WalletType.normal
                ? FloatingOptionsButton(
                    isDialOpen: isDialOpen,
                    bloc: widget.bloc!,
                  )
                : null,
        body: Stack(
          children: [
            if (widget.bloc == null && widget.wallet != null)
              AddressesListView(
                addresses: widget.wallet!.addresses,
                mainAddress: widget.wallet?.mainAddress,
                onTap: (address) {
                  if (widget.wallet!.type != WalletType.multisig)
                    Navigator.pop<String>(context, address.publicKey);
                },
              )
            else
              Positioned.fill(
                child: BlocBuilder<WalletDetailsBloc, WalletDetailsState>(
                  bloc: widget.bloc,
                  buildWhen: (previous, current) {
                    return current is WalletDetailsCompleted;
                  },
                  builder: (context, state) {
                    return AddressesListView(
                      addresses: widget.bloc!.wallet.addresses,
                      mainAddress: widget.bloc?.wallet.mainAddress,
                      onTap: (address) {
                        if (widget.bloc!.wallet.type == WalletType.readOnly)
                          return;
                        Navigator.pushNamed(context, Routes.send, arguments: {
                          "wallet": widget.bloc!.wallet,
                          "wallet-details": widget.bloc,
                          "address": address,
                        });
                      },
                    );
                  },
                ),
              ),
            WalletAppBar(
              controller: controller,
              label: Text(
                'walletAddresses'.tr(),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
