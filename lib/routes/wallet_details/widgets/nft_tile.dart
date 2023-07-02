import 'package:alephium_wallet/routes/home/widgets/token_icon.dart';
import 'package:alephium_wallet/routes/wallet_details/widgets/address_text.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../send/widgets/token_details.dart';

class NftTile extends StatelessWidget {
  final WalletStore wallet;
  const NftTile({Key? key, required this.wallet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (wallet.nftTokensBalances.isEmpty) return SizedBox.shrink();
    return Center(
      child: PhysicalModel(
        borderRadius: BorderRadius.circular(16.0),
        color: Colors.white,
        elevation: 1,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: WalletTheme.instance.maxWidth,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(16.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (wallet.nftTokensBalances.isNotEmpty) ...[
                SizedBox(
                  height: 20,
                ),
                Text(
                  '${"NFT's".tr()} :',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Divider(),
                ...wallet.nftTokensBalances
                    .mapIndexed((index, token) => Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 4,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TokenIcon(tokenStore: token),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AddressText(
                                      onTap: () {
                                        TokenDetails.show(context,
                                            tokenStore: token);
                                      },
                                      address:
                                          "${token.name ?? token.symbol ?? 'Token ${index + 1}'.tr()}",
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ))
              ],
            ],
          ),
        ),
      ),
    );
  }
}
