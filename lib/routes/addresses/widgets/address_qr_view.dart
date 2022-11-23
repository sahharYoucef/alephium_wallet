import 'package:alephium_wallet/routes/wallet_details/widgets/address_text.dart';
import 'package:alephium_wallet/routes/widgets/gradient_icon.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:alephium_wallet/storage/models/address_store.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AddressQRDialog extends StatelessWidget {
  final AddressStore addressStore;
  AddressQRDialog({
    Key? key,
    required this.addressStore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        children: [
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
                data: addressStore.address,
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
          Row(
            children: [
              Expanded(
                child: AddressText(
                  address: addressStore.address,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        foreground: Paint()
                          ..shader = LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              WalletTheme.instance.gradientOne,
                              WalletTheme.instance.gradientTwo,
                            ],
                          ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                      ),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              IconButton(
                  tooltip: "copy".tr(),
                  onPressed: () async {
                    var data = ClipboardData(text: addressStore.address);
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
        ],
      ),
    );
  }
}
