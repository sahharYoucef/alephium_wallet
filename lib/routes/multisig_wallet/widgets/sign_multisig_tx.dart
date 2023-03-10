import 'dart:convert';

import 'package:alephium_wallet/api/repositories/base_api_repository.dart';
import 'package:alephium_wallet/bloc/sign_tx/sign_tx_bloc.dart';
import 'package:alephium_wallet/bloc/wallet_home/wallet_home_bloc.dart';
import 'package:alephium_wallet/encryption/base_wallet_service.dart';
import 'package:alephium_wallet/main.dart';
import 'package:alephium_wallet/routes/multisig_wallet/widgets/tx_verify_dialog.dart';
import 'package:alephium_wallet/routes/multisig_wallet/widgets/wallets_drop_down.dart';
import 'package:alephium_wallet/routes/send/widgets/address_from.dart';
import 'package:alephium_wallet/routes/wallet_details/widgets/alephium_icon.dart';
import 'package:alephium_wallet/routes/widgets/appbar_icon_button.dart';
import 'package:alephium_wallet/routes/widgets/wallet_appbar.dart';
import 'package:alephium_wallet/services/authentication_service.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SignMultisigTxView extends StatefulWidget {
  SignMultisigTxView({
    Key? key,
  }) : super(key: key);

  @override
  State<SignMultisigTxView> createState() => _SignMultisigTxViewState();
}

