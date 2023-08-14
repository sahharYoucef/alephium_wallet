import 'package:dart_nostr/dart_nostr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/store/store_bloc.dart';

class StoreTile extends StatelessWidget {
  final NostrEvent event;
  const StoreTile({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final bool isLiked = event.isLiked(context);
    final bool isDeleted = event.isDeleted(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: IgnorePointer(
        ignoring: isDeleted,
        child: Material(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          color: isDeleted ? Colors.red : Colors.amberAccent,
          child: ListTile(
            onTap: () {},
            title: Text(event.content),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("-" + event.id),
                Text("-" + event.pubkey),
                for (final tag in event.tags) Text("-" + tag.toString()),
              ],
            ),
            trailing: !isLiked
                ? IconButton(
                    icon: Icon(Icons.thumb_up),
                    onPressed: () =>
                        context.read<StoreBloc>().add(ReactToEvent(event)),
                  )
                : Icon(
                    Icons.thumb_up,
                    color: Colors.blue,
                  ),
            leading: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () =>
                  context.read<StoreBloc>().add(DeleteEvent(event)),
            ),
          ),
        ),
      ),
    );
  }
}
