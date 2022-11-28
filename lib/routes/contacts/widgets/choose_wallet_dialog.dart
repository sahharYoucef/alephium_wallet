import 'package:alephium_wallet/bloc/wallet_home/wallet_home_bloc.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ChooseWalletDialog extends StatelessWidget {
  final WalletHomeBloc bloc;
  final String address;
  const ChooseWalletDialog({
    super.key,
    required this.bloc,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: context.height * .6,
        maxWidth: context.width * .9,
        minWidth: context.width * .9,
      ),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        children: [
          RichText(
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "${'sendTo'.tr()} ",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  TextSpan(
                    text: "(${address})",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(overflow: TextOverflow.ellipsis),
                  ),
                ],
              )),
          const SizedBox(
            height: 10,
          ),
          Text(
            "${'chooseWallet'.tr()}",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(
            height: 10,
          ),
          Divider(),
          const SizedBox(
            height: 10,
          ),
          ...bloc.wallets
              .map((wallet) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton(
                          onPressed: () {
                            Navigator.pop<WalletStore>(context, wallet);
                          },
                          child: Row(
                            children: [
                              Text(wallet.title.isEmpty
                                  ? "Alephium"
                                  : wallet.title),
                              Spacer(),
                              Text("${wallet.balance} ℵ")
                            ],
                          )),
                      const SizedBox(
                        height: 8,
                      )
                    ],
                  ))
              .toList()
        ],
      ),
    );
  }
}
