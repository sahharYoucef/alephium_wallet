import 'package:alephium_wallet/routes/wallet_details/widgets/address_text.dart';
import 'package:alephium_wallet/routes/widgets/gradient_icon.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:alephium_wallet/storage/models/address_store.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AddressQRDialog extends StatefulWidget {
  final AddressStore addressStore;
  AddressQRDialog({
    Key? key,
    required this.addressStore,
  }) : super(key: key);

  @override
  State<AddressQRDialog> createState() => _AddressQRDialogState();
}

class _AddressQRDialogState extends State<AddressQRDialog>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;
  late String _value;
  @override
  void initState() {
    _controller = TabController(length: 2, vsync: this);
    _value = widget.addressStore.address;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h, bottom: 16.h),
      child: ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        children: [
          TabBar(
            splashBorderRadius: BorderRadius.circular(8),
            indicator: BoxDecoration(
                color: WalletTheme.instance.buttonsBackground,
                border: Border.all(
                  color: WalletTheme.instance.primary,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8)),
            onTap: (value) {
              if (value == 0) {
                _value = widget.addressStore.address;
              } else {
                _value = widget.addressStore.publicKey!;
              }
              setState(() {});
            },
            labelColor: WalletTheme.instance.buttonsForeground,
            unselectedLabelColor: WalletTheme.instance.textColor,
            controller: _controller,
            tabs: [
              Tab(
                child: Text('Address'),
              ),
              Tab(
                child: Text('Public Key'),
              )
            ],
          ),
          const SizedBox(
            height: 6,
          ),
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: WalletTheme.instance.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: QrImage(
                data: _value,
                backgroundColor: Colors.transparent,
                foregroundColor: WalletTheme.instance.textColor,
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: AddressText(
                    address: _value,
                    align: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                IconButton(
                    tooltip: "copy".tr(),
                    onPressed: () async {
                      var data = ClipboardData(text: _value);
                      await Clipboard.setData(data);
                      context.showSnackBar(
                        "addressCopied".tr(),
                      );
                    },
                    icon: GradientIcon(
                      icon: Icons.copy,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
