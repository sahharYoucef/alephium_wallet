import 'package:alephium_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:alephium_wallet/routes/send/widgets/shake_form_field.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SendCheckButton extends StatelessWidget {
  final TransactionBloc bloc;
  final WalletStore wallet;
  final GlobalKey<ShakeFormState> formKey;
  SendCheckButton({
    Key? key,
    required this.bloc,
    required this.formKey,
  })  : wallet = bloc.wallet,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    late bool activateButton = bloc.activateButton;
    late var transaction = bloc.transaction;
    return Hero(
      tag: "button",
      child: BlocBuilder<TransactionBloc, TransactionState>(
        bloc: bloc,
        buildWhen: (previous, current) {
          return bloc.activateButton != activateButton ||
              transaction?.txId != bloc.transaction?.txId;
        },
        builder: (context, state) {
          activateButton = bloc.activateButton;
          transaction = bloc.transaction;
          return OutlinedButton(
            child: Text(
              transaction != null ? 'send'.tr() : 'check'.tr(),
            ),
            onPressed: activateButton
                ? () {
                    var isValid =
                        formKey.currentState?.validate(shake: true) ?? false;
                    if (!isValid) {
                      return;
                    }
                    if (transaction == null) {
                      bloc.add(
                        CheckTransactionEvent(
                          bloc.fromAddress,
                        ),
                      );
                    } else {
                      if (wallet.type == WalletType.normal)
                        bloc.add(SignAndSendTransaction(
                          privateKey: bloc.fromAddress!.privateKey!,
                          transactionID: transaction!.txId!,
                          unsignedTx: transaction!.unsignedTx!,
                        ));
                      else
                        bloc.add(
                            CheckSignMultisigTransaction(bloc.fromAddress));
                    }
                  }
                : null,
          );
        },
      ),
    );
  }
}
