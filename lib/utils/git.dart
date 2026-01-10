import 'package:gitguilar/utils/app_logger.dart';
import 'package:process_run/shell.dart';

class Git {
  static final Git instance = Git._internal();
  factory Git() => instance;
  Git._internal();

  final shell = Shell();
  String? gitPath;

  Future<void> initialize() async {
    await findGitPath();
  }

  Future<void> findGitPath() async {
    gitPath = await which('git');
    AppLogger.d('findGitPath: $gitPath');
  }

  bool get isInstalled => gitPath != null;
}
