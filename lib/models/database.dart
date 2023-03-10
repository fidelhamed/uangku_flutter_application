import 'dart:io';

import 'package:drift/drift.dart';
// These imports are used to open the database
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uangku_application/models/category.dart';
import 'package:uangku_application/models/transaction.dart';
import 'package:uangku_application/models/transaction_with_category.dart';

part 'database.g.dart';

@DriftDatabase(
  // relative import for the drift file. Drift also supports `package:`
  // imports
  tables: [Categories, Transactions],
)
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<List<Category>> getAllCategoryGet(int type) async {
    return await (select(categories)..where((tbl) => tbl.type.equals(type))).get();
  }

  Future updateCategoryUpdate(int id, String name) async{
    return (update(categories)..where((tbl) => tbl.id.equals(id))).write(CategoriesCompanion(name: Value(name)));
  }

  Future deleteCategoryDelete(int id) async {
    return (delete(categories)..where((tbl) => tbl.id.equals(id))).go();
  }

  // transaksi 

  Stream<List<TransactionWithCategory>> getTransactionByDateGet(DateTime date) {
    final query = (
      select(transactions)
      .join([innerJoin(categories, categories.id.equalsExp(transactions.category_id))])
      ..where(transactions.transaction_date.equals(date)));

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithCategory(row.readTable(transactions), row.readTable(categories));
      }).toList();
    });
  }

  Future updateTransactionUpdate(int id, int ammount, int categoryId, DateTime transactionDate, String name) async{
    return (update(transactions)..where((tbl) => tbl.id.equals(id))).write(TransactionsCompanion(
      amount: Value(ammount),
      category_id: Value(categoryId),
      transaction_date: Value(transactionDate),
      name: Value(name)));
  }

  Future deleteTransactionDelete(int id) async {
    return (delete(transactions)..where((tbl) => tbl.id.equals(id))).go();
  }

}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));

    return NativeDatabase.createInBackground(file);
  });
}