import 'package:alephium_wallet/api/dto_models/balance_dto.dart';
import 'package:alephium_wallet/bloc/create_wallet/create_wallet_bloc.dart';
import 'package:alephium_wallet/routes/constants.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/routes/new_wallet/widgets/new_wallet_checkbox.dart';
import 'package:alephium_wallet/routes/widgets/wallet_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class NewWalletPage extends StatefulWidget {
  const NewWalletPage({Key? key}) : super(key: key);

  @override
  State<NewWalletPage> createState() => _NewWalletPageState();
}

class _NewWalletPageState extends State<NewWalletPage> {
  late final CreateWalletBloc _createWalletBloc;
  String? selected;

  @override
  void initState() {
    FlutterNativeSplash.remove();
    _createWalletBloc = CreateWalletBloc(Blockchain.Alephium);
    super.initState();
  }

  @override
  void dispose() {
    _createWalletBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateWalletBloc, CreateWalletState>(
      bloc: _createWalletBloc,
      listener: ((context, state) {
        if (state is CreateWalletGenerateMnemonicSuccess) {
          Navigator.pushNamed(
            context,
            Routes.walletMnemonic,
            arguments: {
              "wallet": state.wallet,
              "bloc": _createWalletBloc,
            },
          );
        }
        if (state is CreateWalletFailure) {
          context.showSnackBar(state.error, level: Level.error);
        }
        if (state is SaveWalletToDatabaseSuccess) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.home,
            (Route<dynamic> route) => false,
          );
        }
      }),
      child: Scaffold(
        body: Column(
          children: [
            WalletAppBar(
              label: Text(
                'New Wallet',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Expanded(
              child: Center(
                child: Form(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    NewWalletCheckbox(
                      title: "New Wallet",
                      description:
                          "Create a wallet (keys and an address) from a randomly generated mnemonic.",
                      value: "new",
                      onTap: (value) {
                        setState(() {
                          if (selected == value)
                            selected = null;
                          else
                            selected = value;
                        });
                      },
                      selected: selected,
                      icon: Icons.create,
                    ),
                    NewWalletCheckbox(
                      title: "Restore Wallet",
                      description:
                          "Restores a wallet's keys and address from a mnemonic phrase.",
                      value: "restore",
                      selected: selected,
                      onTap: (value) {
                        setState(() {
                          if (selected == value)
                            selected = null;
                          else
                            selected = value;
                        });
                      },
                      icon: Icons.restore,
                    ),
                    NewWalletCheckbox(
                      title: "Read-only Wallet",
                      description:
                          "Add a wallet address in read-only mode. This won't save any secrets in this device.",
                      value: "read-only",
                      selected: selected,
                      onTap: (value) {
                        setState(() {
                          if (selected == value)
                            selected = null;
                          else
                            selected = value;
                        });
                      },
                      icon: Icons.lock_rounded,
                    ),
                  ],
                )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Hero(
                tag: "button",
                child: OutlinedButton(
                  onPressed: selected != null
                      ? () {
                          if (selected == "new")
                            _createWalletBloc.add(
                              CreateWalletGenerateMnemonic(
                                passphrase: '',
                              ),
                            );
                          else if (selected == "restore")
                            Navigator.pushNamed(
                              context,
                              Routes.restoreWallet,
                              arguments: {
                                "bloc": _createWalletBloc,
                              },
                            );
                          else if (selected == "read-only")
                            Navigator.pushNamed(
                              context,
                              Routes.readOnlyWallet,
                              arguments: {
                                "bloc": _createWalletBloc,
                              },
                            );
                        }
                      : null,
                  child: Text("Next"),
                ),
              ),
            ),
            SizedBox(height: 42),
          ],
        ),
      ),
    );
  }
}
