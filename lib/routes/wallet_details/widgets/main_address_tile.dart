import 'package:alephium_wallet/bloc/wallet_details/wallet_details_bloc.dart';
import 'package:alephium_wallet/routes/constants.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class MainAddressTile extends StatelessWidget {
  final WalletStore wallet;
  final WalletDetailsBloc walletDetailsBloc;
  const MainAddressTile({
    Key? key,
    required this.wallet,
    required this.walletDetailsBloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
      borderRadius: BorderRadius.circular(16.0),
      color: Colors.white,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Main Address :',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Divider(
              color: Colors.white,
              thickness: 1,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var address in wallet.addresses.take(2))
                  Text(
                    address.address,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(overflow: TextOverflow.ellipsis),
                    maxLines: 1,
                  ),
                const SizedBox(
                  height: 4,
                ),
                Material(
                  color: Color(0xff797979),
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, Routes.addresses,
                          arguments: {"wallet-details": walletDetailsBloc});
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 16),
                      child: Text(
                        'show more addresses',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
