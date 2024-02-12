import 'package:alephium_wallet/routes/wallet_details/widgets/address_text.dart';
import 'package:alephium_wallet/storage/models/token_store.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../utils/format.dart';
import '../../home/widgets/token_icon.dart';

class TokenDetails extends StatelessWidget {
  final TokenStore tokenStore;
  const TokenDetails({Key? key, required this.tokenStore}) : super(key: key);

  static Future<void> show(BuildContext context,
      {required TokenStore tokenStore}) async {
    return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => TokenDetails(
        tokenStore: tokenStore,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Material(
          color: Theme.of(context).primaryColor,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: TokenIcon(
                    tokenStore: tokenStore,
                    size: tokenStore.isNft ? 260 : 80,
                    textStyle: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
                Text(
                  "Id",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(
                  height: 6,
                ),
                AddressText(
                  address: "${tokenStore.id}",
                ),
                if (tokenStore.description != null) ...[
                  const Divider(),
                  Text(
                    "${'description'.tr()}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  Text(
                    "${tokenStore.description}",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
                const Divider(),
                Row(
                  children: [
                    Text(
                      "name".tr(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Spacer(),
                    Text(
                      "${tokenStore.label}",
                      style:
                          Theme.of(context).textTheme.headlineSmall!.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                  ],
                ),
                const Divider(),
                if (tokenStore.symbol != null) ...[
                  Row(
                    children: [
                      Text(
                        "symbol".tr(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Spacer(),
                      Text(
                        "${tokenStore.symbol}",
                        style:
                            Theme.of(context).textTheme.headlineSmall!.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ],
                  ),
                  const Divider(),
                ],
                if (tokenStore.totalSupply != null) ...[
                  Row(
                    children: [
                      Text(
                        "totalSupply".tr(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Spacer(),
                      Text(
                        "${Format.humanReadableNumber(tokenStore.totalSupply)}",
                        style:
                            Theme.of(context).textTheme.headlineSmall!.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ],
                  ),
                  const Divider(),
                ],
                Row(
                  children: [
                    Text(
                      "decimals".tr(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Spacer(),
                    Text(
                      "${tokenStore.decimals}",
                      style:
                          Theme.of(context).textTheme.headlineSmall!.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                  ],
                ),
                const Divider(),
                if (!tokenStore.isNft) ...[
                  Row(
                    children: [
                      Text(
                        "balance".tr(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Spacer(),
                      Text(
                        "${Format.humanReadableNumber(tokenStore.formattedBalance)}",
                        style:
                            Theme.of(context).textTheme.headlineSmall!.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ],
                  ),
                  const Divider(),
                ],
                if (!tokenStore.isNft) ...[
                  Row(
                    children: [
                      Text(
                        "lockedBalance".tr(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Spacer(),
                      Text(
                        "${Format.humanReadableNumber(tokenStore.formattedBalance)}",
                        style:
                            Theme.of(context).textTheme.headlineSmall!.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ],
                  ),
                  const Divider(),
                ],
                const SizedBox(
                  height: 8,
                ),
                OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("OK"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
