part of 'store_bloc.dart';

abstract class StoreState extends Equatable {
  const StoreState();

  @override
  List<Object> get props => [];
}

class StoreInitial extends StoreState {}

class NewEvent extends StoreState {
  final List<NostrEvent> events;

  NewEvent(this.events);

  @override
  List<Object> get props => [this.events];
}
