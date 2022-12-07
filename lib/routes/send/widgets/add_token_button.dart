import 'package:alephium_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:alephium_wallet/routes/send/widgets/tokens_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddTokenButton extends StatelessWidget {
  final TransactionBloc bloc;
  const AddTokenButton({super.key, required this.bloc});

  @override
  Widget build(BuildContext context) {
    if (bloc.fromAddress?.balance?.tokens != null &&
        bloc.fromAddress!.balance!.tokens!.isNotEmpty)
      return Expanded(
        flex: 1,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                  child: Text(
                    "addToken".tr(),
                  ),
                  onPressed: () async {
                    await showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) => AddTokenDialog(
                              bloc: bloc,
                              tokens: bloc.fromAddress!.balance!.tokens!,
                            ));
                  }),
            ),
            SizedBox(
              width: 8.w,
            ),
          ],
        ),
      );
    return const SizedBox.shrink();
  }
}
