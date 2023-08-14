part of 'store_bloc.dart';

abstract class StoreEvent extends Equatable {
  const StoreEvent();

  @override
  List<Object> get props => [];
}

class SubscribeToNostrRelays extends StoreEvent {}

class SendNostrEvent extends StoreEvent {}

class NewEventAdded extends StoreEvent {
  final NostrEvent event;

  NewEventAdded({required this.event});

  @override
  List<Object> get props => [event.id];
}

class ReactToEvent extends StoreEvent {
  final NostrEvent event;

  ReactToEvent(this.event);

  @override
  List<Object> get props => [this.event.id];
}

class DeleteEvent extends StoreEvent {
  final NostrEvent event;

  DeleteEvent(this.event);

  @override
  List<Object> get props => [this.event.id];
}
