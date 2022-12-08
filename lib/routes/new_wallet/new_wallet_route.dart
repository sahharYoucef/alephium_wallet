import 'package:alephium_wallet/bloc/create_wallet/create_wallet_bloc.dart';
import 'package:alephium_wallet/routes/constants.dart';
import 'package:alephium_wallet/routes/wallet_details/widgets/alephium_icon.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/routes/new_wallet/widgets/new_wallet_checkbox.dart';
import 'package:alephium_wallet/routes/widgets/wallet_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NewWalletPage extends StatefulWidget {
  const NewWalletPage({Key? key}) : super(key: key);

  @override
  State<NewWalletPage> createState() => _NewWalletPageState();
}

class _NewWalletPageState extends State<NewWalletPage> {
  late final CreateWalletBloc _createWalletBloc;
  String? selected;

  @override
  void initState() {
    FlutterNativeSplash.remove();
    _createWalletBloc = CreateWalletBloc();
    super.initState();
  }

  @override
  void dispose() {
    _createWalletBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateWalletBloc, CreateWalletState>(
      bloc: _createWalletBloc,
      listener: ((context, state) {
        if (state is CreateWalletGenerateMnemonicSuccess) {
          Navigator.pushNamed(
            context,
            Routes.walletMnemonic,
            arguments: {
              "wallet": state.wallet,
              "bloc": _createWalletBloc,
            },
          );
        }
        if (state is CreateWalletFailure) {
          context.showSnackBar(state.error, level: Level.error);
        }
        if (state is SaveWalletToDatabaseSuccess) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.home,
            (Route<dynamic> route) => false,
          );
        }
      }),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  WalletAppBar(
                    label: Text(
                      'newWallet'.tr(),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Form(
                          child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          NewWalletCheckbox(
                            title: "newWallet".tr(),
                            description: "newWalletDescription".tr(),
                            value: "new",
                            onTap: (value) {
                              setState(() {
                                if (selected == value)
                                  selected = null;
                                else
                                  selected = value;
                              });
                            },
                            selected: selected,
                            icon: Icons.create,
                          ),
                          NewWalletCheckbox(
                            title: "restoreWallet".tr(),
                            description: "restoreWalletDescription".tr(),
                            value: "restore",
                            selected: selected,
                            onTap: (value) {
                              setState(() {
                                if (selected == value)
                                  selected = null;
                                else
                                  selected = value;
                              });
                            },
                            icon: Icons.restore,
                          ),
                          NewWalletCheckbox(
                            title: "readOnlyWallet".tr(),
                            description: "readOnlyWalletDescription".tr(),
                            value: "read-only",
                            selected: selected,
                            onTap: (value) {
                              setState(() {
                                if (selected == value)
                                  selected = null;
                                else
                                  selected = value;
                              });
                            },
                            icon: Icons.lock_rounded,
                          ),
                          NewWalletCheckbox(
                            title: "multisigWallet".tr(),
                            description: "multisigWalletDescription".tr(),
                            value: "multisig",
                            selected: selected,
                            onTap: (value) {
                              setState(() {
                                if (selected == value)
                                  selected = null;
                                else
                                  selected = value;
                              });
                            },
                            icon: Icons.multiple_stop,
                          ),
                        ],
                      )),
                    ),
                  ),
                  SafeArea(
                    top: false,
                    bottom: true,
                    minimum: EdgeInsets.only(
                        left: 16.w, right: 16.w, top: 16.h, bottom: 16.h),
                    child: Hero(
                      tag: "button",
                      child: OutlinedButton(
                        onPressed: selected != null
                            ? () {
                                if (selected == "new")
                                  _createWalletBloc.add(
                                    CreateWalletGenerateMnemonic(
                                      passphrase: '',
                                    ),
                                  );
                                else if (selected == "restore")
                                  Navigator.pushNamed(
                                    context,
                                    Routes.restoreWallet,
                                    arguments: {
                                      "bloc": _createWalletBloc,
                                    },
                                  );
                                else if (selected == "read-only")
                                  Navigator.pushNamed(
                                    context,
                                    Routes.readOnlyWallet,
                                    arguments: {
                                      "bloc": _createWalletBloc,
                                    },
                                  );
                                else if (selected == "multisig")
                                  Navigator.pushNamed(
                                    context,
                                    Routes.multisigWallet,
                                    arguments: {
                                      "bloc": _createWalletBloc,
                                    },
                                  );
                              }
                            : null,
                        child: Text("next".tr()),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: BlocBuilder<CreateWalletBloc, CreateWalletState>(
                  bloc: _createWalletBloc,
                  buildWhen: (previous, current) {
                    return current is GenerateWalletLoading ||
                        previous is GenerateWalletLoading;
                  },
                  builder: (context, state) {
                    return Visibility(
                      visible: state is GenerateWalletLoading,
                      child: Container(
                        height: double.infinity,
                        width: double.infinity,
                        color: Colors.black.withOpacity(0.3),
                        child: Center(
                          child: AlephiumIcon(
                            spinning: true,
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
