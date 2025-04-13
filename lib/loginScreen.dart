import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:roomate_sync/RoomCodeScreen.dart';
import 'package:roomate_sync/signUp_CreatingAccount.dart';
import 'package:roomate_sync/wrapper.dart';
import 'forgetPassword.dart';

class loginScreen extends StatefulWidget
{
  @override
  State<StatefulWidget> createState() => _loginScreenState();
}

class _loginScreenState extends State<loginScreen>
{
  final formKey = GlobalKey<FormState>();
  bool isobscure = true;
  var email = TextEditingController();
  var password = TextEditingController();

  signIn()async{
    if(formKey.currentState!.validate()) // validating the form first
        {
      try
      {
        showDialog(context: context, builder: (context){
          return Center(child: CircularProgressIndicator());
        });
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.text, password: password.text);
        Navigator.of(context).pop();
        Get.offAll(()=>Wrapper());

      } on FirebaseAuthException catch(e){
        String errorMessage = "";
        print('Error message is : ${e.code}');
        Navigator.of(context).pop();
        if(e.code == 'The email address is badly formatted.')
          errorMessage =  'Please enter a valid email address.';
        else if(e.code == 'The supplied auth credential is incorrect, malformed or has expired.')
          errorMessage = 'The email address has not been signed up yet, or it has already been signed up with Google login.';
        else if(e.code == 'invalid-credential')
          errorMessage = 'The email or password you entered is incorrect. Please try again.';
        else
          errorMessage = 'An error occured. Please try again';

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage,style: TextStyle(color: Colors.white),),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ));
      }
    }
  }
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // Sign-in aborted

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.of(context).pop(); // Close progress dialog
      Get.offAll(() => Wrapper());
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google sign-in failed: ${e.message}', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:true,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width:  MediaQuery.of(context).size.width,
          color: Color(0XffD9D9D9),
          child: Padding(
            padding: const EdgeInsets.only(top:20.0,left: 30.0,right: 30.0,bottom: 30.0),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(top:80.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 60),
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
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Text('Welcome back, you have been missed!',style: TextStyle(color: Colors.black87,fontSize: 15,fontFamily: 'Italicfont',fontWeight: FontWeight.w600),),
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
                                  padding: const EdgeInsets.only(top: 15.0),
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
                                ),// password
                                Padding(
                                  padding: const EdgeInsets.only(top: 5.0,bottom: 5,left: 210),
                                  child: InkWell(
                                      onTap: ()=>Get.to(forgetPassword()),
                                      child: Text('Forget Password?',style: TextStyle(fontSize: 13,color: Colors.blueAccent,fontFamily: 'Italicfont',fontWeight: FontWeight.bold))),
                                ),
                              ],
                            ),)
                        ],
                      ), //email and password input
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 30.0,bottom: 20.0),
                              width: 300,
                              height: 40,
                              child: ElevatedButton(onPressed: (){
                                signIn();
                              },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF0B0B45),
                                  ),
                                  child: Text('Sign in',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w300,color: Colors.white,fontFamily: 'Italicfont'),)),
                            ),//Login
                            Row(
                              children:[
                                Expanded(
                                  child: Divider(
                                    thickness: 1, // Thickness of the line
                                    color: Colors.grey, // Line color
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    "Or continue with",
                                    style: TextStyle(fontSize: 18, color: Colors.grey,fontFamily: 'Italicfont'),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    thickness: 1,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ), // divider Login With
                            Container(
                              margin: EdgeInsets.only(top: 20.0),
                              width: 300,
                              height: 40,
                              child: ElevatedButton(onPressed: () => signInWithGoogle(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF0B0B45),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FaIcon(FontAwesomeIcons.google,color: Colors.white,size: 17,),
                                    Padding(
                                      padding: const EdgeInsets.only(left:8.0),
                                      child: Text('Google',style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.w300,fontFamily: 'Italicfont'),),
                                    )
                                  ],
                                ),
                              ),
                            ), //sign in with google
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Not a member?',style: TextStyle(fontSize: 15,color: Colors.black87,fontFamily: 'Italicfont',fontWeight: FontWeight.bold),),
                                TextButton(onPressed: (){
                                  Get.to(signUpScreen());
                                }, child: Text('Register now',style: TextStyle(fontSize: 15,color: Colors.blueAccent,fontFamily: 'Italicfont',fontWeight: FontWeight.bold),))
                              ],
                            ),// Reister now
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}
