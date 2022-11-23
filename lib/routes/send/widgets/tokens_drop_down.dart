import 'package:alephium_wallet/storage/models/token_store.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';

class TokensDropDown extends StatefulWidget {
  final List<TokenStore> tokens;
  final void Function(String?)? onChanged;
  const TokensDropDown({
    super.key,
    this.onChanged,
    required this.tokens,
  });

  @override
  State<TokensDropDown> createState() => _TokensDropDownState();
}

class _TokensDropDownState extends State<TokensDropDown> {
  String? _tokenId;
  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      child: DropdownButtonFormField<String>(
        menuMaxHeight: context.height / 2,
        dropdownColor: WalletTheme.instance.primary,
        alignment: AlignmentDirectional.centerStart,
        elevation: 3,
        hint: Row(
          children: [
            Expanded(
                child: Text(
              "selectToken".tr(),
              overflow: TextOverflow.ellipsis,
            )),
          ],
        ),
        decoration: InputDecoration(
          label: Text("token"),
        ),
        borderRadius: BorderRadius.circular(16),
        isExpanded: true,
        isDense: false,
        onChanged: (value) {
          setState(() {
            _tokenId = value!;
          });
          if (widget.onChanged != null) widget.onChanged!(value);
        },
        value: _tokenId,
        items: [
          ...widget.tokens
              .map(
                (value) => DropdownMenuItem<String>(
                  value: value.id,
                  child: Text(
                    value.id.toString(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(overflow: TextOverflow.ellipsis),
                  ),
                ),
              )
              .toList()
        ],
      ),
    );
  }
}
