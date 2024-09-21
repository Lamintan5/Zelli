import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

class EmailTextFormWidget extends StatefulWidget {
  final TextEditingController controller;
  final String? action;
  const EmailTextFormWidget({Key? key, required this.controller, this.action}) : super(key: key);

  @override
  State<EmailTextFormWidget> createState() => _EmailTextFormWidgetState();
}

class _EmailTextFormWidgetState extends State<EmailTextFormWidget> {
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
      controller: widget.controller,
      enableSuggestions: true,
      decoration: InputDecoration(
        labelText: 'Email Address',
        border: inputBorder,
        focusedBorder: inputBorder,
        enabledBorder: inputBorder,
        filled: true,
        fillColor: color1,
        contentPadding: const EdgeInsets.all(10),
        prefixIcon:widget.action == "no"? null : Icon(Icons.mail_outline),
      ),
      keyboardType: TextInputType.emailAddress,
      autofillHints: [AutofillHints.email],
      validator: (email) => email !=null && !EmailValidator.validate(email)
          ? 'Enter a valid email'
          : null,
    );
  }
}
