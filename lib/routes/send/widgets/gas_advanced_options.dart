import 'package:alephium_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:alephium_wallet/routes/send/widgets/shake_form_field.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GasAdvancedOption extends StatelessWidget {
  final TransactionBloc bloc;
  final String? Function(String?)? gasAmountValidator;
  final String? Function(String?)? gasPriceValidator;
  GasAdvancedOption({
    super.key,
    required this.bloc,
    required this.gasAmountValidator,
    required this.gasPriceValidator,
  });
  final GlobalKey<ShakeTextFormFieldState> _gasAmountKey =
      GlobalKey<ShakeTextFormFieldState>();
  final GlobalKey<ShakeTextFormFieldState> _gasPriceKey =
      GlobalKey<ShakeTextFormFieldState>();
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        onExpansionChanged: (value) {
          if (!value) {
            _gasAmountKey.currentState?.reset();
            _gasPriceKey.currentState?.reset();
            bloc.add(TransactionValuesChangedEvent(
              gas: "",
              gasPrice: "",
            ));
          }
        },
        tilePadding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        title: Text(
          "advancedOptions".tr(),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        children: [
          ShakeTextFormField(
            style: Theme.of(context).textTheme.bodyMedium,
            key: _gasAmountKey,
            inputFormatters: [AmountFormatter()],
            validator: gasAmountValidator,
            onChanged: (value) {
              bloc.add(TransactionValuesChangedEvent(gas: value));
              _gasAmountKey.currentState?.validate();
            },
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "gasAmount".tr(),
            ),
          ),
          SizedBox(height: 8.h),
          ShakeTextFormField(
            key: _gasPriceKey,
            style: Theme.of(context).textTheme.bodyMedium,
            inputFormatters: [AmountFormatter()],
            validator: gasPriceValidator,
            onChanged: (value) {
              bloc.add(TransactionValuesChangedEvent(gasPrice: value));
              _gasPriceKey.currentState?.validate();
            },
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "gasPrice".tr(),
            ),
          ),
        ],
      ),
    );
  }
}
