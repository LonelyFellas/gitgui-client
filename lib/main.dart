import 'package:flutter/material.dart';
import 'package:gitguilar/pages/launch/page.dart';
import 'package:gitguilar/services/initialization.dart';
import 'package:gitguilar/utils/error_handler.dart';

void main() {
  // 初始化全局异常处理
  ErrorHandler.initialize();

  // 在 Zone 中运行应用，捕获所有未捕获的异常
  ErrorHandler.runZonedGuardedApp(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await InitializationService.initialize();

    runApp(const MainPage());
  });
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Git Guilar',
      // ErrorWidget.builder 已在 ErrorHandler.initialize() 中设置
      // 它会自动处理 Widget 构建错误
      home: const LaunchPage(),
    );
  }
}
