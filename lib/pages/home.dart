import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const storage = FlutterSecureStorage();
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Home"),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: TextButton(
              onPressed: () async {
                await storage.delete(key: "username");
                await storage.delete(key: "password");
                await storage.delete(key: "secret_key");
                await storage.delete(key: "checksum");
              },
              child: Text("Delete")),
        ),
      ),
    );
  }
}
