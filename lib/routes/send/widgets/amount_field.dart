import 'package:alephium_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:alephium_wallet/routes/send/widgets/shake_form_field.dart';
import 'package:alephium_wallet/routes/widgets/gradient_icon.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AmountTextField extends StatefulWidget {
  final String? Function(String?)? validator;
  final TransactionBloc bloc;
  final String? initialValue;
  const AmountTextField(
      {super.key, this.validator, required this.bloc, this.initialValue});

  @override
  State<AmountTextField> createState() => _AmountTextFieldState();
}

class _AmountTextFieldState extends State<AmountTextField> {
  late final TextEditingController _amountController;
  GlobalKey<FormFieldState> _amountKey = GlobalKey<FormFieldState>();

  @override
  void initState() {
    _amountController = TextEditingController(text: widget.initialValue);
    super.initState();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShakeTextFormField(
      controller: _amountController,
      key: _amountKey,
      inputFormatters: [AmountFormatter()],
      style: Theme.of(context).textTheme.bodyMedium,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: widget.validator,
      onChanged: (value) {
        widget.bloc.add(TransactionValuesChangedEvent(amount: value));
        _amountKey.currentState?.validate();
      },
      errorStyle:
          Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white),
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      autocorrect: false,
      decoration: InputDecoration(
        labelText: "amount".tr(),
        suffixIcon: IconButton(
          onPressed: () {
            if (widget.bloc.fromAddress != null)
              widget.bloc.add(TransactionValuesChangedEvent(
                  amount: widget.bloc.fromAddress?.addressBalance.toString()));
            if (widget.bloc.fromAddress?.addressBalance != null)
              _amountController.text =
                  widget.bloc.fromAddress!.addressBalance.toString();
            _amountKey.currentState?.validate();
          },
          icon: GradientIcon(
            icon: Icons.all_inclusive,
          ),
        ),
      ),
    );
  }
}
