import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signup_signin/controllers/text.controllers.dart';
import 'package:signup_signin/model/user.model.dart';
import 'package:signup_signin/services/auth_services/auth_services.dart';
import 'package:signup_signin/services/firestore/firestore.dart';
import 'package:signup_signin/views/authentication/signin.dart';
import 'package:signup_signin/views/authentication/signup.dart';
import 'package:signup_signin/views/home/home.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({Key? key}) : super(key: key);

  @override
  _SignUpViewState createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  AuthServices authServices = AuthServices();
  FireStoreServices fireStoreServices = FireStoreServices();
  FocusNode nodeN = FocusNode();
  FocusNode nodeU = FocusNode();
  FocusNode nodeE = FocusNode();
  FocusNode nodeP = FocusNode();

  String? emailError;
  bool isVisible = false;
  bool submitted = false;
  bool emailIsValid = false;
  bool animateOpacity = false;

  @override
  void dispose() {
    nodeN.dispose();
    nodeU.dispose();
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
                      child: Text('Create Account!',
                          style: GoogleFonts.mcLaren(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18))),
                  const SizedBox(
                    height: 5,
                  ),
                  field(
                      Controllers.nameController,
                      'name',
                      const Icon(
                        Icons.drive_file_rename_outline,
                        color: Colors.black45,
                      ),
                      nodeN),
                  const SizedBox(
                    height: 15,
                  ),
                  field(
                      Controllers.usernameController,
                      'username',
                      const Icon(
                        Icons.drive_file_rename_outline,
                        color: Colors.black45,
                      ),
                      nodeU),
                  const SizedBox(
                    height: 15,
                  ),
                  field(
                    Controllers.emailController,
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
                    Controllers.passwordController,
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
                      nodeU.unfocus();
                      nodeE.unfocus();
                      nodeN.unfocus();
                      if (Controllers.nameController.text.isEmpty ||
                          Controllers.usernameController.text.isEmpty ||
                          Controllers.emailController.text.isEmpty ||
                          Controllers.passwordController.text.isEmpty) {
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
                            name: Controllers.nameController.text,
                            username: Controllers.usernameController.text,
                            email: Controllers.emailController.text,
                            password: Controllers.passwordController.text,
                          );
                          User? user = await authServices.signupWithEmailAndPassword(userA);
                          if (user != null) {
                            print('signup successful');
                            fireStoreServices.insertUser(userA);
                              Navigator.push(context,MaterialPageRoute (
                                builder: (BuildContext context) => const HomeView(),
                              ));
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
                        child: authServices.isLoading? const CircularProgressIndicator(color: Colors.white,) :  Text('CREATE ACCOUNT', style: GoogleFonts.mcLaren(color: Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 315,
                      height: 45,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.brown,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      alignment: Alignment.center,
                      child: Text('Sign Up With Google', style: GoogleFonts.mcLaren(color: Colors.brown)),
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  SizedBox(
                    width: 315,
                    height: 45,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Already have an account?', style: GoogleFonts.mcLaren(color: Colors.black)),
                        const SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute (
                                builder: (BuildContext context) => const SignInView(),
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
        keyboardType: controller == Controllers.passwordController
            ? TextInputType.none
            : TextInputType.multiline,
        maxLines: controller == Controllers.passwordController
            ? 1
            : null,
        controller: controller,
        focusNode: node,
        obscureText: controller == Controllers.passwordController
            ? isVisible
                ? false
                : true
            : false,
        autofocus: false,
        cursorColor: Colors.black,
        cursorWidth: 1,
        cursorHeight: 22,
        autovalidateMode: submitted ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
        onChanged: (value) async {
          if (controller == Controllers.emailController) {
            bool emailExists = await fireStoreServices.checkIfEmailExist(value);
            if (emailExists) {
              if (mounted) {
                setState(() {
                  emailError = 'email already in use';
                });
              }
            } else {
              if (mounted) {
                setState(() {
                  emailError = null;
                });
              }
            }
          }
        },
        validator: (text) {
          if (controller == Controllers.nameController) {
            return null;
          } else if (controller == Controllers.usernameController) {
            return null;
          } else if (controller == Controllers.emailController) {
            if (Controllers.emailController.text.isNotEmpty) {
              bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                  .hasMatch(Controllers.emailController.text);
              if (!emailValid) {
                return 'invalid email format';
              } else {
                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  setState(() {
                    emailIsValid = true;
                  });
                });
                return null;
              }
            }
            return null;
          } else if (controller == Controllers.passwordController) {
            if (Controllers.passwordController.text.isNotEmpty) {
              if (Controllers.passwordController.text.length < 8) {
                return 'password must be at least 6 characters';
              } else {
                return null;
              }
            }
            return null;
          }
        },
        //textInputAction: controller == Controllers.passwordController ? TextInputAction.done : TextInputAction.next,
        style: GoogleFonts.mcLaren(color: Colors.black),
        decoration: InputDecoration(
          prefixIcon: icon,
          suffixIcon: controller == Controllers.passwordController
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
          errorText: controller == Controllers.emailController ? emailError : null,
        ),
      ),
    );
  }
}
