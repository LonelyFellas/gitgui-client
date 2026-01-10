import 'package:flutter/material.dart';
import 'package:gitguilar/pages/launch/controller.dart';
import 'package:gitguilar/utils/git.dart';

class LaunchPage extends StatefulWidget {
  const LaunchPage({super.key});

  @override
  State<LaunchPage> createState() => _LaunchPageState();
}

class _LaunchPageState extends State<LaunchPage> {
  late LaunchController _controller;
  final bool _isInstalledGit = Git.instance.isInstalled;

  @override
  void initState() {
    super.initState();
    _controller = LaunchController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Git Guilar')),
      body: Center(
        child: Text(
          'Git is ${_isInstalledGit ? 'installed' : 'not installed'}',
        ),
      ),
    );
  }
}
