import 'package:alephium_wallet/api/repositories/base_api_repository.dart';
import 'package:alephium_wallet/api/utils/network.dart';
import 'package:alephium_wallet/bloc/wallet_home/wallet_home_bloc.dart';
import 'package:alephium_wallet/main.dart';
import 'package:alephium_wallet/routes/settings/widgets/custom_network_settings.dart';
import 'package:alephium_wallet/storage/app_storage.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

class NetworkDropDown extends StatefulWidget {
  NetworkDropDown({super.key});

  @override
  State<NetworkDropDown> createState() => _NetworkDropDownState();
}

class _NetworkDropDownState extends State<NetworkDropDown> {
  final GlobalKey<FormFieldState> _globalKey = GlobalKey<FormFieldState>();

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      alignedDropdown: true,
      child: DropdownButtonFormField<NetworkType>(
        key: _globalKey,
        menuMaxHeight: context.height / 2,
        dropdownColor: WalletTheme.instance.dropDownBackground,
        alignment: AlignmentDirectional.bottomEnd,
        elevation: 3,
        borderRadius: BorderRadius.circular(16),
        isExpanded: true,
        onChanged: (value) async {
          if (value == NetworkType.custom) {
            final customNetwork = AppStorage.instance.customNetwork;
            final updatedNetwork =
                await showModalBottomSheet<Map<String, String?>?>(
              isScrollControlled: true,
              isDismissible: false,
              backgroundColor: Colors.transparent,
              context: context,
              enableDrag: false,
              builder: (context) => CustomNetworkSetting(
                explorerApiHost: customNetwork?['explorerApiHost'],
                explorerUrl: customNetwork?['explorerUrl'],
                nodeHost: customNetwork?['nodeHost'],
              ),
            );
            if (updatedNetwork == null) {
              // ignore: invalid_use_of_protected_member
              _globalKey.currentState!.setValue(AppStorage.instance.network);
              return;
            }
            AppStorage.instance.customNetwork = updatedNetwork;
          }
          AppStorage.instance.network = value!;
          getIt.get<BaseApiRepository>().changeNetwork = value;
          context.read<WalletHomeBloc>().add(WalletHomeLoadData());
        },
        decoration: InputDecoration(
          label: Text(
            "network".tr(),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        value: AppStorage.instance.network,
        items: [
          ...NetworkType.values
              .map(
                (value) => DropdownMenuItem<NetworkType>(
                  value: value,
                  child: SizedBox(
                    child: Text(
                      value.name.capitalize,
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
