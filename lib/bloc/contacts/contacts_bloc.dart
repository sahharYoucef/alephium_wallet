import 'package:alephium_wallet/api/utils/error_handler.dart';
import 'package:alephium_wallet/storage/base_db_helper.dart';
import 'package:alephium_wallet/storage/models/contact_store.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'contacts_event.dart';
part 'contacts_state.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  final BaseDBHelper dbHelper;

  List<ContactStore> contacts = [];
  ContactsBloc({
    required this.dbHelper,
  }) : super(ContactsLoadingState()) {
    on<ContactsEvent>((event, emit) async {
      try {
        if (event is LoadAllContactsEvent) {
          var data = await dbHelper.getContacts();
          contacts = data;
          emit(ContactsCompletedState(contacts: contacts));
        } else if (event is UpdateContactEvent) {
          await dbHelper.updateContact(event.id, event.contact);

          add(LoadAllContactsEvent());
        } else if (event is AddNewContactEvent) {
          await dbHelper.insertContact(event.contact);
          add(LoadAllContactsEvent());
        } else if (event is DeleteContactEvent) {
          await dbHelper.deleteContact(event.id);
          add(LoadAllContactsEvent());
        }
      } catch (e, trace) {
        emit(ContactsErrorState(
            message: ApiError(exception: e, trace: trace).message));
      }
    });
  }
}
