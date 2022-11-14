part of 'contacts_bloc.dart';

abstract class ContactsEvent extends Equatable {
  const ContactsEvent();

  @override
  List<Object> get props => [];
}

class LoadAllContactsEvent extends ContactsEvent {}

class AddNewContactEvent extends ContactsEvent {
  final ContactStore contact;

  AddNewContactEvent({required this.contact});

  @override
  List<Object> get props => [this.contact];
}

class DeleteContactEvent extends ContactsEvent {
  final String id;

  DeleteContactEvent({required this.id});

  @override
  List<Object> get props => [this.id];
}
