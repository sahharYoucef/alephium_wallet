import 'package:alephium_wallet/bloc/contacts/contacts_bloc.dart';
import 'package:alephium_wallet/routes/send/widgets/shake_form_field.dart';
import 'package:alephium_wallet/routes/wallet_details/widgets/shake_widget.dart';
import 'package:alephium_wallet/routes/widgets/gradient_icon.dart';
import 'package:alephium_wallet/storage/models/contact_store.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ToAddressField extends StatefulWidget {
  final String? Function(String?)? validator;
  final void Function(String) onChanged;
  final String? initialValue;
  final String? label;
  final bool enableSuggestion;
  final bool readOnly;
  final bool obscureText;
  const ToAddressField({
    super.key,
    this.validator,
    this.initialValue,
    this.label,
    this.readOnly = false,
    this.obscureText = false,
    required this.onChanged,
    this.enableSuggestion = false,
  });

  @override
  State<ToAddressField> createState() => _ToAddressFieldState();
}

class _ToAddressFieldState extends State<ToAddressField> {
  GlobalKey<ShakeTextFormFieldState> _toAddressKey =
      GlobalKey<ShakeTextFormFieldState>();
  GlobalKey<ShakeErrorState> _shakeKey = GlobalKey<ShakeErrorState>();

  @override
  Widget build(BuildContext context) {
    return ShakeError(
      key: _shakeKey,
      child: LayoutBuilder(
        builder: (context, constraints) => Autocomplete<ContactStore>(
          onSelected: (option) {
            widget.onChanged(option.address);
            _toAddressKey.currentState?.validate();
          },
          displayStringForOption: (option) => option.address,
          initialValue: widget.initialValue != null
              ? TextEditingValue(
                  text: widget.initialValue!,
                  selection: TextSelection.collapsed(
                    offset: widget.initialValue!.length,
                  ))
              : null,
          optionsBuilder: (value) {
            if (value.text.trim().isEmpty || !widget.enableSuggestion)
              return [];
            final suggestion = context.read<ContactsBloc>().contacts.where(
              (element) {
                final fullName =
                    "${element.firstName} ${element.lastName ?? ''}";
                final isFirstName = element.firstName
                    .toLowerCase()
                    .contains(value.text.toLowerCase());
                final isLastName = element.lastName
                        ?.toLowerCase()
                        .contains(value.text.toLowerCase()) ??
                    false;
                final isFullName =
                    fullName.toLowerCase().contains(value.text.toLowerCase());
                return isFirstName || isLastName || isFullName;
              },
            );
            if (suggestion.isEmpty) {
              _toAddressKey.currentState?.validate();
            }
            return suggestion;
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                color: WalletTheme.instance.dropDownBackground,
                child: Container(
                  height: 52.0 * options.length,
                  width: constraints.biggest.width,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: options.length,
                    shrinkWrap: false,
                    itemBuilder: (BuildContext context, int index) {
                      final option = options.elementAt(index);
                      return InkWell(
                        onTap: () => onSelected(option),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "${option.firstName} ${option.lastName ?? ''}",
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
          fieldViewBuilder:
              (context, textEditingController, focusNode, onFieldSubmitted) {
            return ShakeTextFormField(
              key: _toAddressKey,
              focusNode: focusNode,
              onSaved: (newValue) {
                if (_toAddressKey.currentState!.isValid)
                  _shakeKey.currentState?.shake();
              },
              controller: textEditingController,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: widget.validator,
              style: Theme.of(context).textTheme.bodyMedium,
              onChanged: widget.onChanged,
              readOnly: widget.readOnly,
              obscureText: widget.obscureText,
              decoration: InputDecoration(
                labelText: widget.label,
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
                      widget.onChanged(value);
                      setState(() {
                        textEditingController.text = value;
                      });
                      _toAddressKey.currentState?.validate();
                    }
                  },
                  icon: GradientIcon(icon: Icons.qr_code),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
