import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uangku_application/models/database.dart';
import 'package:uangku_application/models/transaction_with_category.dart';
import 'package:uangku_application/pages/transaction_page.dart';

class HomePage extends StatefulWidget {
  final DateTime selectedDate;
  const HomePage({super.key, required this.selectedDate});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppDb database = AppDb();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // dashboard total pemasukan dan pengeluaran
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          child: Icon(Icons.download, color: Colors.green,),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pemasukan",
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 12
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Rp. 3.550.000",
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 14
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          child: Icon(Icons.upload, color: Colors.red,),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pengeluaran",
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 12
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Rp. 82.000",
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 14
                              ),
                            )
                          ],
                        )
                      ],
                    )
                  ],
                ),
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(16)
                ),
              ),
            ),

            // teks transaksi
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Transaksi",
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            StreamBuilder<List<TransactionWithCategory>>(
              stream: database.getTransactionByDateGet(widget.selectedDate),  
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  if (snapshot.hasData) {
                    if (snapshot.data!.length > 0) {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Card (
                              elevation: 10,
                              child: ListTile(
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () async {
                                        await database.deleteTransactionDelete(
                                          snapshot.data![index].transaction.id
                                        );
                                          setState(() {});                                        
                                      },
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit), 
                                      onPressed: (){
                                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => TransactionPage(transactionWithCategory: snapshot.data![index],)));
                                      },
                                    )
                                  ],
                                ),
                                title: Text(
                                "Rp. " + snapshot.data![index].transaction.amount.toString(),
                                  style: GoogleFonts.montserrat(),
                                ),
                                subtitle: Text(
                                  snapshot.data![index].category.name + " (" + snapshot.data![index].transaction.name + ")",
                                  style: GoogleFonts.montserrat(),
                                ),
                                leading: Container(
                                  child: (snapshot.data![index].category.type == 2) ?
                                    Icon(Icons.upload, color: Colors.red,) : Icon(Icons.download, color: Colors.green,),
                                  decoration: BoxDecoration(
                                    color: Colors.white, borderRadius: BorderRadius.circular(8)
                                  ),
                                ),
                              ),
                            ),
                          );

                        });
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
              }
            ),
          ],
        )
      ),
    );
  }
}