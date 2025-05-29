import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/main.dart';
import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool isRegistering = false; // Відображати екран вибору чи реєстрацію
  bool isPhoneValid = false;

  void _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _nameController.text);
    await prefs.setString('userPhone', _phoneController.text);
    await prefs.setBool('isRegistered', true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
  }

  void _continueAsGuest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isRegistered', false); // Позначаємо, що гість

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
  }

  void _validatePhoneNumber(String value) {
    final phoneRegex = RegExp(r'^\d{1,15}$'); // Тільки цифри, макс 15 символів
    setState(() {
      isPhoneValid = phoneRegex.hasMatch(value);
    });
  }

  void _onLogin(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userPhone', phoneNumber);
    await prefs.setBool('isRegistered', true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(isRegistering ? 'Реєстрація' : 'Ласкаво просимо')),
    body: Center(
    child: Padding(
    padding: EdgeInsets.all(16.0),
    child: isRegistering
    ? Column(
    mainAxisSize: MainAxisSize.min,
    children: [
    TextField(
    controller: _nameController,
    decoration: InputDecoration(labelText: 'Ваше ім’я'),
    ),
    TextField(
    controller: _phoneController,
    keyboardType: TextInputType.number,
    maxLength: 15,
    decoration: InputDecoration(
    labelText: 'Номер телефону',
    counterText: "", // Прибираємо відображення лічильника символів
    ),
    onChanged: _validatePhoneNumber,
    ),
    SizedBox(height: 20),
    ElevatedButton(
    onPressed: isPhoneValid ? _saveUserData : null, // Вимикаємо кнопку, якщо номер некоректний
    child: Text('Зареєструватись'),
    ),
    TextButton(
    onPressed: () => setState(() => isRegistering = false),
    child: Text('Назад'),
    ),
    ],
    )
        : Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
    ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(onLogin: _onLogin),
        ),
      );
    }, // Заглушка для входу
    child: Text('Увійти'),
    ),
    SizedBox(height: 10),
    ElevatedButton(
    onPressed: () => setState(() => isRegistering = true),
    child: Text('Зареєструватись'),
    ),
    SizedBox(height: 10),
    TextButton(
    onPressed: _continueAsGuest,
    child: Text('Продовжити як гість'),
    ),
    ],
    ),
    ),
    ),
    );
  }

}
