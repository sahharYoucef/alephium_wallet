import 'package:alephium_wallet/api/repositories/alephium/alephium_api_repository.dart';
import 'package:alephium_wallet/api/repositories/base_api_repository.dart';
import 'package:alephium_wallet/api/utils/network.dart';
import 'package:alephium_wallet/bloc/wallet_home/wallet_home_bloc.dart';
import 'package:alephium_wallet/main.dart';
import 'package:alephium_wallet/routes/wallet_details/widgets/alephium_icon.dart';
import 'package:alephium_wallet/storage/app_storage.dart';
import 'package:alephium_wallet/utils/constants.dart';
import 'package:alephium_wallet/utils/currencies.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

class SettingsPage extends StatefulWidget {
  final WalletHomeBloc bloc;
  const SettingsPage({
    Key? key,
    required this.bloc,
  }) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String _currency;
  late Network _network;

  @override
  void initState() {
    _currency = AppStorage.instance.currency;
    _network = AppStorage.instance.network;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
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
        ButtonTheme(
          alignedDropdown: true,
          child: DropdownButtonFormField<String>(
            dropdownColor: WalletTheme.instance.primary,
            alignment: AlignmentDirectional.bottomEnd,
            elevation: 3,
            borderRadius: BorderRadius.circular(16),
            decoration: InputDecoration(
              label: Text(
                "Currency",
              ),
            ),
            isExpanded: true,
            onChanged: (value) {
              setState(() {
                _currency = value!;
              });
              AppStorage.instance.currency = _currency;
              widget.bloc.add(WalletHomeLoadData());
            },
            value: _currency,
            items: [
              ...currencies
                  .map(
                    (value) => DropdownMenuItem<String>(
                      value: value,
                      child: SizedBox(
                        width: 100,
                        child: Text(
                          value.toUpperCase(),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  )
                  .toList()
            ],
          ),
        ),
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
        ButtonTheme(
          alignedDropdown: true,
          child: DropdownButtonFormField<Network>(
            dropdownColor: WalletTheme.instance.primary,
            alignment: AlignmentDirectional.bottomEnd,
            elevation: 3,
            borderRadius: BorderRadius.circular(16),
            isExpanded: true,
            onChanged: (value) {
              setState(() {
                _network = value!;
              });
              AppStorage.instance.network = _network;
              (getIt.get<BaseApiRepository>() as AlephiumApiRepository)
                  .changeNetwork = _network;
              widget.bloc.add(WalletHomeLoadData());
            },
            value: _network,
            items: [
              ...Network.values
                  .map(
                    (value) => DropdownMenuItem<Network>(
                      value: value,
                      child: SizedBox(
                        width: 100,
                        child: Text(
                          value.toString(),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  )
                  .toList()
            ],
          ),
        ),
      ],
    );
  }
}
