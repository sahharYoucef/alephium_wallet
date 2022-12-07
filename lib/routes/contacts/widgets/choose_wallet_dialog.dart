import 'package:alephium_wallet/bloc/wallet_home/wallet_home_bloc.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ChooseWalletDialog extends StatelessWidget {
  final WalletHomeBloc bloc;
  final String? address;
  final bool showAmount;
  final String? title;
  final String? content;
  const ChooseWalletDialog({
    super.key,
    required this.bloc,
    this.showAmount = true,
    this.address,
    this.content,
    this.title,
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
                    text: title ?? "${'sendTo'.tr()} ",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  if (address != null)
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
            content ?? "${'chooseWallet'.tr()}",
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
              .where((element) => element.type != WalletType.readOnly)
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
                              Text(
                                wallet.title == null
                                    ? "Alephium"
                                    : wallet.title!,
                              ),
                              if (showAmount) ...[
                                Spacer(),
                                Text("${wallet.balance} ℵ")
                              ]
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
