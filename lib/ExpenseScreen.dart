import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:roomate_sync/NewExpenseScreen.dart';
import 'package:intl/intl.dart';
import 'DetailExpensePage.dart';

class ExpenseScreen extends StatefulWidget{
  final String roomCode;
  ExpenseScreen({required this.roomCode});
  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {

  @override
  deleteExpense(String expenseId)async{
    try{
      final firestore = FirebaseFirestore.instance;

      await firestore
          .collection('rooms')
          .doc(widget.roomCode)
          .collection('expenses')
          .doc(expenseId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Expense deleted successfully!',style: TextStyle(color: Colors.white),
          ),
            backgroundColor:Colors.green,)
      );
    }catch(e)
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Faild to delete expense: $e')),
      );
    }
  }

  Widget build(BuildContext context) {
    String roomcode = widget.roomCode;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20.0,right: 20,top: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(onPressed: (){
                        ScaffoldMessenger.of(context).clearSnackBars();
                        Navigator.of(context).pop();
                      }, icon: FaIcon(FontAwesomeIcons.bars,color: Colors.black87,)),
                      Padding(
                          padding: const EdgeInsets.only(left: 100.0),
                          child: Image.asset('assets/images/Screenshot_2024-11-07_163515-removebg-preview.png',height: 100,width: 200,)
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Text('Expenses',style: TextStyle(fontSize: 60,fontFamily: 'Italicfont',fontWeight: FontWeight.bold,color: Colors.black87),),
                ),
              ],
            ),
          ),
          Positioned(
            top: 230,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Color(0xFF0B0B45),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30),topRight: Radius.circular(30))
              ),
              child:StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('rooms').doc(roomcode).collection('expenses').snapshots(),
                  builder: (context,snapshot){
                    if(snapshot.connectionState == ConnectionState.waiting)
                      return Center(child: CircularProgressIndicator());
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          'No Expenses',
                          style: TextStyle(
                            fontFamily: 'Italicfont',
                            fontWeight: FontWeight.w200,
                            fontSize: 30,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }
                    final expenses = snapshot.data!.docs;
                    return  ListView.builder(
                        itemCount: expenses.length,
                        itemBuilder: (context,index){
                          final expense = expenses[index];
                          return Padding(
                            padding: const EdgeInsets.only(left: 20.0,right: 20,bottom: 20),
                            child: Container(
                                height: 120,
                                width: 300,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(width: 1, color: Colors.black87),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: ListTile(
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              expense['expenseTitle'],
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Italicfont',
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(Icons.calendar_month_outlined, size: 20),
                                                SizedBox(width: 4),
                                                Text(
                                                  expense['date'],
                                                  style: TextStyle(
                                                    fontFamily: 'Italicfont',
                                                    fontWeight: FontWeight.w200,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            TextButton(
                                              onPressed: () {
                                                // Navigate to your DetailExpensePage
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => DetailExpensePage(roomCode: roomcode,expenseId: expense.id,),
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                "View More",
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Italicfont'
                                                ),
                                              ),

                                            )
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              FaIcon(FontAwesomeIcons.indianRupee, size: 18),
                                              SizedBox(width: 4),
                                              Text(
                                                expense['amount'].toString(),
                                                style: TextStyle(
                                                  fontFamily: 'Italicfont',
                                                  fontWeight: FontWeight.w200,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ],
                                          ),
                                          IconButton(
                                              onPressed: () {
                                                deleteExpense(expense.id);
                                              },
                                              icon: Icon(Icons.delete_rounded),
                                              iconSize: 20,
                                            ),

                                        ],
                                      ),
                                    ],
                                  ),
                                )

                            ),
                          );
                        });
                  }),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          ScaffoldMessenger.of(context).clearSnackBars();
          Navigator.push(context, MaterialPageRoute(builder: (context)=>NewExpenseScreen(roomCode: roomcode,)));
        },
        child: Icon(Icons.add,color: Color(0xFF0B0B45),size: 40,),
        backgroundColor: Colors.white,
      ),
    );
  }
}