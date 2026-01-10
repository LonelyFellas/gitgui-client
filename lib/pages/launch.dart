import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gitguilar/utils/git_validator.dart';

/// Launch 页面状态枚举
enum LaunchState {
  initial, // 初始状态
  selecting, // 选择文件夹中
  validating, // 验证中
  success, // 验证成功
  error, // 验证失败
}

class LaunchPage extends StatefulWidget {
  const LaunchPage({super.key});

  @override
  State<LaunchPage> createState() => _LaunchPageState();
}

class _LaunchPageState extends State<LaunchPage> {
  LaunchState _state = LaunchState.initial;
  String? _selectedPath;
  String? _errorMessage;
  RepositoryInfo? _repositoryInfo;
  final TextEditingController _pathController = TextEditingController();

  /// 选择文件夹
  Future<void> _selectFolder() async {
    setState(() {
      _state = LaunchState.selecting;
      _errorMessage = null;
    });

    try {
      final result = await FilePicker.platform.getDirectoryPath();

      if (result != null) {
        _selectedPath = result;
        _pathController.text = result;
        await _validateRepository(result);
      } else {
        setState(() {
          _state = LaunchState.initial;
        });
      }
    } catch (e) {
      setState(() {
        _state = LaunchState.error;
        _errorMessage = '选择文件夹时出错: ${e.toString()}';
      });
    }
  }

  /// 手动输入路径打开
  Future<void> _openFromPath() async {
    final path = _pathController.text.trim();
    if (path.isEmpty) {
      setState(() {
        _state = LaunchState.error;
        _errorMessage = '请输入有效的路径';
      });
      return;
    }

    await _validateRepository(path);
  }

  /// 验证 Git 仓库
  Future<void> _validateRepository(String path) async {
    setState(() {
      _state = LaunchState.validating;
      _errorMessage = null;
    });

    try {
      final info = await GitValidator.validateRepository(path);

      if (info != null) {
        setState(() {
          _state = LaunchState.success;
          _repositoryInfo = info;
          _selectedPath = path;
        });
      } else {
        setState(() {
          _state = LaunchState.error;
          _errorMessage = '这不是一个有效的 Git 仓库';
        });
      }
    } catch (e) {
      setState(() {
        _state = LaunchState.error;
        _errorMessage = '验证仓库时出错: ${e.toString()}';
      });
    }
  }

  /// 重置状态
  void _reset() {
    setState(() {
      _state = LaunchState.initial;
      _selectedPath = null;
      _errorMessage = null;
      _repositoryInfo = null;
      _pathController.clear();
    });
  }

  /// 进入主界面（暂时用占位页面）
  void _enterMainScreen() {
    // TODO: 导航到主界面
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('即将进入主界面: ${_repositoryInfo?.path}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _pathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 标题区域
                  const Icon(Icons.folder, size: 80, color: Colors.blue),
                  const SizedBox(height: 24),
                  const Text(
                    'Git Guilar',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '欢迎使用 Git GUI 桌面端',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 48),

                  // 选择文件夹按钮
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _state == LaunchState.validating
                          ? null
                          : _selectFolder,
                      icon: const Icon(Icons.folder_open),
                      label: const Text(
                        '选择文件夹',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 分隔线
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[300])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '或',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[300])),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 手动输入路径
                  TextField(
                    controller: _pathController,
                    decoration: InputDecoration(
                      labelText: '输入路径',
                      hintText: '请输入 Git 仓库路径',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.edit),
                      suffixIcon: _pathController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _pathController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                    enabled: _state != LaunchState.validating,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _state == LaunchState.validating
                          ? null
                          : _openFromPath,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('打开'),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 状态显示区域
                  _buildStateWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建状态显示组件
  Widget _buildStateWidget() {
    switch (_state) {
      case LaunchState.initial:
        return const SizedBox.shrink();

      case LaunchState.selecting:
        return const SizedBox(
          height: 40,
          child: Center(child: CircularProgressIndicator()),
        );

      case LaunchState.validating:
        return Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              '正在验证 Git 仓库...',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        );

      case LaunchState.success:
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      Text(
                        '验证成功！',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    '路径',
                    _selectedPath ?? _repositoryInfo?.path ?? '',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('当前分支', _repositoryInfo?.branch ?? ''),
                  if (_repositoryInfo?.remoteUrl != null) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow('远程地址', _repositoryInfo!.remoteUrl!),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _enterMainScreen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '进入主界面',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: _reset, child: const Text('重新选择')),
          ],
        );

      case LaunchState.error:
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage ?? '验证失败',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: _reset, child: const Text('重新选择')),
          ],
        );
    }
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }
}
