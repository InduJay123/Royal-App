import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final companyNameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final taglineController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    companyNameController.text = prefs.getString('companyName') ?? '';
    addressController.text = prefs.getString('address') ?? '';
    phoneController.text = prefs.getString('phone') ?? '';
    emailController.text = prefs.getString('email') ?? '';
    taglineController.text = prefs.getString('tagline') ?? '';
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('companyName', companyNameController.text);
    await prefs.setString('address', addressController.text);
    await prefs.setString('phone', phoneController.text);
    await prefs.setString('email', emailController.text);
    await prefs.setString('tagline', taglineController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Settings saved")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Business Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextFormField(
              controller: companyNameController,
              decoration: const InputDecoration(labelText: "Company Name"),
            ),
            TextFormField(
              controller: addressController,
              decoration: const InputDecoration(labelText: "Address"),
              maxLines: 2,
            ),
            TextFormField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Phone"),
            ),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextFormField(
              controller: taglineController,
              decoration: const InputDecoration(labelText: "Tagline"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveSettings,
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
