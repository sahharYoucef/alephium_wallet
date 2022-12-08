import 'package:alephium_wallet/bloc/create_wallet/create_wallet_bloc.dart';
import 'package:alephium_wallet/routes/send/widgets/shake_form_field.dart';
import 'package:alephium_wallet/routes/widgets/appbar_icon_button.dart';
import 'package:alephium_wallet/routes/widgets/wallet_appbar.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  late final GlobalKey<ShakeTextFormFieldState> _nameKey;
  late final GlobalKey<ShakeTextFormFieldState> _addressValueKey;
  late final GlobalKey<ShakeFormState> _formKey;
  late final TextEditingController _controller;
  @override
  void initState() {
    _nameKey = GlobalKey<ShakeTextFormFieldState>();
    _addressValueKey = GlobalKey<ShakeTextFormFieldState>();
    _formKey = GlobalKey<ShakeFormState>();
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
              child: ShakeForm(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 70 + context.topPadding,
                    left: 16.w,
                    right: 16.w,
                  ),
                  child: Column(
                    children: [
                      Spacer(),
                      Text(
                        "enterAddressOrPublicKey".tr(),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      ShakeTextFormField(
                        key: _nameKey,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        onChanged: (value) {},
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: InputDecoration(
                          labelText: 'walletName'.tr(),
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      ShakeTextFormField(
                        key: _addressValueKey,
                        controller: _controller,
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
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: InputDecoration(
                          labelText: 'Address or Public Key',
                        ),
                      ),
                      Spacer(),
                      SafeArea(
                        top: false,
                        bottom: true,
                        minimum: EdgeInsets.only(top: 16.h, bottom: 16.h),
                        child: Hero(
                          tag: "button",
                          child: OutlinedButton(
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                if (_controller.text.trim().isNotEmpty)
                                  widget.bloc.add(
                                    AddReadOnlyWallet(
                                        value: _controller.text,
                                        title: _nameKey.currentState?.value),
                                  );
                              },
                              child: Text("confirm".tr())),
                        ),
                      )
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
