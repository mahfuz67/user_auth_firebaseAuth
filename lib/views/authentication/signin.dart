import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signup_signin/extension/context.extension.dart';
import 'package:signup_signin/model/user.model.dart';
import 'package:signup_signin/provider/providers.dart';
import 'package:signup_signin/services/auth_services/auth_services.dart';
import 'package:signup_signin/services/firestore/firestore.dart';
import 'package:signup_signin/views/authentication/signup.dart';
import 'package:signup_signin/views/home/home.dart';

class SignInView extends StatefulWidget {
  const SignInView({Key? key}) : super(key: key);

  @override
  _SignInViewState createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  AuthServices authServices = AuthServices();
  FireStoreServices fireStoreServices = FireStoreServices();
  FocusNode nodeE = FocusNode();
  FocusNode nodeP = FocusNode();

  String? emailError;
  bool isVisible = false;
  bool submitted = false;
  bool emailIsValid = false;
  bool animateOpacity = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nodeE.dispose();
    nodeP.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: 300,
                      height: 45,
                      child: Text('Login!',
                          style: GoogleFonts.mcLaren(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18))),
                  const SizedBox(
                    height: 5,
                  ),
                  field(
                    emailController,
                    'email',
                    const Icon(
                      Icons.mail,
                      color: Colors.black45,
                    ),
                    nodeE,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  field(
                    passwordController,
                    'password',
                    const Icon(
                      Icons.lock,
                      color: Colors.black45,
                    ),
                    nodeP,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        animateOpacity = true;
                      });
                      nodeP.unfocus();
                      nodeE.unfocus();
                      if (emailController.text.isEmpty ||
                          passwordController.text.isEmpty) {
                        SnackBar snackBar = SnackBar(
                          content: Text(
                            'please input all fields',
                            style: GoogleFonts.mcLaren(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          backgroundColor: Colors.brown,
                          padding: const EdgeInsets.all(12),
                          elevation: 0,
                          duration: const Duration(seconds: 1),
                        );
                        Future.delayed(const Duration(milliseconds: 500), () {
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        });
                      } else {
                        setState(() => submitted = true);
                        if (_formKey.currentState!.validate()) {
                          //_formKey.currentState!.save();
                          UserA userA = UserA(
                            email: emailController.text,
                            password: passwordController.text,
                          );
                          User? user = await authServices.loginWithEmailAndPassword(userA);
                          if (user != null) {
                            print('login successful');
                            Future.delayed(const Duration(seconds: 2), () {
                              Navigator.push(context,MaterialPageRoute (
                                builder: (BuildContext context) => const HomeView(),
                              ));
                            });

                          } else {
                            SnackBar snackBar = SnackBar(
                              content: Text(
                                authServices.errorText!,
                                style: GoogleFonts.mcLaren(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                              backgroundColor: Colors.brown,
                              padding: const EdgeInsets.all(12),
                              elevation: 0,
                              duration: const Duration(seconds: 1),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          }
                        }
                      }
                    },
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: animateOpacity ? 0.2 : 1.0,
                      curve: Curves.bounceInOut,
                      onEnd: () {
                        setState(() {
                          animateOpacity = false;
                        });
                      },
                      child: Container(
                        width: 315,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.brown,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        alignment: Alignment.center,
                        child: authServices.isLoading? const CircularProgressIndicator(color: Colors.white,) :   Text('Login', style: GoogleFonts.mcLaren(color: Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // GestureDetector(
                  //   onTap: () {},
                  //   child: Container(
                  //     width: 315,
                  //     height: 45,
                  //     decoration: BoxDecoration(
                  //       border: Border.all(
                  //         color: Colors.brown,
                  //         width: 1.5,
                  //       ),
                  //       borderRadius: BorderRadius.circular(10.0),
                  //     ),
                  //     alignment: Alignment.center,
                  //     child: Text('Sign Up With Google', style: GoogleFonts.mcLaren(color: Colors.brown)),
                  //   ),
                  // ),

                  SizedBox(
                    width: 315,
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                            onTap: (){
                            },
                            child: Text('Forgot password?', style: GoogleFonts.mcLaren(color: Colors.blue, fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 315,
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Don\'t have an account?', style: GoogleFonts.mcLaren(color: Colors.black)),
                        const SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute (
                                builder: (BuildContext context) => const SignUpView(),
                              ));
                            },
                            child: Text('Sign in', style: GoogleFonts.mcLaren(color: Colors.blue, fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget field(TextEditingController controller, String text, Icon icon, FocusNode node) {
    return SizedBox(
      width: 315,
      child: TextFormField(
        controller: controller,
        focusNode: node,
        obscureText: controller == passwordController
            ? isVisible
            ? false
            : true
            : false,
        autofocus: false,
        cursorColor: Colors.black,
        cursorWidth: 1,
        cursorHeight: 22,
        autovalidateMode: submitted ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
        textInputAction: controller == passwordController ? TextInputAction.done : TextInputAction.next,
        style: GoogleFonts.mcLaren(color: Colors.black),
        decoration: InputDecoration(
          prefixIcon: icon,
          suffixIcon: controller == passwordController
              ? GestureDetector(
              onTap: () {
                setState(() {
                  isVisible = !isVisible;
                });
              },
              child: isVisible
                  ? const Icon(
                Icons.visibility_outlined,
                color: Colors.black45,
              )
                  : const Icon(
                Icons.visibility_off_outlined,
                color: Colors.black45,
              ))
              : null,
          isCollapsed: true,
          contentPadding: const EdgeInsets.only(top: 13),
          filled: true,
          fillColor: Colors.brown.withOpacity(0.3),
          hintText: text,
          hintStyle: GoogleFonts.mcLaren(color: Colors.black45),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                width: 1.5,
                color: Colors.brown,
              ),
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                width: 1,
                color: Colors.white,
              ),
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                width: 1,
                color: Colors.red,
              ),
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          focusedErrorBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                width: 1,
                color: Colors.red,
              ),
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          errorMaxLines: 1,
          errorText: controller == emailController ? emailError : null,
        ),
      ),
    );
  }
}
