import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
final _firebase = FirebaseAuth.instance; //حطيتها فوق عشان اقدر استخدمها بكل الكلاسات
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  var _enteredemail='';
  var _enteredusername='';
  var _enteredpassword='';
  var isLogin = true; // Toggle between login and signup modes


  void _submit() async {
  final isValid = _form.currentState!.validate();
  if (!isValid) {
    return;
  }
  _form.currentState!.save();

  try {
    if (isLogin) {
      // Log users in
      final userCredentials  = await _firebase.signInWithEmailAndPassword(
        email: _enteredemail,
        password: _enteredpassword,
      ); // Add semicolon here
    } else {
      // Sign up new users
      final userCredentials = await _firebase.createUserWithEmailAndPassword(
        email: _enteredemail,
        password: _enteredpassword,
      );
      await FirebaseFirestore.instance.collection('users').doc(userCredentials.user!.uid).set({
        'username': _enteredusername,
        'email' : _enteredemail
      });
    }
  } on FirebaseAuthException catch (error) {
    if (error.code == 'email-already-in-use') {
      // Handle case where email is already in use
    }
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error.message ?? 'Authentication failed.'),
    ));
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo and header
                Image.asset('assets/jdny.png'),
               const SizedBox(height: 20),
                Text(
                  isLogin ? 'Welcome Back' : 'Create an Account',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  isLogin ? 'Sign in to continue' : 'Join us for more features',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 30),
                 Card(
                  margin: EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding:EdgeInsets.all(16),
                      child: Form(
                        key: _form,
                        child:Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              decoration: InputDecoration(
                                 labelText: 'Email',
                                 prefixIcon: Icon(Icons.email),
                                 border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  ),
                                 ),
                                 keyboardType: TextInputType.emailAddress,
                                 autocorrect: false,
                                 textCapitalization: TextCapitalization.none,
                                 validator: (value) {
                                   if(value ==null || value.trim().isEmpty || !value.contains('@') ) {
                                    return 'please enter a valid email address.';
                                   }
                                   return null;
                                 },
                                 onSaved: (Value) {
                                   _enteredemail=Value!;
                                 },
                            ),
                            SizedBox(height: 20,),
                            if(!isLogin)
                             TextFormField(
                              decoration: InputDecoration(
                                 labelText: 'username',
                                 prefixIcon: Icon(Icons.person),
                                 border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  ),
                                 ),
                                 keyboardType: TextInputType.name,
                                 autocorrect: false,
                                 textCapitalization: TextCapitalization.none,
                                 validator: (value) {
                                   if(value ==null || value.trim().isEmpty || value.trim().length<4 ) {
                                    return 'username must be at least 4 characters long.';
                                   }
                                   return null;
                                 },
                                 onSaved: (Value) {
                                   _enteredusername=Value!;
                                 },
                            ),
                            SizedBox(height: 20,),
                            TextFormField(
                              decoration: InputDecoration(
                                 labelText: 'Password',
                                 prefixIcon: Icon(Icons.lock),
                                 border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  ),
                                 ),
                                 obscureText: true,
                                 validator: (value) {
                                   if(value ==null || value.trim().isEmpty || value.trim().length<6 ) {
                                    return 'password must be at least 6 characters long.';
                                   }
                                   return null;
                                 },
                                 onSaved: (Value) {
                                   _enteredpassword=Value!;
                                 },
                            ),
                            const SizedBox(height: 12,),
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                               child:  Text(isLogin ? 'Login':'Signup',style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),),),
                              TextButton(onPressed: (){
                                setState(() {
                                 isLogin =!isLogin; //كذا يروح للساين اب اذا ضغط عليه
                                });
                              },
                               child: Text(isLogin?'Create an account':'I already have an account' , style: TextStyle(color: const Color.fromARGB(180, 0, 0, 0),))),
                          ],
                        ),
                         ),
                          ),
                  ),
                ),
 ],
            ),
          ),
        ),
      ),
    );
  }
} 