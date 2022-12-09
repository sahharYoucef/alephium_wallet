import 'package:alephium_wallet/bloc/wallet_details/wallet_details_bloc.dart';
import 'package:alephium_wallet/bloc/wallet_home/wallet_home_bloc.dart';
import 'package:alephium_wallet/bloc/wallet_setting/wallet_setting_bloc.dart';
import 'package:alephium_wallet/encryption/base_wallet_service.dart';
import 'package:alephium_wallet/main.dart';
import 'package:alephium_wallet/routes/constants.dart';
import 'package:alephium_wallet/routes/send/widgets/shake_form_field.dart';
import 'package:alephium_wallet/routes/widgets/appbar_icon_button.dart';
import 'package:alephium_wallet/services/authentication_service.dart';
import 'package:alephium_wallet/storage/models/address_store.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/routes/wallet_settings/widgets/wallet_data_dialog.dart';
import 'package:alephium_wallet/routes/widgets/confirmation_dialog.dart';
import 'package:alephium_wallet/routes/widgets/wallet_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WalletSetting extends StatefulWidget {
  final WalletDetailsBloc detailsBloc;
  const WalletSetting({
    Key? key,
    required this.detailsBloc,
  }) : super(key: key);

  @override
  State<WalletSetting> createState() => _WalletSettingState();
}

class _WalletSettingState extends State<WalletSetting> {
  late FocusNode _focusNode;
  late final WalletSettingBloc _settingBloc;
  late final GlobalKey<ShakeTextFormFieldState> _nameKey;
  late final ScrollController controller;

  @override
  void initState() {
    _nameKey = GlobalKey<ShakeTextFormFieldState>();
    _settingBloc = WalletSettingBloc(
      widget.detailsBloc.wallet,
      getIt.get<AuthenticationService>(),
    );
    _focusNode = FocusNode();
    controller = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _settingBloc.close();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletSettingBloc, WalletSettingState>(
      bloc: _settingBloc,
      listener: (context, state) {
        if (state is WalletSettingDisplayDataState) {
          showDialog(
              context: context,
              builder: (_) {
                return WalletSettingDataDialog(
                  isSecure: state.isSecure,
                  title: state.title,
                  data: state.data,
                );
              });
        } else if (state is WalletSettingErrorState) {
          context.showSnackBar(state.message, level: Level.error);
        }
      },
      child: GestureDetector(
        onTap: () {
          _focusNode.unfocus();
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              Positioned.fill(
                child: ListView(
                  controller: controller,
                  padding: EdgeInsets.only(
                    top: 70.h + context.topPadding,
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: ShakeTextFormField(
                        focusNode: _focusNode,
                        key: _nameKey,
                        initialValue: widget.detailsBloc.wallet.title,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        validator: ((value) {
                          var validator = RegExp(r'^[1-9A-HJ-NP-Za-km-z]+$');
                          if (!validator.hasMatch(value!)) {
                            return 'Invalid Address';
                          }
                          return null;
                        }),
                        onChanged: (value) {},
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: InputDecoration(
                          labelText: 'walletName'.tr(),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Hero(
                        tag: "button",
                        child: OutlinedButton(
                          onPressed: () {
                            _focusNode.unfocus();
                            if (_nameKey.currentState?.value != null &&
                                _nameKey.currentState!.value!.trim().isNotEmpty)
                              widget.detailsBloc.add(UpdateWalletName(
                                  _nameKey.currentState!.value!));
                          },
                          child: Text(
                            "apply".tr(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(),
                    if (widget.detailsBloc.wallet.type ==
                        WalletType.multisig) ...[
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "signersSettingButton".tr(),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      OutlinedButton(
                        onPressed: () {
                          _focusNode.unfocus();
                          Navigator.pushNamed(context, Routes.addresses,
                              arguments: {
                                "wallet": WalletStore(
                                    id: "",
                                    mainAddress: "",
                                    type: WalletType.multisig,
                                    addresses: [
                                      ...widget.detailsBloc.wallet.signatures!
                                          .mapIndexed(
                                        (index, e) => AddressStore(
                                          address: getIt
                                              .get<BaseWalletService>()
                                              .addressFromPublicKey(e),
                                          index: index,
                                          publicKey: e,
                                          walletId: "",
                                        ),
                                      ),
                                    ]),
                              });
                        },
                        child: Text(
                          "addresses".tr(),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Divider(),
                    ],
                    if (widget.detailsBloc.wallet.type ==
                        WalletType.normal) ...[
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "derivedAddresses".tr(),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      OutlinedButton(
                        onPressed: () {
                          _focusNode.unfocus();
                          Navigator.pushNamed(context, Routes.addresses,
                              arguments: {
                                "wallet-details": widget.detailsBloc,
                              });
                        },
                        child: Text(
                          "addresses".tr(),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Divider(),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "readOnlyDescription".tr(),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      OutlinedButton(
                        onPressed: () {
                          _focusNode.unfocus();
                          _settingBloc.add(WalletSettingDisplayPublicKey());
                        },
                        child: Text(
                          "displayPublicKey".tr(),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Divider(),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "displayMnemonicDescription".tr(),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      OutlinedButton(
                          onPressed: () {
                            _focusNode.unfocus();
                            _settingBloc.add(WalletSettingDisplayMnemonic());
                          },
                          child: Text(
                            "displayMnemonic".tr(),
                          )),
                    ]
                  ],
                ),
              ),
              WalletAppBar(
                controller: controller,
                label: Text(
                  'walletSetting'.tr(),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                action: AppBarIconButton(
                    tooltip: "deleteWallet".tr(),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) => WalletConfirmationDialog(
                                title: "deleteWallet".tr(),
                                data: "deleteWalletDescription".tr(),
                                onConfirmTap: () {
                                  BlocProvider.of<WalletHomeBloc>(context).add(
                                      WalletHomeRemoveWallet(
                                          widget.detailsBloc.wallet.id));
                                  Navigator.popUntil(
                                      context, (route) => route.isFirst);
                                },
                              ));
                    },
                    icon: Icon(
                      Icons.delete,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
