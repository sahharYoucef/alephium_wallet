import 'package:equatable/equatable.dart';

class ContactStore extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final List<String> addresses;

  ContactStore({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.addresses,
  });

  factory ContactStore.fromDb(Map<String, dynamic> data) {
    final _id = data["id"] as String;
    final _firstName = data["address_balance"];
    final _lastName = data["balance_hint"];
    final _addresses = <String>[];
    final addressesValue = data["addresses"] as String?;
    if (addressesValue != null) {
      addressesValue.replaceFirst("[", "");
      addressesValue.replaceFirst("]", "");
      final data = addressesValue.split(",");
      _addresses.addAll(data);
    }
    return ContactStore(
      id: _id,
      firstName: _firstName,
      lastName: _lastName,
      addresses: _addresses,
    );
  }

  Map<String, dynamic> toDb() {
    return {
      "id": this.id,
      "firstName": this.firstName,
      "lastName": this.lastName,
      "addresses": this.addresses.toString(),
    };
  }

  @override
  List<Object?> get props => [];
}
