import 'package:alephium_wallet/api/repositories/alephium/alephium_api_repository.dart';
import 'package:alephium_wallet/api/repositories/base_api_repository.dart';
import 'package:alephium_wallet/bloc/wallet_details/wallet_details_bloc.dart';
import 'package:alephium_wallet/main.dart';
import 'package:alephium_wallet/routes/widgets/animated_gradient_icon.dart';
import 'package:alephium_wallet/routes/widgets/gradient_icon.dart';
import 'package:alephium_wallet/storage/models/transaction_store.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:timeago/timeago.dart' as timeago;

class TransactionTile extends StatelessWidget {
  final TransactionStore transaction;
  final WalletDetailsBloc _walletDetailsBloc;
  const TransactionTile(
    this._walletDetailsBloc, {
    Key? key,
    required this.transaction,
  }) : super(key: key);

  Future<void> _launchUrl() async {
    final repo = getIt.get<BaseApiRepository>() as AlephiumApiRepository;
    final url =
        "${repo.network.explorerUrl}/transactions/${transaction.txHash}";
    await launch(url);
  }

  @override
  Widget build(BuildContext context) {
    final type = transaction.type;
    final date = DateTime.fromMillisecondsSinceEpoch(transaction.timeStamp);
    final status = transaction.txStatus == TXStatus.completed;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Theme.of(context).primaryColor,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: InkWell(
          customBorder:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          onTap: _launchUrl,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0),
                      child: Row(
                        children: [
                          !status
                              ? AnimatedGradientProgressIndicator()
                              : GradientIcon(
                                  size: 16, icon: Icons.check_circle),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            status ? "Confirmed" : "Pending",
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
                    Spacer(),
                    Text(
                      timeago.format(date),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Amount',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: WalletTheme.instance.textColor
                                            .withOpacity(.6),
                                      )),
                              const SizedBox(
                                width: 10,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: WalletTheme.instance.background,
                                ),
                                child: Text(
                                  '${transaction.txAmount}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              Spacer(),
                              if (type == TransactionType.withdraw) ...[
                                Text('Fee',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: WalletTheme.instance.textColor
                                              .withOpacity(.6),
                                        )),
                                const SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    color: WalletTheme.instance.background,
                                  ),
                                  child: Text(
                                    '${transaction.fee}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ]
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            '${transaction.address}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  overflow: TextOverflow.ellipsis,
                                  fontWeight: FontWeight.w600,
                                  foreground: Paint()
                                    ..shader = LinearGradient(
                                      begin: Alignment.topRight,
                                      end: Alignment.bottomLeft,
                                      colors: [
                                        Color(0xff1902d5),
                                        Color(0xfffe594e),
                                      ],
                                    ).createShader(
                                        Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    GradientIcon(
                        icon: type == TransactionType.withdraw
                            ? Icons.arrow_upward
                            : Icons.arrow_downward),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
