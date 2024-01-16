// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musicapp/screens/SignInAndSignUp/signin_page.dart';
import 'package:page_transition/page_transition.dart';

Widget textField({
  required String label,
  required TextEditingController controller,
  TextInputType? keyboardtype,
  String? Function(String?)? validator,
  bool? obscureText,
  String? Function(String?)? onchanged,
  String? hinttext,
  Function()? ontap,
  bool? readonly,
}) {
  return Container(
    decoration: const BoxDecoration(

      boxShadow: [
        // BoxShadow(
        //   color: Color.fromARGB(141, 255, 255, 255),
        //   blurRadius: 80,
        //   offset: Offset(5, 5),
        //   spreadRadius: 1,
        // ),
        // BoxShadow(
        //   color: Color.fromARGB(138, 255, 255, 255),
        //   blurRadius: 80,
        //   offset: Offset(-5, -5),
        //   spreadRadius: 00,
        // )
      ],
    ),
    child: TextFormField(
      
      readOnly: readonly ?? false,
      onTap: ontap,
      keyboardType: keyboardtype ?? TextInputType.name,
      autocorrect: true,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      obscureText: obscureText ?? false,
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hinttext,
        hintStyle: const TextStyle(color: Color.fromARGB(132, 255, 255, 255)),
        errorStyle: const TextStyle(
            color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold),
        labelText: label,
        labelStyle: GoogleFonts.aBeeZee(
            textStyle: const TextStyle(
          color: Colors.white,
        )),
        filled: true,
        fillColor: const Color.fromARGB(162, 0, 0, 0),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(width: 2, color: Colors.red),
        ),
        focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(width: 2, color: Colors.red)),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromARGB(255, 0, 255, 247),
            width: 2.0,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromARGB(255, 255, 250, 250),
            width: 2.0,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
      ),
      validator: validator,
      onChanged: onchanged,
    ),
  );
}

Widget buttons({
  String? buttonText,
  Widget? navigation,
  BuildContext? ctx,
  TextEditingController? usernamecontroller,
  TextEditingController? passwordcontroller,
}) {
  return ElevatedButton(
    onPressed: () {
      if (usernamecontroller!.text == 'Admin12' &&
          passwordcontroller!.text == '1234') {
        print('navigated');
        Navigator.pushReplacement(
          ctx!,
          PageTransition(
            child: const SignInPage(),
            type: PageTransitionType.fade,
          ),
        );
      } else {
        print('notnavigated');

        Navigator.pushReplacement(
          ctx!,
          PageTransition(
            child: navigation!,
            type: PageTransitionType.fade,
          ),
        );
      }
    },
    style: ButtonStyle(
      minimumSize: MaterialStateProperty.all(const Size(120, 50)),
    ),
    child: Text(
      buttonText!,
      style: GoogleFonts.rowdies(color: Colors.black, fontSize: 20),
    ),
  );
}

Widget pageHeading(
    {String? head1, String? head2, String? font1, String? font2}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Text(
        head1!,
        style: GoogleFonts.getFont(font1!, fontSize: 35, color: Colors.white),
      ),
      Text(
        head2!,
        style: GoogleFonts.getFont(font2!, fontSize: 15, color: Colors.white),
      ),
      const SizedBox(
        height: 30,
      )
    ],
  );
}

Widget suggest({
  required BuildContext ctx,
  String? firsttext,
  String? linktext,
  Function? page,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        firsttext!,
        style: GoogleFonts.roboto(color: Colors.white),
      ),
      GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            ctx,
            PageTransition(
              child: page != null ? page() : const SizedBox(),
              type: PageTransitionType.fade,
            ),
          );
        },
        child: Text(
          linktext!,
          style: GoogleFonts.roboto(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
      )
    ],
  );
}

Widget bottomHead(
    {String? head1,
    String? head2,
    String? font,
    double? head1size,
    double? head2size}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Column(
        children: [
          Text(
            head1!,
            style: GoogleFonts.getFont(
              font!,
              color: Colors.white,
              fontSize: head1size,
            ),
          ),
          Text(
            head2!,
            style: GoogleFonts.getFont(
              font,
              color: Colors.white,
              fontSize: head2size,
            ),
          )
        ],
      ),
    ],
  );
}
