import 'package:alephium_wallet/bloc/wallet_details/wallet_details_bloc.dart';
import 'package:alephium_wallet/routes/wallet_details/widgets/alephium_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

class StickyHeader extends StatelessWidget {
  final WalletDetailsState state;
  final Widget sliver;
  const StickyHeader(this.state, {super.key, required this.sliver});

  @override
  Widget build(BuildContext context) {
    return SliverStickyHeader(
        sliver: sliver,
        header: PhysicalModel(
            color: Theme.of(context).primaryColor,
            shadowColor: Colors.black54,
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Transactions',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Spacer(),
                  AlephiumIcon(
                    spinning: state is WalletDetailsCompleted &&
                        (state as WalletDetailsCompleted).withLoadingIndicator,
                  )
                ],
              ),
            )));
  }
}
