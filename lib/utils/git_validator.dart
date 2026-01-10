import 'dart:io';

/// Git 仓库信息模型
class RepositoryInfo {
  final String path;
  final String branch;
  final String? remoteUrl;

  RepositoryInfo({required this.path, required this.branch, this.remoteUrl});
}

/// Git 仓库验证工具类
class GitValidator {
  /// 检查指定路径是否为有效的 Git 仓库
  static Future<bool> isValidRepository(String path) async {
    try {
      final gitDir = Directory('$path/.git');
      return await gitDir.exists();
    } catch (e) {
      return false;
    }
  }

  /// 获取当前分支名称（通过读取 HEAD 文件）
  static Future<String?> getCurrentBranch(String path) async {
    try {
      final headFile = File('$path/.git/HEAD');
      if (!await headFile.exists()) {
        return null;
      }

      final content = await headFile.readAsString();
      final trimmed = content.trim();

      // HEAD 文件格式可能是：
      // ref: refs/heads/main  (正常分支)
      // 或者是一个 commit hash (detached HEAD)
      if (trimmed.startsWith('ref: refs/heads/')) {
        // 提取分支名称
        return trimmed.substring('ref: refs/heads/'.length);
      } else if (trimmed.length >= 7) {
        // detached HEAD，返回前 7 个字符
        return trimmed.substring(0, 7);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取远程仓库地址（通过读取 config 文件）
  static Future<String?> getRemoteUrl(String path) async {
    try {
      final configFile = File('$path/.git/config');
      if (!await configFile.exists()) {
        return null;
      }

      final content = await configFile.readAsString();
      final lines = content.split('\n');

      // 查找 [remote "origin"] 部分
      bool inOriginSection = false;
      for (var line in lines) {
        final trimmed = line.trim();

        if (trimmed.startsWith('[remote "origin"]')) {
          inOriginSection = true;
          continue;
        }

        if (trimmed.startsWith('[')) {
          inOriginSection = false;
          continue;
        }

        if (inOriginSection && trimmed.startsWith('url =')) {
          // 提取 URL
          final url = trimmed.substring('url ='.length).trim();
          return url;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// 验证仓库并获取仓库信息
  static Future<RepositoryInfo?> validateRepository(String path) async {
    try {
      // 检查是否为 Git 仓库
      if (!await isValidRepository(path)) {
        return null;
      }

      // 获取当前分支
      final branch = await getCurrentBranch(path);
      if (branch == null) {
        return null;
      }

      // 获取远程地址（可选）
      final remoteUrl = await getRemoteUrl(path);

      return RepositoryInfo(path: path, branch: branch, remoteUrl: remoteUrl);
    } catch (e) {
      return null;
    }
  }
}
