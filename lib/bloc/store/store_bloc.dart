import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dart_nostr/dart_nostr.dart';
import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'store_event.dart';
part 'store_state.dart';

class StoreBloc extends Bloc<StoreEvent, StoreState> {
  StreamSubscription? streamSubscription;
  late final NostrKeyPairs keyPair;
  final queryTag = ["t", "alephium-wallet"];
  List<NostrEvent> events = [];
  StoreBloc() : super(StoreInitial()) {
    on<SubscribeToNostrRelays>(_subscribeToNostrRelays);
    on<SendNostrEvent>(_sendNostrEvent);
    on<NewEventAdded>((event, emit) {
      events.add(event.event);
      emit(NewEvent(List.from(events)));
    });
    on<ReactToEvent>(_reactToEvent);
    on<DeleteEvent>(_deleteEvent);
  }

  Future<void> _reactToEvent(
      ReactToEvent event, Emitter<StoreState> emit) async {
    final tags = event.event.tags
        .where((element) =>
            !(element.length >= 2 && (element[0] == "e" || element[0] == "p")))
        .toList();
    tags.add(["e", event.event.id]);
    tags.add(["p", event.event.pubkey]);
    final react = NostrEvent.fromPartialData(
        kind: 7, content: "+", keyPairs: keyPair, tags: tags);
    Nostr.instance.relaysService.sendEventToRelays(react);
  }

  Future<void> _deleteEvent(DeleteEvent event, Emitter<StoreState> emit) async {
    final tags = event.event.tags;
    tags.add(["e", event.event.id]);
    final react = NostrEvent.fromPartialData(
        kind: 5,
        content: "these posts were published by accident",
        keyPairs: keyPair,
        tags: tags);
    Nostr.instance.relaysService.sendEventToRelays(react);
  }

  Future<void> _subscribeToNostrRelays(
      SubscribeToNostrRelays event, Emitter<StoreState> emit) async {
    keyPair = Nostr.instance.keysService.generateKeyPair();
    await Nostr.instance.relaysService.init(
      relaysUrl: ["wss://relayable.org"],
      onRelayError: (relay, error) {
        print("Relay error: $error");
      },
      onRelayDone: (relayUrl) => print("Relay done: $relayUrl"),
      onRelayListening: (relayUrl, receivedData) {},
    );

    final notesKindList = <int>[0, 7, 5];
    // ignore: unused_local_variable
    final tTags = [queryTag];
    final sinceDateTime = DateTime.now().subtract(Duration(days: 2));
    final request = NostrRequest(
      filters: <NostrFilter>[
        NostrFilter(
          kinds: notesKindList,
          t: queryTag,
          authors: [keyPair.public],
          since: sinceDateTime,
        ),
      ],
    );

    final requestStream =
        Nostr.instance.relaysService.startEventsSubscription(request: request);
    streamSubscription = requestStream.stream.listen((event) {
      add(NewEventAdded(event: event));
    });
  }

  Future<void> _sendNostrEvent(
      SendNostrEvent event, Emitter<StoreState> emit) async {
    Nostr.instance.relaysService.sendEventToRelays(
      NostrEvent.fromPartialData(
          kind: 0,
          content: "test Alephium wallet - sahhar youcef",
          keyPairs: keyPair,
          tags: [queryTag]),
    );
  }
}

extension NostrHelper on NostrEvent {
  bool isLiked(BuildContext context) {
    List<NostrEvent> events = context.read<StoreBloc>().events;
    NostrEvent? reaction;
    for (final event in events.where((element) => element.kind == 7)) {
      for (final tag in event.tags) {
        if (tag.contains(this.id)) {
          reaction = event;
          break;
        }
      }
    }
    return reaction != null;
  }

  bool isDeleted(BuildContext context) {
    List<NostrEvent> events = context.read<StoreBloc>().events;
    NostrEvent? reaction;
    for (final event in events.where((element) => element.kind == 5)) {
      for (final tag in event.tags) {
        if (tag.contains(this.id)) {
          reaction = event;
          break;
        }
      }
    }
    return reaction != null;
  }
}
