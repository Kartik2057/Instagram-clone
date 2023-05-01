import 'package:flutter/material.dart';


class TextFieldInput extends StatelessWidget {
    final TextEditingController controller;
    final bool isPass;
    final String hintText;
    final TextInputType textInputType;
    final logIn;
    const TextFieldInput(
      {Key? key,
      required this.controller,
      this.isPass=false,
      required this.hintText,
      required this.textInputType,
      this.logIn,
      }
    );    

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
          borderSide: Divider.createBorderSide(context)
         );
    
    return TextField(
      controller: controller,
      onSubmitted: isPass?logIn:null,
      decoration: InputDecoration(
         hintText: hintText,
         border: inputBorder,
         focusedBorder: inputBorder,
         enabledBorder: inputBorder,
         filled: true,
         contentPadding: const EdgeInsets.all(8),
      ),
      keyboardType: textInputType,
      obscureText: isPass,
    );
  }
}