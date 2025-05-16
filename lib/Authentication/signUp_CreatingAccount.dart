import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:roomate_sync/services/wrapper.dart';


class signUpScreen extends StatefulWidget{
  @override
  State<signUpScreen> createState() => _signUpScreenState();
}

class _signUpScreenState extends State<signUpScreen> {
  final formKey = GlobalKey<FormState>();
  bool isobscure = true;
  var email = TextEditingController();
  var password = TextEditingController();

  signUp() async{
    if(formKey.currentState!.validate())
    {
      try{
        showDialog(context: context, builder: (context){
          return Center(child: CircularProgressIndicator());
        });
        await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email.text, password: password.text);
        Navigator.of(context).pop();
        Get.offAll(Wrapper());
      } on FirebaseAuthException catch(e){
        Navigator.of(context).pop();

        String errormessage = "";
        if(e.message == 'The email address is badly formatted.')
          errormessage =  'Please enter a valid email address.';
        else if(e.message == 'The email address is already in use by another account.')
          errormessage = 'This email has already been taken, or you have already signed up via Google.';
        else
          errormessage = 'An error occurred. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errormessage,style: TextStyle(color: Colors.white),),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 85.0),
          child: Text('Sign Up',style: TextStyle(fontSize: 25,color: Colors.white,fontFamily: 'Italicfont',fontWeight: FontWeight.bold),),
        ),
        backgroundColor: Color(0xFF0B0B45),
        iconTheme: IconThemeData(
            color: Colors.white
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width:  MediaQuery.of(context).size.width,
          color: Color(0XffD9D9D9),
          child: Padding(
            padding: const EdgeInsets.only(top:20.0,left: 30.0,right: 30.0,bottom: 30.0),
            child: Container(
              width: MediaQuery.of(context).size.height,
              height: MediaQuery.of(context).size.width,
              color: Color(0XffD9D9D9),
              child: Padding(
                padding: const EdgeInsets.only(top:80.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 80),
                      child: Column(
                          children:[
                            Padding(
                              padding: const EdgeInsets.only(left: 17.0),
                              child: Image.asset('assets/images/LoginScreen_infinity.png',),
                            ),
                            Text('RoomateSync',style: TextStyle(fontFamily: 'Italicfont',fontSize: 30,color: Color(0Xfff353535),fontWeight: FontWeight.bold),),
                          ]
                      ),
                    ),

                    Column                                                                                                                                                                                                                                                                (
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Register & Join your roomates!!',style: TextStyle(color: Colors.black45,fontSize: 15,fontFamily: 'Italicfont',fontWeight: FontWeight.bold),),
                        ),
                        Form(
                          key: formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: email,
                                cursorColor: Color(0Xff14123D),
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.email_outlined,),
                                  hintText: 'Email',
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 18,
                                    fontFamily: 'Italicfont',
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Color(0Xff353535),
                                      )
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Color(0Xff14123D),
                                        width: 1,
                                      )
                                  ),
                                ),
                                validator: (value){
                                  if(value!.isEmpty)
                                  {
                                    return "Enter Email";
                                  }
                                  else
                                    return null;
                                },
                              ), //email
                              Padding(
                                padding: const EdgeInsets.only(top:20.0),
                                child: TextFormField(
                                  controller: password,
                                  cursorColor: Color(0Xff14123D),
                                  obscureText: isobscure,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.lock_outline_rounded),
                                    suffixIcon: IconButton(
                                      icon: isobscure?FaIcon(FontAwesomeIcons.eyeSlash,color: Colors.grey,size: 18,):Icon(Icons.remove_red_eye_outlined,color: Colors.grey,),
                                      onPressed: (){
                                        isobscure = !isobscure;
                                        setState(() { });
                                      },
                                    ),
                                    hintText: 'Password',
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 18,
                                      fontFamily: 'Italicfont',
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: Color(0Xff353535),
                                        )
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: Color(0Xff14123D),
                                          width: 1,
                                        )
                                    ),
                                  ),
                                  validator: (value){
                                    if(value!.isEmpty)
                                    {
                                      return "Enter Password";
                                    }
                                    else
                                      return null;
                                  },
                                ),
                              ),
                            ],
                          ),)
                      ],
                    ), //email and password input
                    Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 30.0,bottom: 20.0),
                          width: 300,
                          height: 40,
                          child: ElevatedButton(onPressed: (){
                            signUp();
                          },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF0B0B45),
                              ),
                              child: Text('Sign up',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w300,color: Colors.white,fontFamily: 'Italicfont'),)),
                        ),//Login
                      ],
                    )//signUp button
                  ],
                ),
              ),

            ),
          ),
        ),
      ),
    );
  }
}