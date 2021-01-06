import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realtime_chat_app/helpers/show_alert.dart';
import 'package:realtime_chat_app/services/auth_service.dart';
import 'package:realtime_chat_app/services/socket_service.dart';

import 'package:realtime_chat_app/widgets/custom_input.dart';
import 'package:realtime_chat_app/widgets/login_button.dart';
import 'package:realtime_chat_app/widgets/login_labels.dart';
import 'package:realtime_chat_app/widgets/login_logo.dart';

class RegisterPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F2F2),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Logo(title: "Registro" ,),
                _Form(),
                Labels(
                  text1: 'Ya tienes cuenta?',
                  text2: 'Ingresa con tu usuario',
                  route: 'login',
                ),
                Text('Terminos y condiciones de uso', style: TextStyle(fontWeight: FontWeight.w200),),
              ],
            ),
          ),
        ),
      )
   );
  }
}


class _Form extends StatefulWidget {
  @override
  __FormState createState() => __FormState();
}

class __FormState extends State<_Form> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final socketService = Provider.of<SocketService>(context);
    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: [
          CustomInput(
            icon: Icons.perm_identity,
            placeholder: 'Nombre',
            textController: nameCtrl,
          ),
          CustomInput(
            icon: Icons.mail_outline,
            placeholder: 'Email',
            keyboardType: TextInputType.emailAddress,
            textController: emailCtrl,
          ),
          CustomInput(
            icon: Icons.lock_outline,
            placeholder: 'Password',
            textController: passwordCtrl,
            isPassword: true,
          ),
          LoginButton(
            text: 'Crear',
            onPressed: authService.authenticating ? null : () async{
              FocusScope.of(context).unfocus();
              final registrationResult = await authService.register(nameCtrl.text, emailCtrl.text.trim(), passwordCtrl.text.trim());

              if(registrationResult == true){
                socketService.connect();
                Navigator.pushReplacementNamed(context, 'users');
              }else{
                showAlert(context, 'Registro Incorrecto', registrationResult);
              }
            }
          ),
        ],
      ),
    );
  }
}

