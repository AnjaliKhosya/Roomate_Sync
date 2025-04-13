import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class forgetPassword extends StatefulWidget{
  @override
  State<forgetPassword> createState() => _forgetPasswordState();
}

class _forgetPasswordState extends State<forgetPassword> {
  final formKey = GlobalKey<FormState>();
  var email = TextEditingController();
  reset() async{
    if(formKey.currentState!.validate())
    {
      try{
        final user = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email.text);
        if(user.isEmpty)
        {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No user found for this email address.',style: TextStyle(color: Colors.red),),
                backgroundColor: Colors.white38,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ));
          return;
        }
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset link sent to your email!'),
            backgroundColor: Colors.green,
          ),
        );
      } on FirebaseAuthException catch(e){
        String errormessage = '';
        if(e.message=='The email address is badly formatted.')
          errormessage = 'Please enter a valid email address.';
        else
          errormessage = 'An error occurred, Please try again later.';
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errormessage,style: TextStyle(color: Colors.red),),
              backgroundColor: Colors.white38,
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
          padding: const EdgeInsets.only(left: 50.0),
          child: Text('Forget Password',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w300,color: Colors.white,fontFamily: 'Italicfont'),),
        ),
        iconTheme: IconThemeData(
            color: Colors.white
        ),
        backgroundColor: Color(0xFF0B0B45),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Color(0XffD9D9D9),
          child: Padding(
            padding: const EdgeInsets.only(top: 130.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 100.0),
                  child: Image.asset('assets/images/ForgeotPassword.jpg',height: 200,width: 200,),
                ),//image
                SizedBox(height: 50,),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text('Enter e-mail to recieve reset link',style: TextStyle(fontSize: 15,color: Colors.black87,fontFamily: 'Italicfont',fontWeight: FontWeight.bold),),
                ),//text
                Padding(
                  padding: const EdgeInsets.only(left: 23.0,right: 23,top: 10),
                  child: Form(
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
                              return "Enter your email";
                            }
                            else
                              return null;
                          },
                        ), //email
                      ],
                    ),),
                ),//email
                Padding(
                  padding: const EdgeInsets.only(left: 70.0),
                  child: Container(
                    margin: EdgeInsets.only(top: 30.0,bottom: 20.0),
                    width: 250,
                    height: 40,
                    child: ElevatedButton(onPressed: (){
                      reset();
                    },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0B0B45),
                        ),
                        child: Text('Send Link',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w300,color: Colors.white,fontFamily: 'Italicfont'),)),
                  ),
                ),//send link button
              ],
            ),
          ),
        ),
      ),
    );
  }
}