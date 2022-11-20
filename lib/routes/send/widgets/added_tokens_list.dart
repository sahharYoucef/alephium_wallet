import 'package:alephium_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:alephium_wallet/routes/wallet_details/widgets/address_text.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddedTokensList extends StatelessWidget {
  final TransactionBloc bloc;
  const AddedTokensList({super.key, required this.bloc});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
        bloc: bloc,
        builder: (context, state) {
          return Column(
            children: [
              if (bloc.tokens.isNotEmpty) const SizedBox(height: 8),
              ...bloc.tokens.map((token) => Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              "\u2022  ",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w900),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      IconButton(
                          onPressed: () {
                            bloc.add(DeleteTokenTransactionEvent(token.id!));
                          },
                          icon: Icon(Icons.close))
                    ],
                  ))
            ],
          );
        });
  }
}
