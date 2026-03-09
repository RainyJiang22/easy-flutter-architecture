import 'package:easy_flutter_architecture/shared/widgets/app_drawer.dart';
import 'package:flutter/material.dart';

class ShellWithDrawer extends StatelessWidget {
  final Widget child;

  const ShellWithDrawer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: child,
    );
  }
}
