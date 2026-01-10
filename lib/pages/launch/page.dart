import 'package:flutter/material.dart';
import 'package:gitguilar/pages/launch/controller.dart';
import 'package:gitguilar/utils/git.dart';

class LaunchPage extends StatefulWidget {
  const LaunchPage({super.key});

  @override
  State<LaunchPage> createState() => _LaunchPageState();
}

enum _RepositoryType { local, remote }

class _LaunchPageState extends State<LaunchPage> {
  late LaunchController _controller;
  final bool _isInstalledGit = Git.instance.isInstalled;
  _RepositoryType _repositoryType = _RepositoryType.local;

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
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {},
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey[200],
            height: 48,
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 6.0,
            ),
            child: Row(
              spacing: 12,
              children: [
                ToggleButtons(
                  isSelected: [
                    _repositoryType == _RepositoryType.local,
                    _repositoryType == _RepositoryType.remote,
                  ],
                  onPressed: (index) {
                    setState(() {
                      _repositoryType = index == 0
                          ? _RepositoryType.local
                          : _RepositoryType.remote;
                    });
                  },
                  children: [
                    _RepositoryTypeButton(
                      repositoryType: _RepositoryType.local,
                      isSelected: _repositoryType == _RepositoryType.local,
                    ),
                    _RepositoryTypeButton(
                      repositoryType: _RepositoryType.remote,
                      isSelected: _repositoryType == _RepositoryType.remote,
                    ),
                  ],
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "搜索仓库",
                      contentPadding: .zero,
                      filled: true,
                      hoverColor: Colors.transparent,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RepositoryTypeButton extends StatelessWidget {
  final _RepositoryType repositoryType;
  final bool isSelected;

  const _RepositoryTypeButton({
    required this.repositoryType,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        repositoryType == _RepositoryType.local ? "本地仓库" : "远程仓库",
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
    );
  }
}
