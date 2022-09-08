import 'package:alephium_wallet/routes/restore_wallet/widgets/mnemonic_text_field.dart';
import 'package:alephium_wallet/routes/widgets/wallet_appbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bloc/create_wallet/create_wallet_bloc.dart';

class RestoreWallet extends StatelessWidget {
  final CreateWalletBloc bloc;

  RestoreWallet({super.key, required this.bloc});

  final GlobalKey<MnemonicTextFieldState> _key =
      GlobalKey<MnemonicTextFieldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).padding.top + 70,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Enter your mnemonic to restore your wallet :",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MnemonicTextField(
                        key: _key,
                      ),
                    ),
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    children: [
                      Spacer(),
                      SafeArea(
                        bottom: true,
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Hero(
                            tag: "button",
                            child: OutlinedButton(
                              onPressed: () {
                                if (_key.currentState?.mnemonic != null)
                                  bloc.add(
                                    CreateWalletRestore(
                                      mnemonic: _key.currentState!.mnemonic,
                                    ),
                                  );
                              },
                              child: Text("Restore Wallet"),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // SizedBox(
                //   height: 42,
                // ),
              ],
            ),
          ),
          WalletAppBar(
            label: Text(
              'Restore Wallet',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ],
      ),
    );
  }
}
