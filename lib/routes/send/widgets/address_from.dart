import 'package:alephium_wallet/routes/widgets/gradient_icon.dart';
import 'package:alephium_wallet/storage/models/address_store.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/utils/theme.dart';

import 'package:flutter/material.dart';

class AddressFromDropDownMenu extends StatefulWidget {
  final Function(AddressStore)? onChanged;
  final List<AddressStore> addresses;
  final String label;
  final AddressStore? initialAddress;
  AddressFromDropDownMenu({
    Key? key,
    required this.addresses,
    required this.label,
    this.initialAddress,
    this.onChanged,
  }) : super(key: key);

  @override
  State<AddressFromDropDownMenu> createState() =>
      _AddressFromDropDownMenuState();
}

class _AddressFromDropDownMenuState extends State<AddressFromDropDownMenu> {
  AddressStore? _value;

  @override
  void initState() {
    _value = widget.initialAddress;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      alignedDropdown: false,
      child: DropdownButtonFormField<AddressStore>(
        menuMaxHeight: context.height / 2,
        alignment: AlignmentDirectional.bottomStart,
        elevation: 0,
        dropdownColor: WalletTheme.instance.primary,
        borderRadius: BorderRadius.circular(16),
        decoration: InputDecoration(
          label: Text(widget.label),
          suffixIcon: GradientIcon(
            icon: Icons.arrow_drop_down,
            size: 24,
          ),
          isDense: true,
          alignLabelWithHint: false,
        ),
        value: _value,
        isExpanded: true,
        isDense: true,
        icon: const SizedBox(),
        iconSize: 24,
        items: widget.addresses
            .map((address) => DropdownMenuItem<AddressStore>(
                  value: address,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          address.address,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        address.formattedBalance,
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    ],
                  ),
                ))
            .toList(),
        onChanged: (value) {
          if (value == null) return;
          setState(() {
            _value = value;
          });
          if (widget.onChanged != null) {
            widget.onChanged!(_value!);
          }
        },
      ),
    );
  }
}
