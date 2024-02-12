import 'package:alephium_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:alephium_wallet/routes/home/widgets/token_icon.dart';
import 'package:alephium_wallet/routes/wallet_details/widgets/address_text.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:collection/collection.dart';

import '../../../utils/format.dart';

class AddedTokensList extends StatelessWidget {
  final TransactionBloc bloc;
  const AddedTokensList({super.key, required this.bloc});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
        bloc: bloc,
        builder: (context, state) {
          if (bloc.tokens.isEmpty) return SizedBox.shrink();
          return Column(
            children: [
              ...bloc.tokens.mapIndexed((index, token) => Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
                    margin: EdgeInsets.symmetric(vertical: 2.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: WalletTheme.instance.secondary,
                      border: Border.all(
                        color: WalletTheme.instance.primary,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TokenIcon(tokenStore: token),
                        SizedBox(
                          width: 5.w,
                        ),
                        Expanded(
                          child: token.isNft && token.name != null
                              ? Text(
                                  "${token.name}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall!
                                      .copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                )
                              : (token.symbol != null)
                                  ? Text(
                                      "${token.symbol}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall!
                                          .copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    )
                                  : AddressText(
                                      address: "${token.id}",
                                    ),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        if (token.isNft)
                          Text(
                            "(NFT)",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          )
                        else
                          Text(
                            Format.humanReadableNumber(
                                token.formattedBalance.toString()),
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        const SizedBox(
                          width: 8,
                        ),
                        IconButton(
                          onPressed: () {
                            bloc.add(DeleteTokenTransactionEvent(token.id!));
                          },
                          icon: Icon(Icons.remove_circle),
                        )
                      ],
                    ),
                  )),
            ],
          );
        });
  }
}
