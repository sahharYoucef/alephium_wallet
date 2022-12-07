import 'package:alephium_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:alephium_wallet/routes/send/widgets/shake_form_field.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomNetworkSetting extends StatefulWidget {
  final String? explorerApiHost;
  final String? explorerUrl;
  final String? nodeHost;
  CustomNetworkSetting({
    Key? key,
    this.explorerUrl,
    this.explorerApiHost,
    this.nodeHost,
  }) : super(key: key);

  @override
  State<CustomNetworkSetting> createState() => _CustomNetworkSettingState();
}

class _CustomNetworkSettingState extends State<CustomNetworkSetting>
    with InputValidators {
  final GlobalKey<ShakeFormState> _formKey = GlobalKey<ShakeFormState>();
  String? explorerApiHost;
  String? explorerUrl;
  String? nodeHost;
  final RegExp _urlValidator = RegExp(
      r"https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)");
  @override
  void initState() {
    explorerApiHost = widget.explorerApiHost;
    explorerUrl = widget.explorerUrl;
    nodeHost = widget.nodeHost;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        bottom: 16.h + context.viewInsetsBottom,
      ),
      child: Material(
          elevation: 3,
          borderRadius: BorderRadius.circular(16.0),
          color: WalletTheme.instance.background,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: ShakeForm(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "customNodeUrls".tr(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  const Divider(),
                  SizedBox(
                    height: 8.h,
                  ),
                  ShakeTextFormField(
                    validator: (value) {
                      if (_urlValidator.hasMatch("${value}")) return null;
                      return "invalidUrl".tr();
                    },
                    initialValue: widget.nodeHost,
                    onChanged: (value) {
                      nodeHost = value;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    autofocus: true,
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: InputDecoration(
                      label: Text(
                        "nodeHostUrl".tr(),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  ShakeTextFormField(
                    validator: (value) {
                      if (_urlValidator.hasMatch("${value}")) return null;
                      return "invalidUrl".tr();
                    },
                    initialValue: widget.explorerUrl,
                    onChanged: (value) {
                      explorerUrl = value;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: InputDecoration(
                      label: Text(
                        "explorerUrl".tr(),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  ShakeTextFormField(
                    initialValue: widget.explorerApiHost,
                    validator: (value) {
                      if (_urlValidator.hasMatch("${value}")) return null;
                      return "invalidUrl".tr();
                    },
                    onChanged: (value) {
                      explorerApiHost = value;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    autofocus: true,
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: InputDecoration(
                      label: Text(
                        "explorerApiUrl".tr(),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 12.h,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Hero(
                          tag: "button",
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "cancel".tr(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Hero(
                          tag: "button",
                          child: OutlinedButton(
                            onPressed: () {
                              final isValid =
                                  _formKey.currentState?.validate(shake: true);
                              if (isValid ?? false) {
                                final data = {
                                  'nodeHost': nodeHost,
                                  'explorerApiHost': explorerApiHost,
                                  'explorerUrl': explorerUrl,
                                };
                                Navigator.pop<Map<String, String?>?>(
                                  context,
                                  data,
                                );
                              }
                            },
                            child: Text(
                              "save".tr(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }

  @override
  TransactionBloc? get bloc => null;

  @override
  WalletStore? get wallet => null;
}
