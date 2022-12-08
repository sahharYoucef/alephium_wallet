import 'package:alephium_wallet/routes/receive/widgets/amount_field.dart';
import 'package:alephium_wallet/routes/send/widgets/address_from.dart';
import 'package:alephium_wallet/routes/wallet_details/widgets/address_text.dart';
import 'package:alephium_wallet/routes/widgets/gradient_icon.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:alephium_wallet/storage/models/address_store.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReceivePage extends StatefulWidget {
  final WalletStore wallet;
  ReceivePage({
    Key? key,
    required this.wallet,
  }) : super(key: key);

  @override
  State<ReceivePage> createState() => _ReceivePageState();
}

class _ReceivePageState extends State<ReceivePage> {
  late AddressStore _addressStore;
  double? amount;

  @override
  void initState() {
    _addressStore = widget.wallet.addresses
        .firstWhere((element) => element.address == widget.wallet.mainAddress);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0.w),
      child: ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        children: [
          Text(
            "${'receive'.tr()} :",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(
            height: 6.h,
          ),
          Divider(),
          SizedBox(
            height: 6.h,
          ),
          AddressFromDropDownMenu(
            addresses: widget.wallet.addresses,
            label: "address".tr(),
            initialAddress: _addressStore,
            onChanged: (value) {
              if (value != null) _addressStore = value;
              setState(() {});
            },
          ),
          SizedBox(
            height: 6.h,
          ),
          Center(
            child: Container(
              height: 200.h,
              decoration: BoxDecoration(
                color: WalletTheme.instance.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: QrImage(
                data: _addressStore.receiveAmount(amount),
                backgroundColor: Colors.transparent,
                foregroundColor: WalletTheme.instance.textColor,
                version: QrVersions.auto,
              ),
            ),
          ),
          SizedBox(
            height: 6.h,
          ),
          Row(
            children: [
              Expanded(
                child: AddressText(
                  address: _addressStore.address,
                ),
              ),
              SizedBox(
                width: 8.w,
              ),
              IconButton(
                  tooltip: "copy".tr(),
                  onPressed: () async {
                    var data = ClipboardData(
                        text: widget.wallet.addresses.first.address);
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
          SizedBox(
            height: 6.h,
          ),
          ReceiveAmountField(
            onChanged: (_value) {
              amount = _value;
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}
