import 'package:alephium_wallet/bloc/wallet_home/wallet_home_bloc.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:collection/collection.dart';

class WalletDropdownButton extends StatefulWidget {
  final WalletHomeBloc bloc;
  final void Function(WalletStore) onChanged;
  const WalletDropdownButton({
    super.key,
    required this.bloc,
    required this.onChanged,
  });

  @override
  State<WalletDropdownButton> createState() => _WalletDropdownButtonState();
}

class _WalletDropdownButtonState extends State<WalletDropdownButton> {
  WalletStore? _walletStore;
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<WalletStore>(
      menuMaxHeight: context.height / 2,
      dropdownColor: WalletTheme.instance.dropDownBackground,
      alignment: AlignmentDirectional.bottomEnd,
      elevation: 3,
      borderRadius: BorderRadius.circular(16),
      isExpanded: true,
      validator: (value) {
        if (value == null) {
          return "Please select a wallet";
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          _walletStore = value!;
        });
        widget.onChanged(value!);
      },
      decoration: InputDecoration(
        hintText: "Please select a wallet",
        label: Text(
          "wallet".tr(),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      value: _walletStore,
      items: [
        ...widget.bloc.wallets
            .where((element) => element.type == WalletType.normal)
            .mapIndexed(
              (index, value) => DropdownMenuItem<WalletStore>(
                value: value,
                child: Text(
                  "${index + 1} - ${value.title != null ? value.title : 'Alephium'}",
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList()
      ],
    );
  }
}
