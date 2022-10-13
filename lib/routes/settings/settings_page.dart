import 'package:alephium_wallet/bloc/wallet_home/wallet_home_bloc.dart';
import 'package:alephium_wallet/routes/settings/widgets/currency_drop_down.dart';
import 'package:alephium_wallet/routes/settings/widgets/network_drop_down.dart';
import 'package:alephium_wallet/routes/settings/widgets/theme_switch.dart';
import 'package:alephium_wallet/routes/wallet_details/widgets/alephium_icon.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 32, right: 16, left: 16, bottom: 100),
      children: [
        Material(
          elevation: 2,
          color: WalletTheme.instance.primary,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                AlephiumIcon(),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Alephium Wallet",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  "v0.0.1",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  "Brought to you by Sahhar Youcef 2022",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                RichText(
                    text: TextSpan(children: [
                  TextSpan(
                    text: "Licensed under ",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextSpan(
                    text: "Apache 2 License",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.blue,
                        decoration: TextDecoration.underline),
                    recognizer: new TapGestureRecognizer()
                      ..onTap = () {
                        launch(
                            'https://github.com/sahharYoucef/alephium_wallet/blob/master/LICENSE.md');
                      },
                  ),
                ])),
                RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(children: [
                      TextSpan(
                        text: "This project is open source , find help on ",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextSpan(
                        text: "Telegram",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.blue,
                            decoration: TextDecoration.underline),
                        recognizer: new TapGestureRecognizer()
                          ..onTap = () {
                            launch('https://t.me/alephiumgroup');
                          },
                      ),
                    ])),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        RichText(
            textAlign: TextAlign.center,
            text: TextSpan(children: [
              TextSpan(
                text: "Alephium Price is powered by ",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextSpan(
                text: "CoinGecko",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.blue, decoration: TextDecoration.underline),
                recognizer: new TapGestureRecognizer()
                  ..onTap = () {
                    launch('https://www.coingecko.com/');
                  },
              ),
            ])),
        const SizedBox(
          height: 20,
        ),
        const Divider(),
        const SizedBox(
          height: 10,
        ),
        ThemeSwitch(),
        const SizedBox(
          height: 20,
        ),
        const Divider(),
        const SizedBox(
          height: 10,
        ),
        Text(
          "Currency",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(
          height: 10,
        ),
        CurrencyDropDown(),
        const SizedBox(
          height: 10,
        ),
        const Divider(),
        const SizedBox(
          height: 10,
        ),
        Text(
          "Network",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(
          height: 10,
        ),
        NetworkDropDown()
      ],
    );
  }
}
