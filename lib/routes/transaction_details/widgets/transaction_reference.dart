import 'package:alephium_wallet/routes/wallet_details/widgets/address_text.dart';
import 'package:alephium_wallet/routes/widgets/gradient_icon.dart';
import 'package:alephium_wallet/storage/models/transaction_ref_store.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
            if (ref.tokens != null && ref.tokens!.isNotEmpty)
              return Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  trailing: GradientIcon(icon: Icons.add),
                  initiallyExpanded: false,
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: EdgeInsets.only(left: 20, top: 4, bottom: 4),
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "\u2022  ",
                        style: TextStyle(
                            fontSize: 20.sp, fontWeight: FontWeight.w900),
                      ),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            AddressText(
                              address: "${ref.address}",
                            ),
                            Text(
                              "${ref.txAmount}",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ).obscure("ℵ"),
                          ]))
                    ],
                  ),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (ref.tokens != null)
                      ...ref.tokens!.map((token) => Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "\u2022  ",
                                style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w900),
                              ),
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AddressText(
                                    address: "${token.id}",
                                  ),
                                  Row(
                                    children: [
                                      if (token.symbol != null ||
                                          token.name != null)
                                        Expanded(
                                          child: Text(
                                            "${token.name ?? token.symbol}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall!
                                                .copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ),
                                      Text(
                                        "${token.formattedAmount}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall!
                                            .copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ))
                            ],
                          ))
                  ],
                ),
              );
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                "\u2022  ",
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900),
              ),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    AddressText(
                      address: "${ref.address}",
                    ),
                    Text(
                      "${ref.txAmount}",
                      style:
                          Theme.of(context).textTheme.headlineSmall!.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                    ).obscure("ℵ"),
                  ]))
            ]);
          },
        ),
      ],
    );
  }
}
