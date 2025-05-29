import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rebi_vin_decoder/rebi_vin_decoder.dart';

import '../main.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _vinController = TextEditingController();
  File? _image;

  String? _vinMake;
  String? _vinModel;
  String? _vinType;
  String? _vinYear;
  String? _vinManufacturer;
  String? _vinRegion;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _nameController.text = prefs.getString('userName') ?? '';
    _phoneController.text = prefs.getString('userPhone') ?? '';
    _vinController.text = prefs.getString('userVin') ?? '';
    String? imagePath = prefs.getString('userAvatar');
    if (imagePath != null) {
      _image = File(imagePath);
    }

    _vinMake = prefs.getString('vinMake');
    _vinModel = prefs.getString('vinModel');
    _vinType = prefs.getString('vinType');
    _vinYear = prefs.getString('vinYear');
    _vinManufacturer = prefs.getString('vinManufacturer');
    _vinRegion = prefs.getString('vinRegion');

    setState(() {});
  }

  _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _nameController.text);
    await prefs.setString('userPhone', _phoneController.text);
    await prefs.setString('userVin', _vinController.text);

    if (_image != null) {
      await prefs.setString('userAvatar', _image!.path);
    }

    // Спроба декодувати VIN
    try {
      var vin = VIN(number: _vinController.text, extended: true);

      _vinYear = vin.getYear().toString();
      _vinRegion = vin.getRegion();
      _vinManufacturer = vin.getManufacturer();

      var make = await vin.getMakeAsync();
      var model = await vin.getModelAsync();
      var type = await vin.getVehicleTypeAsync();

      _vinMake = make;
      _vinModel = model;
      _vinType = type;

      await prefs.setString('vinMake', _vinMake ?? '');
      await prefs.setString('vinModel', _vinModel ?? '');
      await prefs.setString('vinType', _vinType ?? '');
      await prefs.setString('vinYear', _vinYear ?? '');
      await prefs.setString('vinManufacturer', _vinManufacturer ?? '');
      await prefs.setString('vinRegion', _vinRegion ?? '');

      setState(() {}); // Оновлення UI
    } catch (e) {
      print('VIN decoding failed: $e');
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Дані оновлено")));
  }

  _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isRegistered', false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
  }

  Widget _buildVinInfo() {
    if (_vinMake == null && _vinModel == null && _vinType == null) {
      return SizedBox.shrink(); // нічого не показуємо
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: 30),
        Text("Результати VIN-декодування:", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        if (_vinMake != null) Text("Марка: $_vinMake"),
        if (_vinModel != null) Text("Модель: $_vinModel"),
        if (_vinType != null) Text("Тип авто: $_vinType"),
        if (_vinYear != null) Text("Рік випуску: $_vinYear"),
        if (_vinManufacturer != null) Text("Виробник: $_vinManufacturer"),
        if (_vinRegion != null) Text("Регіон: $_vinRegion"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Профіль')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: _image != null
                  ? FileImage(_image!)
                  : AssetImage('assets/default_avatar.png') as ImageProvider,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Змінити аватарку'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Ваше ім’я'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: 'Номер телефону'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _vinController,
              decoration: InputDecoration(labelText: 'VIN код'),
            ),
            _buildVinInfo(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveUserData,
              child: Text('Зберегти'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Вийти'),
            ),
          ],
        ),
      ),
    );
  }
}