class _SignMultisigTxViewState extends State<SignMultisigTxView> {
  late final TextEditingController _controller;
  late final SignTxBloc _bloc;
  WalletStore? wallet;
  @override
  void initState() {
    _bloc = SignTxBloc(
      getIt.get<BaseWalletService>(),
      getIt.get<AuthenticationService>(),
      getIt.get<BaseApiRepository>(),
    );
    _controller =
        TextEditingController(text: "Please copy transaction details");
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Positioned.fill(
          child: BlocConsumer<SignTxBloc, SignTxState>(
            bloc: _bloc,
            listener: (context, state) async {
              if (state is SignTxError) {
                context.showSnackBar(state.message, level: Level.error);
              } else if (state is TxIdVerifyCompleted) {
                await showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) => TransactionVerifyDialog(
                          transaction: state.tx,
                        ));
              }
            },
            builder: (context, state) {
              return Column(children: [
                WalletAppBar(
                  label: Text(
                    'signMultisigTx'.tr(),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  action: AppBarIconButton(
                    tooltip: "QRscanner".tr(),
                    icon: Icon(
                      CupertinoIcons.qrcode_viewfinder,
                    ),
                    onPressed: () async {
                      var data = await showQRView(
                        context,
                        isTransfer: false,
                      );
                      if (data == null) return;
                      if (data["txId"] != null && data["unsignedTx"] != null) {
                        _bloc.add(UpdateSignTxDataEvent(
                          walletStore: wallet,
                          txId: data["txId"],
                          unsignedTx: data["unsignedTx"],
                          address: _bloc.addressStore,
                        ));
                      } else {
                        context.showSnackBar(
                          "invalidTransactionDetails".tr(),
                          level: Level.error,
                        );
                      }
                    },
                  ),
                ),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        sliver: SliverList(
                            delegate: SliverChildListDelegate(
                          [
                            SizedBox(
                              height: 20.h,
                            ),
                            Text(
                              "selectSignerAddress".tr(),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            WalletDropdownButton(
                                bloc: context.read<WalletHomeBloc>(),
                                onChanged: (value) {
                                  wallet = value;
                                  _bloc.add(UpdateSignTxDataEvent(
                                    walletStore: wallet,
                                    address: null,
                                    txId: _bloc.txId,
                                    unsignedTx: _bloc.unsignedTx,
                                  ));
                                }),
                            const SizedBox(
                              height: 10,
                            ),
                            AddressFromDropDownMenu(
                              addresses: wallet?.addresses,
                              label: "chooseAddress".tr(),
                              onChanged: (address) {
                                _bloc.add(UpdateSignTxDataEvent(
                                  walletStore: wallet,
                                  address: address,
                                  txId: _bloc.txId,
                                  unsignedTx: _bloc.unsignedTx,
                                ));
                              },
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Text(
                              "pasteTxId".tr(),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            TextFormField(
                              readOnly: true,
                              controller: _controller,
                              style: Theme.of(context).textTheme.bodyMedium,
                              decoration: InputDecoration(
                                suffixIcon: _bloc.txId != null
                                    ? Icon(
                                        Icons.check,
                                        color: Colors.green,
                                      )
                                    : Icon(
                                        Icons.warning_outlined,
                                        color: WalletTheme.instance.errorColor,
                                      ),
                              ),
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      var text =
                                          await Clipboard.getData("text/plain");
                                      if (text != null) {
                                        try {
                                          var data = json.decode(text.text!);
                                          _controller.text = "txIdFilled".tr();
                                          final txId = data["txId"];
                                          final unsignedTx = data["unsignedTx"];
                                          _bloc.add(UpdateSignTxDataEvent(
                                            walletStore: wallet,
                                            txId: txId,
                                            unsignedTx: unsignedTx,
                                            address: _bloc.addressStore,
                                          ));
                                        } catch (_) {
                                          context.showSnackBar(
                                              "invalidTransactionDetails".tr(),
                                              level: Level.error);
                                        }
                                      }
                                    },
                                    child: Text(
                                      "paste".tr(),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      maximumSize: Size.fromHeight(40.h),
                                      minimumSize: Size.fromHeight(40.h),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 20.h,
                                ),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: (state is SignTxCompleted)
                                        ? () {
                                            _controller.text = "pasteTxId".tr();
                                            _bloc.add(UpdateSignTxDataEvent(
                                              walletStore: wallet,
                                              txId: null,
                                              unsignedTx: null,
                                              address: _bloc.addressStore,
                                            ));
                                          }
                                        : null,
                                    child: Text(
                                      "clear".tr(),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      maximumSize: Size.fromHeight(40.h),
                                      minimumSize: Size.fromHeight(40.h),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        )),
                      ),
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 10.h,
                            ),
                            Expanded(
                              child: Center(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: state is SignTxCompleted
                                      ? Container(
                                          height: 200.h,
                                          decoration: BoxDecoration(
                                            color: WalletTheme.instance.primary,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: QrImageView(
                                            padding: EdgeInsets.all(8.w),
                                            data: state.signature,
                                            backgroundColor: Colors.transparent,
                                            foregroundColor:
                                                WalletTheme.instance.textColor,
                                            version: QrVersions.auto,
                                          ),
                                        )
                                      : state is TxIdVerifyCompleted
                                          ? Icon(
                                              Icons.check_circle_outline,
                                              color: Colors.green,
                                              size: 100,
                                            )
                                          : SizedBox(),
                                ),
                              ),
                            ),
                            if (state is SignTxCompleted)
                              SafeArea(
                                  top: false,
                                  bottom: true,
                                  minimum: EdgeInsets.only(
                                      left: 16.w,
                                      right: 16.w,
                                      top: 16.h,
                                      bottom: 16.h),
                                  child: Hero(
                                      tag: "button",
                                      child: OutlinedButton(
                                        onPressed: () async {
                                          var data = ClipboardData(
                                              text: state.signature);
                                          await Clipboard.setData(data);
                                          context.showSnackBar(
                                            "addressCopied".tr(),
                                          );
                                        },
                                        child: Text(
                                          "copySignature".tr(),
                                        ),
                                      )))
                            else if (state is TxIdVerifyCompleted)
                              SafeArea(
                                  top: false,
                                  bottom: true,
                                  minimum: EdgeInsets.only(
                                      left: 16.w,
                                      right: 16.w,
                                      top: 16.h,
                                      bottom: 16.h),
                                  child: Hero(
                                    tag: "button",
                                    child: OutlinedButton(
                                      child: Text("signTransaction".tr()),
                                      onPressed: _bloc.activateButton
                                          ? () {
                                              _bloc.add(
                                                SignMultisigTransaction(),
                                              );
                                            }
                                          : null,
                                    ),
                                  ))
                            else
                              SafeArea(
                                top: false,
                                bottom: true,
                                minimum: EdgeInsets.only(
                                    left: 16.w,
                                    right: 16.w,
                                    top: 16.h,
                                    bottom: 16.h),
                                child: Hero(
                                  tag: "button",
                                  child: OutlinedButton(
                                    child: Text("verifyTransaction".tr()),
                                    onPressed: _bloc.activateButton
                                        ? () {
                                            _bloc.add(
                                              VerifyMultisigTransaction(),
                                            );
                                          }
                                        : null,
                                  ),
                                ),
                              )
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ]);
            },
          ),
        ),
        Positioned.fill(
          child: BlocBuilder<SignTxBloc, SignTxState>(
              bloc: _bloc,
              buildWhen: (previous, current) {
                return current is SignTxLoading || previous is SignTxLoading;
              },
              builder: (context, state) {
                return Visibility(
                  visible: state is SignTxLoading,
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
    ));
  }
}
