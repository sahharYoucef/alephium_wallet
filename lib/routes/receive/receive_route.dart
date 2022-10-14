import 'package:alephium_wallet/routes/receive/widgets/amount_field.dart';
import 'package:alephium_wallet/routes/send/widgets/address_from.dart';
import 'package:alephium_wallet/routes/wallet_details/widgets/alephium_icon.dart';
import 'package:alephium_wallet/storage/models/address_store.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late final GlobalKey _key;

  @override
  void initState() {
    _addressStore = widget.wallet.addresses
        .firstWhere((element) => element.address == widget.wallet.mainAddress);
    _key = GlobalKey();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Receive :",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(
          height: 6,
        ),
        Divider(),
        const SizedBox(
          height: 6,
        ),
        AddressFromDropDownMenu(
          addresses: widget.wallet.addresses,
          label: "Address",
          initialAddress: _addressStore,
          onChanged: (value) {
            _addressStore = value;
            setState(() {});
          },
        ),
        const SizedBox(
          height: 6,
        ),
        Center(
          child: Builder(
              key: _key,
              builder: (context) {
                return QrImage(
                  data: _addressStore.receiveAmount(amount),
                  backgroundColor: WalletTheme.instance.primary,
                  foregroundColor: WalletTheme.instance.textColor,
                  version: QrVersions.auto,
                  size: 200.0,
                );
              }),
        ),
        const SizedBox(
          height: 6,
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                _addressStore.address,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            IconButton(
                onPressed: () async {
                  var data = ClipboardData(
                      text: widget.wallet.addresses.first.address);
                  await Clipboard.setData(data);
                  context.showSnackBar(
                    "address copied to clipboard!",
                  );
                },
                icon: Icon(
                  Icons.copy,
                )),
          ],
        ),
        ReceiveAmountField(
          onChanged: (_value) {
            amount = _value;
            setState(() {});
          },
        ),
      ],
    );
  }
}
