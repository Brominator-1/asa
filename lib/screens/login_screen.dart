import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  final Function(String) onLogin;

  LoginScreen({required this.onLogin});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool isPhoneValid = false;

  void _validatePhoneNumber(String value) {
    final phoneRegex = RegExp(r'^\d{1,15}$'); // Дозволені лише цифри, макс. 15 символів
    setState(() {
      isPhoneValid = phoneRegex.hasMatch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Вхід')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.number,
                maxLength: 15,
                decoration: InputDecoration(
                  labelText: 'Номер телефону',
                  counterText: "", // Приховуємо підпис під полем
                ),
                onChanged: _validatePhoneNumber,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isPhoneValid ? () => widget.onLogin(_phoneController.text) : null,
                child: Text('Увійти'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Назад'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
