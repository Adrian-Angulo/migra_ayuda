import 'package:flutter/material.dart';

class TextFieldNumericWidget extends StatelessWidget {
  final String title;
  final String hintText;
  final int flex;
  final TextEditingController controller;
  final String? Function(String?)? validator;


  const TextFieldNumericWidget({
    super.key,
    required this.title,
    required this.hintText,
    this.flex = 1, 
    required this.controller, this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: flex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: TextInputType.number,
            maxLength: 2,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              hintText: hintText,
              counterText: '',
            ),
          ),
        ],
      ),
    );
  }
}
