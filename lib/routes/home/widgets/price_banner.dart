import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../../bloc/wallet_home/wallet_home_bloc.dart';
import '../../../storage/app_storage.dart';
import '../../wallet_details/widgets/alephium_icon.dart';

class PriceBanner extends StatelessWidget {
  const PriceBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletHomeBloc, WalletHomeState>(
      builder: (context, state) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AlephiumIcon(
              spinning:
                  state is WalletHomeCompleted && state.withLoadingIndicator,
            ),
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${AppStorage.instance.formattedPrice ?? ''}",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  AutoSizeText(
                    'alephiumWallet'.tr(),
                    maxLines: 1,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }
}
