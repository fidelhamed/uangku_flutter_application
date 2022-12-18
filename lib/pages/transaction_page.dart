import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uangku_application/models/database.dart';
import 'package:uangku_application/models/transaction_with_category.dart';

class TransactionPage extends StatefulWidget {
  final TransactionWithCategory? transactionWithCategory;
  const TransactionPage({super.key, required this.transactionWithCategory});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final AppDb database = AppDb();
  bool isExpense = true;
  late int type;
  List <String> list = ['Makan', 'Transportasi', 'Belanja'];
  late String dropDownValue = list.first;
  TextEditingController amountController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  Category? selectedCategory;

  Future<List<Category>> getAllCategory(int type) async {
    return await database.getAllCategoryGet(type);
  }

  Future insert(int amount, DateTime date, String nameDetail, int categoryId) async {
    DateTime now = DateTime.now();
    final row = await database.into(database.transactions).insertReturning(TransactionsCompanion.insert(
      name: nameDetail, category_id: categoryId, transaction_date: date, amount: amount, createdAt: now, updatedAt: now));
    print(row.toString());
  }

  Future update(int transactionId, int ammount, int categoryId, DateTime transactionDate, String name) async {
    return await database.updateTransactionUpdate(
      transactionId, ammount, categoryId, transactionDate, name
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    if (widget.transactionWithCategory !=null) {
      updateTransactionView(widget.transactionWithCategory!);
    } else {
      type = 2;
    }
    super.initState();
  }

  void updateTransactionView(TransactionWithCategory transactionWithCategory) {
    amountController.text = transactionWithCategory.transaction.amount.toString();
    nameController.text = transactionWithCategory.transaction.name;
    dateController.text = DateFormat("yyyy-MM-dd").format(transactionWithCategory.transaction.transaction_date);
    type = transactionWithCategory.category.type;
    (type == 2) ? isExpense = true : isExpense = false;
    selectedCategory = transactionWithCategory.category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Tambah Transaksi",
          style: GoogleFonts.montserrat(),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Switch(
                    value: isExpense, 
                    onChanged: (bool value) {
                      setState(() {
                        isExpense = value;
                        type = (isExpense) ? 2 : 1;
                        selectedCategory = null;
                      });
                    }, 
                    inactiveTrackColor: Colors.green[200], 
                    inactiveThumbColor: Colors.green,
                    activeColor: Colors.red,
                  ),
                  Text((isExpense) ? 
                    "Pengeluaran" : "Pemasukan",
                    style: GoogleFonts.montserrat(
                      fontSize: 14
                    ), 
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(), 
                    labelText: "Nominal"
                  ),  
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Kategori",
                  style: GoogleFonts.montserrat(fontSize: 16),
                ),
              ),
              FutureBuilder<List<Category>>(
                future: getAllCategory(type),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    if (snapshot.hasData) {
                      if (snapshot.data!.length > 0) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: DropdownButton<Category>(
                            value: (selectedCategory == null) ? snapshot.data!.first : selectedCategory,
                            isExpanded: true,
                            icon: Icon(Icons.arrow_downward),
                            items: snapshot.data!.map((Category item) {
                              return DropdownMenuItem<Category>(
                                value: item,
                                child: Text(item.name),
                              );
                            }).toList(), 
                            onChanged: (Category? value) {
                              setState(() {
                                selectedCategory = value;                                
                              });
                            }),
                        );
                      } else {
                        return Center(
                          child: Text("Tidak ada data"),
                        );
                      }
                    } else {
                      return Center(
                        child: Text("Tidak ada data"),
                      );
                    }
                  }
                }),
              SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  readOnly: true,
                  controller: dateController,
                  decoration: InputDecoration(labelText: "Masukkan Tanggal"),
                  onTap: () async{
                    DateTime? pickedDate = await showDatePicker(
                      context: context, 
                      initialDate: DateTime.now(), 
                      firstDate: DateTime(2020), 
                      lastDate: DateTime(2099));

                      if (pickedDate != null) {
                        String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                      
                        dateController.text = formattedDate;
                      }
                  },
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: nameController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(), 
                    labelText: "Deskriipsi"
                  ),  
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    (widget.transactionWithCategory == null) ?
                    insert(
                      int.parse(amountController.text), 
                      DateTime.parse(dateController.text), 
                      nameController.text, 
                      selectedCategory!.id
                    ) 
                    : await
                    update(
                      widget.transactionWithCategory!.transaction.id, 
                      int.parse(amountController.text), 
                      selectedCategory!.id, 
                      DateTime.parse(dateController.text), 
                      nameController.text
                    );
                    Navigator.pop(context, true);
                  },
                  child: Text(
                    "Simpan",
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                  )
                ),
              )
            ],
          )
        ),
      ),
    );
  }
}