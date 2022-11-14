import 'package:alephium_wallet/storage/models/contact_store.dart';
import 'package:alephium_wallet/storage/sqflite_database/sqflite_database.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'contacts_event.dart';
part 'contacts_state.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  final SQLiteDBHelper dbHelper;

  List<ContactStore> contacts = [];
  ContactsBloc({
    required this.dbHelper,
  }) : super(ContactsLoadingState()) {
    on<ContactsEvent>((event, emit) async {
      if (event is LoadAllContactsEvent) {
        var data = await dbHelper.getContacts();
        contacts = data;
        emit(ContactsCompletedState(contacts: contacts));
      } else if (event is AddNewContactEvent) {
        await dbHelper.insertContact(event.contact);
        add(LoadAllContactsEvent());
      } else if (event is DeleteContactEvent) {
        await dbHelper.deleteContact(event.id);
        add(LoadAllContactsEvent());
      }
    });
  }
}
