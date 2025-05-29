import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/user_service.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _vinController = TextEditingController();
  final _carModelController = TextEditingController();
  final _carYearController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final profile = await UserService.loadProfile();
    if (profile != null) {
      setState(() {
        _nameController.text = profile.name;
        _phoneController.text = profile.phoneNumber;
        _emailController.text = profile.email;
        _vinController.text = profile.vinCode;
        _carModelController.text = profile.carModel;
        _carYearController.text = profile.carYear;
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      final profile = UserProfile(
        name: _nameController.text,
        phoneNumber: _phoneController.text,
        email: _emailController.text,
        vinCode: _vinController.text,
        carModel: _carModelController.text,
        carYear: _carYearController.text,
      );

      UserService.saveProfile(profile);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Профіль збережено!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Мій профіль'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Ім\'я'),
                validator: (value) => value!.isEmpty ? 'Введіть ім\'я' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Номер телефону'),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                value!.isEmpty ? 'Введіть номер телефону' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty ? 'Введіть email' : null,
              ),
              TextFormField(
                controller: _vinController,
                decoration: InputDecoration(labelText: 'VIN код'),
                validator: (value) => value!.isEmpty ? 'Введіть VIN код' : null,
              ),
              TextFormField(
                controller: _carModelController,
                decoration: InputDecoration(labelText: 'Модель автомобіля'),
                validator: (value) =>
                value!.isEmpty ? 'Введіть модель автомобіля' : null,
              ),
              TextFormField(
                controller: _carYearController,
                decoration: InputDecoration(labelText: 'Рік автомобіля'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? 'Введіть рік автомобіля' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfile,
                child: Text('Зберегти профіль'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
