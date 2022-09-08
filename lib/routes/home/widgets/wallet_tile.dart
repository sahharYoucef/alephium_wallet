import 'package:alephium_dart/alephium_dart.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/routes/widgets/wallet_appbar.dart';
import 'package:alephium_wallet/storage/app_storage.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants.dart';

class WalletTile extends StatelessWidget {
  final WalletStore wallet;
  const WalletTile({Key? key, required this.wallet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: WalletTheme.lightPrimaryColor,
        elevation: 0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        child: InkWell(
          customBorder:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          onTap: () {
            Navigator.pushNamed(
              context,
              Routes.wallet,
              arguments: {"wallet": wallet},
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 40,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            wallet.title.isEmpty
                                ? "Alephium wallet"
                                : wallet.title,
                            style: Theme.of(context).textTheme.headlineSmall),
                        RichText(
                            text: TextSpan(children: [
                          TextSpan(
                              text: "${wallet.balance}",
                              style: Theme.of(context).textTheme.headlineSmall),
                          if (wallet.balanceConverted != null &&
                              wallet.balanceConverted != "0.000") ...[
                            TextSpan(
                              text: " = ",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            TextSpan(
                                text: "${wallet.balanceConverted}",
                                style: Theme.of(context).textTheme.bodyMedium),
                          ]
                        ]))
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Main address : ",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        wallet.addresses.first.address,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    IconButton(
                        onPressed: () async {
                          var data = ClipboardData(
                              text: wallet.addresses.first.address);
                          await Clipboard.setData(data);
                          context.showSnackBar(
                            "address copied to clipboard!",
                          );
                        },
                        icon: Icon(Icons.copy))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
