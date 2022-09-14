import 'package:alephium_wallet/api/repositories/alephium/alephium_api_repository.dart';
import 'package:alephium_wallet/api/repositories/base_api_repository.dart';
import 'package:alephium_wallet/bloc/wallet_details/wallet_details_bloc.dart';
import 'package:alephium_wallet/main.dart';
import 'package:alephium_wallet/storage/models/transaction_store.dart';
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
        elevation: 0,
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
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color:
                            status ? Colors.greenAccent : Colors.orangeAccent,
                      ),
                      child: Text(
                        status ? "Confirmed" : "Pending",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    Spacer(),
                    Text(
                      timeago.format(date),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Divider(
                  color: Colors.white,
                  thickness: 2,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${transaction.txAmount}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          if (type == TransactionType.withdraw)
                            Text(
                              '${transaction.fee}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          Text(
                            '${transaction.address}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(type == TransactionType.withdraw
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
