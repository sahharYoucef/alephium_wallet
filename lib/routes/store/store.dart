import 'package:alephium_wallet/routes/store/widgets/store_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/store/store_bloc.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          BlocBuilder<StoreBloc, StoreState>(
            builder: (context, state) {
              final items = context
                  .read<StoreBloc>()
                  .events
                  .reversed
                  .where((element) => element.kind == 0)
                  .toList();
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => StoreTile(
                    event: items[index],
                  ),
                  childCount: items.length,
                ),
              );
            },
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 120),
          )
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              context.read<StoreBloc>().add(SendNostrEvent());
            }),
      ),
    );
  }
}
