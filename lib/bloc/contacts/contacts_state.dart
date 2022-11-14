part of 'contacts_bloc.dart';

abstract class ContactsState extends Equatable {
  const ContactsState();

  @override
  List<Object> get props => [];
}

class ContactsLoadingState extends ContactsState {}

class ContactsCompletedState extends ContactsState {
  final List<ContactStore> contacts;
  ContactsCompletedState({required this.contacts});
  @override
  List<Object> get props => [this.contacts];
}

class ContactsErrorState extends ContactsState {
  final String message;
  ContactsErrorState({required this.message});

  @override
  List<Object> get props => [this.message];
}
