import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpn_basic_project/helpers/pref.dart';
import 'package:vpn_basic_project/screens/split_tunneling_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String selectedProtocol = 'Auto';
  bool showNotification = true;

  final List<String> protocols = [
    'Auto',
    'Open VPN',
    'Ipsec',
    'IKEver2',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedProtocol = prefs.getString('protocol') ?? 'Auto';
      showNotification = prefs.getBool('showNotification') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('protocol', selectedProtocol);
    await prefs.setBool('showNotification', showNotification);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Pref.isDartMode ? null : Colors.orange,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Setting',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
      body: ListView(
        children: [
          // VPN Protocol Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'VPN protocol',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...protocols.map((protocol) => RadioListTile<String>(
                value: protocol,
                groupValue: selectedProtocol,
                title: Text(protocol),
                onChanged: (value) {
                  setState(() {
                    selectedProtocol = value!;
                  });
                },
              )),

          const Divider(height: 32),

          // Split Tunneling Section
          ListTile(
            title: const Text('Split tunneling'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Get.to(() => const SplitTunnelingScreen());
            },
          ),

          const Divider(height: 32),

          // Notification Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Notification',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text(
              'Show notification when VPN\nis disconnect',
              style: TextStyle(fontSize: 14),
            ),
            value: showNotification,
            onChanged: (bool value) {
              setState(() {
                showNotification = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
