import 'package:alephium_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:alephium_wallet/routes/wallet_details/widgets/address_text.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:alephium_wallet/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ToAddressesField extends StatefulWidget {
  final TransactionBloc bloc;
  const ToAddressesField({
    super.key,
    required this.bloc,
  });

  @override
  State<ToAddressesField> createState() => _ToAddressesFieldState();
}

class _ToAddressesFieldState extends State<ToAddressesField>
    with InputValidators {
  GlobalKey<FormFieldState> _toAddressKey = GlobalKey<FormFieldState>();
  List<String> toAddresses = <String>[];

  _submitAddress() {
    _toAddressKey.currentState!.validate();
    if (_toAddressKey.currentState!.isValid) {
      setState(() {
        toAddresses.add(_toAddressKey.currentState!.value);
      });
      _toAddressKey.currentState!.reset();
      widget.bloc.add(TransactionValuesChangedEvent(toAddresses: toAddresses));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList(
            delegate: SliverChildListDelegate(
          [
            TextFormField(
              key: _toAddressKey,
              textInputAction: TextInputAction.next,
              validator: addressToValidator,
              autocorrect: false,
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: InputDecoration(
                labelText: "toAddress".tr(),
                suffixIcon: IconButton(
                  onPressed: _submitAddress,
                  icon: Icon(
                    Icons.add,
                  ),
                ),
              ),
              onFieldSubmitted: (value) {
                _submitAddress();
              },
            ),
            const SizedBox(
              height: 8,
            ),
            ...widget.bloc.toAddresses
                .map(
                  (address) => Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: AddressText(
                        address: address,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.w600,
                              foreground: Paint()
                                ..shader = LinearGradient(
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                  colors: [
                                    WalletTheme.instance.gradientOne,
                                    WalletTheme.instance.gradientTwo,
                                  ],
                                ).createShader(
                                    Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                            ),
                      )),
                      const SizedBox(
                        width: 8,
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            toAddresses
                                .removeWhere((value) => value == address);
                          });
                          widget.bloc.add(TransactionValuesChangedEvent(
                              toAddresses: toAddresses));
                        },
                        icon: Icon(
                          Icons.delete,
                        ),
                      ),
                    ],
                  ),
                )
                .toList()
          ],
        )));
  }

  @override
  TransactionBloc get bloc => widget.bloc;

  @override
  WalletStore get wallet => widget.bloc.wallet;
}
