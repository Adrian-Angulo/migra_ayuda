import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:migra_ayuda/presentation/pages/widget/button_google_widget.dart';
import 'package:migra_ayuda/presentation/pages/widget/text_fiel_pasword_widget.dart';
import 'package:migra_ayuda/presentation/pages/widget/text_fiel_widget.dart';
import 'package:migra_ayuda/presentation/widgets/button_widget.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passController = TextEditingController();

    return Form(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16),
            TextFieldWidget(
              title: "Correo electronico",
              hintText: "Ej. usuario@gmail.com",
              controller: _emailController,
            ),
            SizedBox(height: 16),
            TextFieldPaswordWidget(
              title: "Contraseña",
              hintText: "",
              controller: _passController,
            ),
            SizedBox(height: 16),
            ButtonWidget(formKey: _formKey, text: 'Iniciar Sesión'),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Divider(height: 2)),
                Text("O Registrase con"),
                Expanded(child: Divider(height: 2)),
              ],
            ),
            SizedBox(height: 16),
            ButtonGoogleWidget(),
          ],
        ),
      ),
    );
  }
}
