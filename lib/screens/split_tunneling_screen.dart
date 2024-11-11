import 'package:flutter/material.dart';

class SplitTunnelingScreen extends StatefulWidget {
  const SplitTunnelingScreen({super.key});

  @override
  State<SplitTunnelingScreen> createState() => _SplitTunnelingScreenState();
}

class _SplitTunnelingScreenState extends State<SplitTunnelingScreen> {
  bool isEnabled = false;
  final List<AppItem> apps = [
    AppItem(
      name: 'Chrome',
      packageName: 'com.android.chrome',
      icon: Icons.android,
    ),
    AppItem(
      name: 'YouTube',
      packageName: 'com.google.android.youtube',
      icon: Icons.play_circle_outlined,
    ),
    AppItem(
      name: 'Gmail',
      packageName: 'com.google.android.gmail',
      icon: Icons.mail_outline,
    ),
    // Add more apps as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Split tunneling'),
      ),
      body: Column(
        children: [
          // Enable/Disable Switch
          SwitchListTile(
            title: const Text(
              'Enable split tunneling',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: const Text(
              'Select apps that will not use VPN',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            value: isEnabled,
            onChanged: (bool value) {
              setState(() {
                isEnabled = value;
              });
            },
          ),
          const Divider(),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search apps',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                // Implement search functionality
              },
            ),
          ),

          // Apps List
          Expanded(
            child: ListView.builder(
              itemCount: apps.length,
              itemBuilder: (context, index) {
                final app = apps[index];
                return AppListTile(
                  app: app,
                  enabled: isEnabled,
                  onChanged: (bool? value) {
                    if (isEnabled) {
                      setState(() {
                        app.isSelected = value ?? false;
                      });
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AppItem {
  final String name;
  final String packageName;
  final IconData icon;
  bool isSelected;

  AppItem({
    required this.name,
    required this.packageName,
    required this.icon,
    this.isSelected = false,
  });
}

class AppListTile extends StatelessWidget {
  final AppItem app;
  final bool enabled;
  final ValueChanged<bool?> onChanged;

  const AppListTile({
    super.key,
    required this.app,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(app.icon),
      ),
      title: Text(app.name),
      subtitle: Text(app.packageName),
      trailing: Checkbox(
        value: app.isSelected,
        onChanged: enabled ? onChanged : null,
      ),
    );
  }
} 