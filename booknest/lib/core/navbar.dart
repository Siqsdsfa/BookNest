import 'package:booknest/core/auth.dart';
import 'package:booknest/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(FirebaseAuth.instance.currentUser!.uid),
            accountEmail: Text('${FirebaseAuth.instance.currentUser!.email}'),
            currentAccountPicture: const CircleAvatar(
              radius: 32,
              child: Icon(
                Icons.person,
                size: 60,
                color: Colors.black,
              ),
            ),
            decoration:
                const BoxDecoration(color: Color.fromARGB(255, 106, 205, 230)),
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text('Sign Out'),
            onTap: () async {
              await Auth().signOut();
              if (context.mounted) {
                context.pushNamed(LoginScreen.name);
              }
            },
          ),
        ],
      ),
    );
  }
}
