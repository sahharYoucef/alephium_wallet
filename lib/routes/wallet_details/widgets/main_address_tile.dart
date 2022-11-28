import 'package:alephium_wallet/bloc/wallet_details/wallet_details_bloc.dart';
import 'package:alephium_wallet/routes/constants.dart';
import 'package:alephium_wallet/routes/wallet_details/widgets/address_text.dart';
import 'package:alephium_wallet/routes/widgets/gradient_icon.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

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
    return Center(
      child: PhysicalModel(
        borderRadius: BorderRadius.circular(16.0),
        color: Colors.white,
        elevation: 1,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: WalletTheme.instance.maxWidth,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(16.0),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${'addresses'.tr()} :",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Divider(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var address in wallet.addresses.take(3))
                    Row(
                      children: [
                        GradientIcon(
                          icon: wallet.mainAddress == address.address
                              ? Icons.star
                              : Icons.circle,
                          size: 12,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: AddressText(
                            address: "${address.address}",
                            style: Theme.of(context).textTheme.bodyMedium!,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(
                    height: 4,
                  ),
                  Material(
                    color: WalletTheme.instance.secondary,
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
                          'showMoreAddresses'.tr(),
                          style: Theme.of(context).textTheme.bodyMedium!,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
