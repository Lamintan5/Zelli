import 'package:Zelli/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final isPass;
  final Icon? prxIcon;
  final IconButton? srfIcon;
  final String? labelText;
  final String? hintText;
  final TextAlign textAlign;
  final TextStyle? labelStyle;
  final TextInputType textInputType;
  final int? maxLength;
  final int? maxLine;
  final String? Function(String?)? validator;

  TextFieldInput({
    Key? key,
    required this.textEditingController,
    this.isPass = false,
    this.prxIcon,
    this.hintText,
    this.maxLength,
    this.maxLine,
    this.textAlign = TextAlign.start,
    this.textInputType = TextInputType.text,
    this.labelText, this.srfIcon, this.labelStyle, this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final color2 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.black26;
    final inputBorder = OutlineInputBorder(
        borderSide: Divider.createBorderSide(context, color: color1)
    );
    return TextFormField(
      enableInteractiveSelection: true,
      controller: textEditingController,
      keyboardType: TextInputType.multiline,
      validator: validator,
      textAlign: textAlign,
      maxLength: maxLength==null?null:maxLength,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      maxLines: maxLine==null?1:maxLine,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: secondaryColor),
        labelText: labelText,
        labelStyle: labelStyle,
        border: inputBorder,
        focusedBorder: inputBorder,
        enabledBorder: inputBorder,
        prefixIcon: prxIcon,
        suffixIcon: srfIcon,
        filled: true,
        fillColor: color1,
        contentPadding: const EdgeInsets.all(10),
      ),
      obscureText: isPass,
    );
  }
}
