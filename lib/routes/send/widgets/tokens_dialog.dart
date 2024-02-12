import 'package:alephium_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:alephium_wallet/routes/send/widgets/shake_form_field.dart';
import 'package:alephium_wallet/routes/send/widgets/tokens_drop_down.dart';
import 'package:alephium_wallet/storage/models/token_store.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';

class AddTokenDialog extends StatefulWidget {
  final List<TokenStore> tokens;
  final TransactionBloc bloc;
  const AddTokenDialog({
    Key? key,
    required this.tokens,
    required this.bloc,
  }) : super(key: key);

  @override
  State<AddTokenDialog> createState() => _AddTokenDialogState();
}

class _AddTokenDialogState extends State<AddTokenDialog> with InputValidators {
  GlobalKey<ShakeTextFormFieldState> _amountKey =
      GlobalKey<ShakeTextFormFieldState>();
  String? _id;
  String? _amount;

  @override
  Widget build(BuildContext context) {
    final token =
        widget.tokens.firstWhereOrNull((element) => element.id == _id);
    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Material(
          color: Theme.of(context).primaryColor,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${'addToken'.tr()}",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(
                  height: 6,
                ),
                const Divider(),
                const SizedBox(
                  height: 6,
                ),
                TokensDropDown(
                  tokens: widget.tokens
                      .where(
                          (element) => element.availableBalance > BigInt.zero)
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _id = value;
                    });
                  },
                ),
                const SizedBox(
                  height: 6,
                ),
                if (_id != null && token != null && !token.isNft)
                  ShakeTextFormField(
                      enabled: true,
                      key: _amountKey,
                      inputFormatters: [
                        AmountFormatter(
                          decimals: token.decimals,
                        )
                      ],
                      style: Theme.of(context).textTheme.bodyMedium,
                      validator: (value) {
                        if (token.isNft) return null;
                        return tokenAmountValidator(token, value);
                      },
                      onChanged: (value) {
                        _amount = value;
                        _amountKey.currentState?.validate();
                      },
                      textInputAction: TextInputAction.next,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      autocorrect: false,
                      decoration: InputDecoration(
                        labelText: "amount".tr(),
                      )),
                const SizedBox(height: 8),
                if (_id != null && token != null && !token.isNft)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      "${'availableBalance'.tr()} : ${token.availableBalance}",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                            onPressed: token != null
                                ? () {
                                    if ((_amountKey.currentState?.validate() ??
                                        false || token.isNft)) {
                                      widget.bloc.add(AddTokenTransactionEvent(
                                        _id!,
                                        token.isNft ? "1" : _amount!,
                                        token.decimals,
                                      ));
                                      Navigator.pop(context);
                                    }
                                  }
                                : null,
                            child: Text("OK")),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "close".tr(),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  TransactionBloc get bloc => widget.bloc;

  @override
  WalletStore get wallet => widget.bloc.wallet;
}
