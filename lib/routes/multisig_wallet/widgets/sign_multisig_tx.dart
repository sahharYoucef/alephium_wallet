import 'package:alephium_wallet/bloc/sign_tx/sign_tx_bloc.dart';
import 'package:alephium_wallet/bloc/wallet_home/wallet_home_bloc.dart';
import 'package:alephium_wallet/encryption/base_wallet_service.dart';
import 'package:alephium_wallet/main.dart';
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
            listener: (context, state) {
              if (state is SignTxError) {
                context.showSnackBar(state.message, level: Level.error);
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
                      if (data?["address"] != null &&
                          data!["address"] is String &&
                          data["address"].trim().isNotEmpty) {
                        _bloc.add(UpdateSignTxDataEvent(
                          walletStore: wallet,
                          txId: data["address"],
                          address: _bloc.addressStore,
                        ));
                      }
                    },
                  ),
                ),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                            delegate: SliverChildListDelegate(
                          [
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Please select wallet address to used a signer from your wallets"
                                  .tr(),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            WalletDropdownButton(
                                bloc: context.read<WalletHomeBloc>(),
                                onChanged: (value) {
                                  wallet = value;
                                  _bloc.add(UpdateSignTxDataEvent(
                                    walletStore: wallet,
                                    address: null,
                                    txId: _bloc.txId,
                                  ));
                                }),
                            const SizedBox(
                              height: 10,
                            ),
                            AddressFromDropDownMenu(
                              addresses: wallet?.addresses,
                              label: "Choose address",
                              onChanged: (address) {
                                _bloc.add(UpdateSignTxDataEvent(
                                  walletStore: wallet,
                                  address: address,
                                  txId: _bloc.txId,
                                ));
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Please enter the transaction id".tr(),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(
                              height: 10,
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
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      var text =
                                          await Clipboard.getData("text/plain");
                                      _controller.text =
                                          "Transaction details copied!";
                                      final txId = text?.text;
                                      _bloc.add(UpdateSignTxDataEvent(
                                        walletStore: wallet,
                                        txId: txId,
                                        address: _bloc.addressStore,
                                      ));
                                    },
                                    child: Text(
                                      "paste".tr(),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      maximumSize: Size.fromHeight(40),
                                      minimumSize: Size.fromHeight(40),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: (state is SignTxCompleted)
                                        ? () {
                                            _controller.text =
                                                "Please copy transaction details";
                                            _bloc.add(UpdateSignTxDataEvent(
                                              walletStore: wallet,
                                              txId: null,
                                              address: _bloc.addressStore,
                                            ));
                                          }
                                        : null,
                                    child: Text(
                                      "clear".tr(),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      maximumSize: Size.fromHeight(40),
                                      minimumSize: Size.fromHeight(40),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            if (state is SignTxCompleted)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Center(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: WalletTheme.instance.primary,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: QrImage(
                                        data: state.signature,
                                        backgroundColor: Colors.transparent,
                                        foregroundColor:
                                            WalletTheme.instance.textColor,
                                        version: QrVersions.auto,
                                        size: 200.0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                          ],
                        )),
                      ),
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Column(
                          children: [
                            Spacer(),
                            if (state is SignTxCompleted)
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                  child: Hero(
                                      tag: "Button1",
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
                            else
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                child: Hero(
                                  tag: "Button1",
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
                                ),
                              ),
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
