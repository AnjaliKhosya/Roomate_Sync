import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:roomate_sync/services/wrapper.dart';

class Varify extends StatefulWidget{
  @override
  State<Varify> createState() => _VarifyState();
}

class _VarifyState extends State<Varify> {
  bool isLoading = false;
  void initState() {
    super.initState();
    sendVerificationLink();
  }
  sendVerificationLink()async
  {
    final user =  FirebaseAuth.instance.currentUser!;
    if(user!=null && !user.emailVerified)
    {
      setState(() {
        isLoading = true;
      });

      try{
        await user.sendEmailVerification();
        showdialogbox();
      } catch(e){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error sending verification email : $e')));
      }
      finally{
        setState(() {
          isLoading = false;
        });
      }}
  }
  void showdialogbox()async{
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text('The verification link has been sent to your email. Please check your inbox and then refresh to confirm.',style: TextStyle(fontSize: 20,color: Colors.black,fontFamily: 'Italicfont',fontWeight: FontWeight.bold),),
        content: ElevatedButton(onPressed: ()=>reload(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0B0B45),
            ),
            child: Icon(Icons.refresh,color: Colors.white,)),
      );
    });
  }
  reload()async{
    await FirebaseAuth.instance.currentUser!.reload().then((value)=>{
      Get.offAll(Wrapper())
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: isLoading?
        Center(child: CircularProgressIndicator()):SizedBox.shrink(),
      ),
    );
  }

}
