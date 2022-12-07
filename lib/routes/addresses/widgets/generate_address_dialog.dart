import 'package:alephium_wallet/bloc/wallet_details/wallet_details_bloc.dart';
import 'package:alephium_wallet/routes/addresses/widgets/group_drop_down.dart';
import 'package:alephium_wallet/routes/addresses/widgets/main_address_switch.dart';
import 'package:alephium_wallet/routes/send/widgets/shake_form_field.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

enum GenerationType { single, group }

class GenerateWalletDialog extends StatelessWidget {
  final WalletDetailsBloc bloc;
  final GenerationType type;
  GenerateWalletDialog({
    Key? key,
    required this.bloc,
    required this.type,
  }) : super(key: key);

  final GlobalKey<ShakeTextFormFieldState> _key =
      GlobalKey<ShakeTextFormFieldState>();
  final GlobalKey<MainAddressSwitchState> _switchKey =
      GlobalKey<MainAddressSwitchState>();
  final GlobalKey<GroupDropDownState> _groupKey =
      GlobalKey<GroupDropDownState>();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: MediaQuery.of(context).viewInsets,
        width: MediaQuery.of(context).size.width * .70,
        child: Material(
            elevation: 3,
            borderRadius: BorderRadius.circular(16.0),
            color: WalletTheme.instance.background,
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          type == GenerationType.single
                              ? "mainAddress".tr()
                              : "generateOneAddress".tr(),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      if (type == GenerationType.single)
                        MainAddressSwitch(
                          key: _switchKey,
                        )
                    ],
                  ),
                  if (type == GenerationType.single) ...[
                    Text(
                      "generateAddressDescription"
                          .tr(args: [bloc.wallet.mainAddress.substring(0, 10)]),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(),
                  const SizedBox(
                    height: 10,
                  ),
                  ShakeTextFormField(
                    key: _key,
                    autofocus: true,
                    decoration: InputDecoration(
                      label: Text("title".tr()),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  if (type == GenerationType.single) ...[
                    GroupDropDown(
                      key: _groupKey,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                  Hero(
                    tag: "button",
                    child: OutlinedButton(
                      onPressed: () {
                        if (type == GenerationType.single)
                          bloc.add(GenerateNewAddress(
                            isMain: _switchKey.currentState!.value,
                            title: _key.currentState?.value,
                            color: "",
                            group: _groupKey.currentState!.value,
                          ));
                        else
                          bloc.add(GenerateOneAddressPerGroup(
                            title: _key.currentState?.value,
                            color: "",
                          ));
                        Navigator.pop(context);
                      },
                      child: Text(
                        type == GenerationType.single
                            ? "generateAddress".tr()
                            : "generate".tr(),
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
