import 'package:alephium_wallet/routes/settings/widgets/advanced_switch.dart';
import 'package:alephium_wallet/routes/settings/widgets/local_auth_switch.dart';
import 'package:alephium_wallet/routes/settings/widgets/network_drop_down.dart';
import 'package:alephium_wallet/routes/settings/widgets/visibility_switch.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:alephium_wallet/routes/settings/widgets/currency_drop_down.dart';
import 'package:alephium_wallet/routes/settings/widgets/language_drop_down.dart';
import 'package:alephium_wallet/routes/settings/widgets/theme_drop_down.dart';
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
      padding: EdgeInsets.only(
          top: 32,
          right: 16,
          left: 16,
          bottom: 100 + MediaQuery.of(context).padding.bottom),
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
                  "alephiumWallet".tr(),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  "v0.9.5",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  "broughtBy".tr(args: ["Sahhar Youcef"]),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                RichText(
                    text: TextSpan(children: [
                  TextSpan(
                    text: "licensedUnder".tr(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextSpan(
                    text: "Apache 2 ${'license'.tr()}",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: WalletTheme.instance.gradientTwo,
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
                        text: "socialLink".tr() + " ",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextSpan(
                        text: "openSource".tr(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: WalletTheme.instance.gradientTwo,
                            decoration: TextDecoration.underline),
                        recognizer: new TapGestureRecognizer()
                          ..onTap = () {
                            launch(
                                'https://github.com/sahharYoucef/alephium_wallet');
                          },
                      ),
                      TextSpan(
                        text: " " + "findHelpOn".tr() + " ",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextSpan(
                        text: "Telegram",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: WalletTheme.instance.gradientTwo,
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
                text: "priceSource".tr(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextSpan(
                text: "CoinGecko",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: WalletTheme.instance.gradientTwo,
                      decoration: TextDecoration.underline,
                    ),
                recognizer: new TapGestureRecognizer()
                  ..onTap = () {
                    launch('https://www.coingecko.com/');
                  },
              ),
            ])),
        const SizedBox(
          height: 20,
        ),
        Material(
          elevation: 2,
          color: WalletTheme.instance.primary,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                LocalAuthSwitch(),
                const SizedBox(
                  height: 10,
                ),
                const Divider(),
                const SizedBox(
                  height: 10,
                ),
                VisibilitySwitch(),
                const SizedBox(
                  height: 10,
                ),
                const Divider(),
                const SizedBox(
                  height: 10,
                ),
                AdvancedSwitch(),
                const SizedBox(
                  height: 10,
                ),
                const Divider(),
                const SizedBox(
                  height: 10,
                ),
                ThemeSwitch(),
                const SizedBox(
                  height: 10,
                ),
                const Divider(),
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
                LanguageDropDown(),
                const SizedBox(
                  height: 10,
                ),
                const Divider(),
                const SizedBox(
                  height: 10,
                ),
                NetworkDropDown(),
              ],
            ),
          ),
        )
      ],
    );
  }
}
