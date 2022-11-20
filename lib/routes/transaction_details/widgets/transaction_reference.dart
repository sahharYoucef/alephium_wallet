import 'package:alephium_wallet/routes/wallet_details/widgets/address_text.dart';
import 'package:alephium_wallet/storage/models/transaction_ref_store.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class TransactionReferences extends StatelessWidget {
  final List<TransactionRefStore> refs;
  const TransactionReferences({
    Key? key,
    required this.refs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...refs.map(
          (ref) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "\u2022  ",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AddressText(
                        address: "${ref.address}",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.w600,
                              foreground: Paint()
                                ..shader = LinearGradient(
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                  colors: [
                                    WalletTheme.instance.gradientOne,
                                    WalletTheme.instance.gradientTwo,
                                  ],
                                ).createShader(
                                    Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                            ),
                      ),
                      Text(
                        "${ref.txAmount}",
                        style:
                            Theme.of(context).textTheme.headlineSmall!.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      if (ref.tokens != null && ref.tokens!.isNotEmpty)
                        Text(
                          "${'Tokens'.tr()} :",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      if (ref.tokens != null)
                        ...ref.tokens!.map((token) => Container(
                              padding: EdgeInsets.all(2),
                              margin: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: WalletTheme.instance.secondary,
                                  ),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "\u2022  ",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900),
                                  ),
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AddressText(
                                        address: "${token.id}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                              foreground: Paint()
                                                ..shader = LinearGradient(
                                                  begin: Alignment.topRight,
                                                  end: Alignment.bottomLeft,
                                                  colors: [
                                                    WalletTheme
                                                        .instance.gradientOne,
                                                    WalletTheme
                                                        .instance.gradientTwo,
                                                  ],
                                                ).createShader(Rect.fromLTWH(
                                                    0.0, 0.0, 200.0, 70.0)),
                                            ),
                                      ),
                                      Text(
                                        "${token.amount}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall!
                                            .copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ],
                                  ))
                                ],
                              ),
                            ))
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
