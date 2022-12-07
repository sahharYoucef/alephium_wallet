import 'package:alephium_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:alephium_wallet/routes/send/widgets/check_tx_result.dart';
import 'package:alephium_wallet/routes/send/widgets/gas_advanced_options.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BuildTransactionResultView extends StatelessWidget {
  final TransactionBloc bloc;
  final WalletStore wallet;
  final String? Function(String?)? gasAmountValidator;
  final String? Function(String?)? gasPriceValidator;
  BuildTransactionResultView({
    Key? key,
    required this.bloc,
    required this.gasAmountValidator,
    required this.gasPriceValidator,
  })  : wallet = bloc.wallet,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    late var transaction = bloc.transaction;
    return BlocBuilder<TransactionBloc, TransactionState>(
      bloc: bloc,
      buildWhen: (previous, current) {
        return transaction?.txId != bloc.transaction?.txId;
      },
      builder: (context, state) {
        transaction = bloc.transaction;
        return Column(
          children: [
            if (bloc.transaction != null)
              CheckTransactionResult(
                bloc: bloc,
              )
            else ...[
              Divider(
                height: 1,
              ),
              GasAdvancedOption(
                bloc: bloc,
                gasAmountValidator: gasAmountValidator,
                gasPriceValidator: gasPriceValidator,
              ),
            ],
          ],
        );
      },
    );
  }
}
