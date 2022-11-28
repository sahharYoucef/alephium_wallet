import 'package:equatable/equatable.dart';

class ContactStore extends Equatable {
  final int? id;
  final String firstName;
  final String? lastName;
  final String address;

  ContactStore({
    this.id,
    required this.firstName,
    required this.address,
    this.lastName,
  });

  factory ContactStore.fromDb(Map<String, dynamic> data) {
    final _id = data["id"] as int;
    final _firstName = data["firstName"] as String;
    final _lastName = data["lastName"] as String?;
    final _address = data["address"] as String;
    return ContactStore(
      id: _id,
      firstName: _firstName,
      lastName: _lastName,
      address: _address,
    );
  }

  Map<String, dynamic> toDb() {
    return {
      "firstName": this.firstName,
      "lastName": this.lastName,
      "address": this.address,
    };
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        address,
      ];
}
