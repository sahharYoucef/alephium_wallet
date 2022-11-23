import 'package:alephium_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:alephium_wallet/routes/widgets/gradient_icon.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ToAddressField extends StatefulWidget {
  final String? Function(String?)? validator;
  final TransactionBloc bloc;
  final String? initialValue;
  const ToAddressField({
    super.key,
    this.validator,
    this.initialValue,
    required this.bloc,
  });

  @override
  State<ToAddressField> createState() => _ToAddressFieldState();
}

class _ToAddressFieldState extends State<ToAddressField> {
  GlobalKey<FormFieldState> _toAddressKey = GlobalKey<FormFieldState>();
  late final TextEditingController _controller;
  @override
  void initState() {
    _controller = TextEditingController(text: widget.initialValue);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: _toAddressKey,
      controller: _controller,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      validator: widget.validator,
      style: Theme.of(context).textTheme.bodyMedium,
      onChanged: ((value) {
        widget.bloc.add(TransactionValuesChangedEvent(toAddress: value));
      }),
      decoration: InputDecoration(
        labelText: "toAddress".tr(),
        suffixIcon: IconButton(
          onPressed: () async {
            var data = await showQRView(
              context,
              isTransfer: false,
            );
            if (data?["address"] != null &&
                data!["address"] is String &&
                data["address"].trim().isNotEmpty) {
              final value = data["address"];
              widget.bloc.add(TransactionValuesChangedEvent(toAddress: value));
              setState(() {
                _controller.text = value;
              });
            }
          },
          icon: GradientIcon(icon: Icons.qr_code),
        ),
      ),
    );
  }
}
