import 'package:alephium_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

class AvailableBalanceTile extends StatelessWidget {
  final TransactionBloc bloc;
  const AvailableBalanceTile({
    super.key,
    required this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      bloc: bloc,
      builder: (context, state) {
        return AnimatedSize(
          duration: Duration(milliseconds: 200),
          child: bloc.balance != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    "${'availableBalance'.tr()} : ${bloc.balance} ℵ",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }
}
