import 'package:alephium_wallet/storage/app_storage.dart';
import 'package:alephium_wallet/storage/models/address_store.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddressTile extends StatelessWidget {
  final AddressStore address;
  final bool isMain;
  final void Function() onTap;
  const AddressTile(
      {Key? key,
      required this.address,
      required this.isMain,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        elevation: 0,
        color: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: isMain
                ? BorderSide(color: Colors.orange, width: 2)
                : BorderSide.none),
        child: InkWell(
          customBorder:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        address.title ?? "",
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      "index : ${address.index}",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Group : ${address.group.toString()}",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                Divider(
                  color: Colors.white,
                  thickness: 2,
                ),
                RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: "Balance : ",
                      style: Theme.of(context).textTheme.headlineSmall),
                  TextSpan(
                      text: "${address.formattedBalance}",
                      style: Theme.of(context).textTheme.headlineSmall),
                  if (address.balanceConverted != null &&
                      address.balance?.balance != "0.0000") ...[
                    TextSpan(
                        text: " = ",
                        style: Theme.of(context).textTheme.bodyMedium),
                    TextSpan(
                        text: "${address.balanceConverted}  ",
                        style: Theme.of(context).textTheme.bodyMedium),
                  ]
                ])),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        address.address,
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
                          var data = ClipboardData(text: address.address);
                          await Clipboard.setData(data);
                          context.showSnackBar("address copied to clipboard!");
                        },
                        icon: Icon(Icons.copy))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
