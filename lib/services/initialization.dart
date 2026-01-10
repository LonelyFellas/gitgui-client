import 'package:gitguilar/utils/git.dart';

class InitializationService {
  InitializationService();

  static Future<void> initialize() async {
    await Git.instance.initialize();
  }
}
