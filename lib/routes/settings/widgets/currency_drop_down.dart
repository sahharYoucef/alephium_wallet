import 'package:alephium_wallet/bloc/wallet_home/wallet_home_bloc.dart';
import 'package:alephium_wallet/storage/app_storage.dart';
import 'package:alephium_wallet/utils/currencies.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

class CurrencyDropDown extends StatefulWidget {
  const CurrencyDropDown({super.key});

  @override
  State<CurrencyDropDown> createState() => _CurrencyDropDownState();
}

class _CurrencyDropDownState extends State<CurrencyDropDown> {
  String _currency = AppStorage.instance.currency;
  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      alignedDropdown: true,
      child: DropdownButtonFormField<String>(
        menuMaxHeight: context.height / 2,
        dropdownColor: WalletTheme.instance.primary,
        alignment: AlignmentDirectional.bottomEnd,
        elevation: 3,
        decoration: InputDecoration(
          label: Text(
            "currency".tr(),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        borderRadius: BorderRadius.circular(16),
        isExpanded: true,
        onChanged: (value) {
          setState(() {
            _currency = value!;
          });
          AppStorage.instance.currency = _currency;
          context.read<WalletHomeBloc>().add(WalletHomeLoadData());
        },
        value: _currency,
        items: [
          ...currencies
              .map(
                (value) => DropdownMenuItem<String>(
                  value: value,
                  child: SizedBox(
                    child: Text(
                      value.toUpperCase(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              )
              .toList()
        ],
      ),
    );
  }
}
