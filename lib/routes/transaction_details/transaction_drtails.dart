import 'package:alephium_wallet/storage/models/transaction_store.dart';
import 'package:flutter/material.dart';

class TransactionDetails extends StatelessWidget {
  final TransactionStore transaction;
  const TransactionDetails({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  16,
                )),
            child: ListView(children: [
              Text(
                "Hash",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(
                height: 6,
              ),
              Text(
                "${transaction.blockHash}",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Divider(),
            ])));
  }
}
