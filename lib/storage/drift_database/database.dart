// import 'package:drift/drift.dart';

// part 'database.g.dart';

// @DataClassName("WalletsTable")
// class WalletsTable extends Table {
//   IntColumn get id => integer().autoIncrement()();
//   TextColumn get title => text().nullable()();
//   TextColumn get passphrase => text().nullable()();
//   TextColumn get mnemonic => text().nullable()();
//   TextColumn get seed => text().nullable()();
//   TextColumn get mainAddress => text()();
//   IntColumn get addresses => integer().references(AddressesTable, #id)();
// }

// @DataClassName("AddressesTable")
// class AddressesTable extends Table {
//   IntColumn get id => integer().autoIncrement()();
//   TextColumn get address => text().unique().nullable()();
//   TextColumn get address_title => text().nullable()();
//   TextColumn get address_color => text().nullable()();
//   TextColumn get publicKey => text().nullable()();
//   TextColumn get privateKey => text().nullable()();
//   IntColumn get index => integer().nullable()();
//   IntColumn get group => integer().nullable()();
//   BlobColumn get balances => blob()();
//   IntColumn get transactions => integer().references(TransactionsTable, #id)();
// }

// @DataClassName("TransactionsTable")
// class TransactionsTable extends Table {
//   IntColumn get id => integer().autoIncrement()();
//   TextColumn get txHash => text().nullable()();
//   TextColumn get blockHash => text().nullable()();
//   IntColumn get timeStamp => integer()();
//   IntColumn get amount => integer()();
//   IntColumn get gas => integer()();
//   TextColumn get status => text()();
//   TextColumn get txId => text()();
//   BlobColumn get refIn => blob()();
//   BlobColumn get refOut => blob()();
// }

// @DriftDatabase(
//   tables: [
//     WalletsTable,
//     AddressesTable,
//     TransactionsTable,
//   ],
// )
// class Database extends _$Database {
//   Database(QueryExecutor e) : super(e);
// }
