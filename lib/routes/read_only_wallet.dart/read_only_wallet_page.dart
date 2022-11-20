import 'package:alephium_wallet/bloc/create_wallet/create_wallet_bloc.dart';
import 'package:alephium_wallet/routes/widgets/appbar_icon_button.dart';
import 'package:alephium_wallet/routes/widgets/wallet_appbar.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ReadOnlyWalletPage extends StatefulWidget {
  const ReadOnlyWalletPage({
    super.key,
    required this.bloc,
  });
  final CreateWalletBloc bloc;

  @override
  State<ReadOnlyWalletPage> createState() => _ReadOnlyWalletPageState();
}

class _ReadOnlyWalletPageState extends State<ReadOnlyWalletPage> {
  late final GlobalKey<FormFieldState> _nameKey;
  late final GlobalKey<FormFieldState> _addressValueKey;
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _controller;
  @override
  void initState() {
    _nameKey = GlobalKey<FormFieldState>();
    _addressValueKey = GlobalKey<FormFieldState>();
    _formKey = GlobalKey<FormState>();
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Positioned.fill(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 70 + context.topPadding,
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  child: Column(
                    children: [
                      Spacer(),
                      Text(
                        "enterAddressOrPublicKey".tr(),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        key: _nameKey,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return null;
                          }
                          var validator = RegExp(r'^[1-9A-HJ-NP-Za-km-z]+$');
                          if (!validator.hasMatch(value!)) {
                            return 'Invalid Address';
                          }
                          return null;
                        },
                        onChanged: (value) {},
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: InputDecoration(
                          labelText: 'walletName'.tr(),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        key: _addressValueKey,
                        controller: _controller,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        // validator: ((value) {
                        //   var validator = RegExp(r'^[1-9A-HJ-NP-Za-km-z]+$');
                        //   if (!validator.hasMatch(value!)) {
                        //     return 'Invalid Address';
                        //   }
                        //   return null;
                        // }),
                        onChanged: (value) {},
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: InputDecoration(
                          labelText: 'Address or Public Key',
                        ),
                      ),
                      Spacer(),
                      const SizedBox(
                        height: 10,
                      ),
                      Hero(
                        tag: "button",
                        child: OutlinedButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              if (_addressValueKey.currentState?.value !=
                                      null &&
                                  _addressValueKey.currentState!.value
                                      .trim()
                                      .isNotEmpty)
                                widget.bloc.add(
                                  AddReadOnlyWallet(
                                    value: _addressValueKey.currentState!.value,
                                  ),
                                );
                            },
                            child: Text("confirm".tr())),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            WalletAppBar(
              label: Text(
                'readOnlyWallet'.tr(),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              action: AppBarIconButton(
                tooltip: "QRscanner".tr(),
                icon: Icon(
                  Icons.qr_code_scanner,
                ),
                onPressed: () async {
                  var data = await showQRView(
                    context,
                    isTransfer: false,
                  );
                  if (data?["address"] != null &&
                      data!["address"] is String &&
                      data["address"].trim().isNotEmpty) {
                    setState(() {
                      _controller.text = data["address"];
                    });
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
