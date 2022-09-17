import 'package:alephium_wallet/bloc/wallet_details/wallet_details_bloc.dart';
import 'package:alephium_wallet/bloc/wallet_home/wallet_home_bloc.dart';
import 'package:alephium_wallet/bloc/wallet_setting/wallet_setting_bloc.dart';
import 'package:alephium_wallet/routes/constants.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/routes/wallet_settings/widgets/wallet_data_dialog.dart';
import 'package:alephium_wallet/routes/widgets/confirmation_dialog.dart';
import 'package:alephium_wallet/routes/widgets/wallet_appbar.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WalletSetting extends StatefulWidget {
  final WalletDetailsBloc detailsBloc;
  const WalletSetting({
    Key? key,
    required this.detailsBloc,
  }) : super(key: key);

  @override
  State<WalletSetting> createState() => _WalletSettingState();
}

class _WalletSettingState extends State<WalletSetting> {
  late FocusNode _focusNode;
  late final WalletSettingBloc _settingBloc;
  late final GlobalKey<FormFieldState> _nameKey;
  late final ScrollController controller;

  @override
  void initState() {
    _nameKey = GlobalKey<FormFieldState>();
    _settingBloc = WalletSettingBloc(widget.detailsBloc.wallet);
    _focusNode = FocusNode();
    controller = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _settingBloc.close();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletSettingBloc, WalletSettingState>(
      bloc: _settingBloc,
      listener: (context, state) {
        if (state is WalletSettingDisplayDataState) {
          showDialog(
              context: context,
              builder: (_) {
                return WalletSettingDataDialog(
                  title: state.title,
                  data: state.data,
                );
              });
        } else if (state is WalletSettingErrorState) {
          context.showSnackBar(state.message, level: Level.error);
        }
      },
      child: GestureDetector(
        onTap: () {
          _focusNode.unfocus();
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Column(
            children: [
              WalletAppBar(
                controller: controller,
                label: Text(
                  'Wallet setting',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                action: IconButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) => WalletConfirmationDialog(
                                title: "Delete Wallet",
                                data:
                                    "Please make sure you saved your mnemonic before deleting this wallet , are you sure you want to continue?",
                                onConfirmTap: () {
                                  BlocProvider.of<WalletHomeBloc>(context).add(
                                      WalletHomeRemoveWallet(
                                          widget.detailsBloc.wallet.id));
                                  Navigator.popUntil(
                                      context, (route) => route.isFirst);
                                },
                              ));
                    },
                    icon: Icon(
                      Icons.delete,
                    )),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      focusNode: _focusNode,
                      key: _nameKey,
                      initialValue: widget.detailsBloc.wallet.title,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      validator: ((value) {
                        var validator = RegExp(r'^[1-9A-HJ-NP-Za-km-z]+$');
                        if (!validator.hasMatch(value!)) {
                          return 'Invalid Address';
                        }
                        return null;
                      }),
                      onChanged: (value) {},
                      style: Theme.of(context).textTheme.headlineMedium,
                      decoration: InputDecoration(
                        labelText: 'Wallet name',
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Hero(
                      tag: "button",
                      child: OutlinedButton(
                          onPressed: () {
                            _focusNode.unfocus();
                            if (_nameKey.currentState?.value != null &&
                                _nameKey.currentState!.value.trim().isNotEmpty)
                              widget.detailsBloc.add(UpdateWalletName(
                                  _nameKey.currentState?.value));
                          },
                          child: Text("Apply")),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "A wallet can have multiple public addresses derived from the main address.",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    OutlinedButton(
                        onPressed: () {
                          _focusNode.unfocus();
                          Navigator.pushNamed(context, Routes.addresses,
                              arguments: {
                                "wallet-details": widget.detailsBloc,
                              });
                        },
                        child: Text("Addresses")),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "You can add this wallet as a read only wallet to other wallet applications with your extended public key.No secret will be shared.",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    OutlinedButton(
                        onPressed: () {
                          _focusNode.unfocus();
                          _settingBloc.add(WalletSettingDisplayPublicKey());
                        },
                        child: Text("Display public key")),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "You can display your mnemonic (seed phrase , paper key) in can you have lost your backup, or to confirm that your backup is correct.",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    OutlinedButton(
                        onPressed: () {
                          _focusNode.unfocus();
                          _settingBloc.add(WalletSettingDisplayMnemonic());
                        },
                        child: Text(
                          "Display mnemonic",
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
