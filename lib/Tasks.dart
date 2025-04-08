import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:roomate_sync/NewTaskScreen.dart';

class TaskScreen extends StatefulWidget
{
  final String roomCode;
  TaskScreen({required this.roomCode});
  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen>
{

  Map<String, String> userNames = {};
  @override
  void initState() {
    super.initState();
    deleteExpiredTasks(widget.roomCode);
    fetchAllUserNames();
  }

  deletetask(String TaskId)async{
    try{
      final firestore = FirebaseFirestore.instance;

      await firestore
          .collection('rooms')
          .doc(widget.roomCode)
          .collection('tasks')
          .doc(TaskId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task deleted successfully!',style: TextStyle(color: Colors.white),
          ),
            backgroundColor:Colors.green,)
      );
    }catch(e)
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Faild to delete Task: $e')),
      );
    }
  }
  DecrementNoOfTasks(String userId,String status)async{
    try{
      var userFieldRef = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomCode)
          .collection('Roomates')
          .doc(userId);
      await userFieldRef.update({
        'totalTasks': FieldValue.increment(-1),
      });
      if(status=='completed')
      {
        await userFieldRef.update({
          'taskCompleted': FieldValue.increment(-1),
        });
      }
    }catch (e) {
      print('Error updating task count: $e');
    }
  }
  Future<void> deleteExpiredTasks(String roomCode) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final now = DateTime.now();

      var expiredTasks = await firestore
          .collection('rooms')
          .doc(roomCode)
          .collection('tasks')
          .where('deadline', isLessThan: Timestamp.fromDate(now))
          .get();

      for (var task in expiredTasks.docs) {
        await firestore
            .collection('rooms')
            .doc(roomCode)
            .collection('tasks')
            .doc(task.id)
            .delete();
      }

    } catch (e) {
      print("Error deleting expired tasks: $e");
    }
  }
  Future<void> fetchAllUserNames() async {
    try {
      var userDocs = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomCode)
          .collection('Roomates')
          .get();

      setState(() {
        for (var doc in userDocs.docs) {
          userNames[doc.id] = doc.data()['name'];
        }
      });
    } catch (e) {
      print("Error fetching user names: $e");
    }
  }
  OnTaskCompleteChanged(bool isComplete,String userId,String taskId) async {

    if(isComplete==null)return;
    await FirebaseFirestore.instance.collection('rooms').doc(widget.roomCode).collection('tasks').doc(taskId).update({
      'status': isComplete ? 'completed' : 'pending',
    });
    if (isComplete) {
      await FirebaseFirestore.instance.collection('rooms').doc(widget.roomCode).collection('Roomates').doc(userId).update({
        'taskCompleted': FieldValue.increment(1), // Increment the 'user' count
      });
    }
    else
    {
      await FirebaseFirestore.instance.collection('rooms').doc(widget.roomCode).collection('Roomates').doc(userId).update({
        'taskCompleted': FieldValue.increment(-1), // Increment the 'user' count
      });
    }
  }


  @override
  Widget build(BuildContext context ) {
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
                  padding: const EdgeInsets.only(left: 20.0,right: 20,top: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(onPressed: (){
                        ScaffoldMessenger.of(context).clearSnackBars();
                        Navigator.of(context).pop();
                      }, icon: FaIcon(FontAwesomeIcons.bars,color: Color(0xFF0B0B45),)),
                      Padding(
                        padding: const EdgeInsets.only(left: 210.0,bottom: 0),
                        child: /*Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children:[Text('${time.day}',style: TextStyle(fontWeight: FontWeight.bold,fontFamily: 'Italicfont',fontSize: 50,color: Colors.white),),
                        Text('${DateFormat('MMM').format(DateTime.now())}',style: TextStyle(fontSize: 30,fontFamily: 'Italicfont',fontWeight: FontWeight.w300,color: Colors.white),),]),*/
                        Text('All',style: TextStyle(fontSize: 60,fontFamily: 'Italicfont',fontWeight: FontWeight.bold,color: Color(0xFF0B0B45)),),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Text('Tasks',style: TextStyle(fontSize: 60,fontFamily: 'Italicfont',fontWeight: FontWeight.bold,color: Color(0xFF0B0B45)),),
                ),
              ],
            ),
          ), //tasks header
          Positioned(
            top: 200,
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
                    stream: FirebaseFirestore.instance.collection('rooms').doc(roomcode).collection('tasks').snapshots(),
                    builder: (context,snapshot){
                      if(snapshot.connectionState == ConnectionState.waiting)
                        return Center(child: CircularProgressIndicator());
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty){
                        return Center(
                          child: Text(
                            'No Tasks',
                            style: TextStyle(
                              fontFamily: 'Italicfont',
                              fontWeight: FontWeight.w200,
                              fontSize: 30,
                              color: Colors.white,
                            ),
                          ),);
                      }
                      final tasks = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount:tasks.length,
                        itemBuilder: (context, i) {
                          final task = tasks[i];
                          return Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 25),
                            child:  Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(width: 1, color: Colors.black87),

                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: CheckboxListTile(
                                      value: task['status']=='completed',
                                      onChanged: (value) {
                                        OnTaskCompleteChanged(value!,task['assignedTo'],task.id);
                                      },
                                      title: Padding(
                                        padding: const EdgeInsets.only(bottom: 5.0),
                                        child: Text(
                                          task['title'],
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontFamily: 'Italicfont',
                                          ),
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 5.0),
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 3.0),
                                                  child: Icon(Icons.people, color: Colors.black),
                                                ),
                                                Text(userNames[task['assignedTo']]??'Not Found',style: TextStyle(fontSize: 13,color: Colors.black,fontFamily: 'Italicfont'),)
                                              ],
                                            ),
                                          ),//assigned To
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Icon(Icons.calendar_month_outlined, size: 20, color: Colors.black),
                                              SizedBox(width: 5),
                                              Text(
                                                task['deadline'],
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black,
                                                  fontFamily: 'Italicfont',
                                                ),
                                              ),
                                            ],
                                          ),//deadline
                                        ],
                                      ),
                                      checkColor: Colors.white,
                                      activeColor: Colors.green,
                                      side: BorderSide(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 1.0),
                                    child: IconButton(
                                      onPressed: () async{
                                        var TaskSnapshot = await FirebaseFirestore.instance.collection('rooms').doc(widget.roomCode).collection('tasks').doc(task.id).get();
                                        var taskData = TaskSnapshot.data();
                                        String status = taskData?['status'];
                                        DecrementNoOfTasks(task['assignedTo'],status);
                                        deletetask(task.id);
                                      },
                                      icon: Icon(Icons.delete_rounded, color: Colors.black, size: 20),
                                    ),
                                  ), // delete button
                                ],
                              ),
                            ),
                          );
                        },
                      );

                    }
                )
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>NewTaskScreen(roomCode: roomcode,)));
        },
        child: Icon(Icons.add,color: Color(0xFF0B0B45),size: 40,),
        backgroundColor: Colors.white,
      ),
    );
  }
}