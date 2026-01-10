import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gitguilar/utils/app_logger.dart';

/// 全局异常处理器
class ErrorHandler {
  /// 初始化全局异常处理
  static void initialize() {
    // 处理 Flutter 框架异常
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _logError(
        'Flutter框架异常',
        details.exception,
        details.stack,
        details.context,
      );
    };

    // 自定义错误 Widget 构建器
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return _DefaultErrorWidget(
        error: details.exception,
        stackTrace: details.stack,
      );
    };

    // 处理异步异常（未捕获的 Future 异常）
    PlatformDispatcher.instance.onError = (error, stack) {
      _logError('异步异常', error, stack);
      return true; // 返回 true 表示已处理异常
    };
  }

  /// 在 Zone 中运行应用，捕获所有未捕获的异常
  static void runZonedGuardedApp(VoidCallback appRunner) {
    runZonedGuarded(
      () {
        appRunner();
      },
      (error, stack) {
        _logError('未捕获的异常', error, stack);
      },
    );
  }

  /// 记录错误信息（公共方法，供外部调用）
  static void logError(
    String type,
    dynamic error,
    StackTrace? stackTrace, [
    DiagnosticsNode? context,
  ]) {
    _logError(type, error, stackTrace, context);
  }

  /// 记录错误信息（内部实现）
  static void _logError(
    String type,
    dynamic error,
    StackTrace? stackTrace, [
    DiagnosticsNode? context,
  ]) {
    final errorMessage = error.toString();
    final stackTraceStr = stackTrace?.toString() ?? '无堆栈信息';
    final contextStr = context?.toString() ?? '';

    // 记录到日志
    AppLogger.e('[$type] $errorMessage', error, stackTrace);

    // 在调试模式下打印详细信息
    if (kDebugMode) {
      debugPrint('========== $type ==========');
      debugPrint('错误: $errorMessage');
      debugPrint('堆栈跟踪:');
      debugPrint(stackTraceStr);
      if (contextStr.isNotEmpty) {
        debugPrint('上下文: $contextStr');
      }
      debugPrint('===========================');
    }

    // 在生产环境中，这里可以添加错误上报逻辑
    // 例如：发送到错误监控服务（如 Sentry、Firebase Crashlytics 等）
    // _reportToErrorService(type, errorMessage, stackTraceStr);
  }

  /// 上报错误到错误监控服务（可选）
  /// 示例：可以集成 Sentry、Firebase Crashlytics 等
  // static void _reportToErrorService(
  //   String type,
  //   String errorMessage,
  //   String stackTrace,
  // ) {
  //   // TODO: 实现错误上报逻辑
  //   // Sentry.captureException(error, stackTrace: stackTrace);
  // }
}

/// 错误边界 Widget，用于捕获 Widget 树中的异常
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(BuildContext context, Object error, StackTrace? stack)?
  errorBuilder;

  const ErrorBoundary({super.key, required this.child, this.errorBuilder});

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(context, _error!, _stackTrace);
      }
      return _DefaultErrorWidget(
        error: _error!,
        stackTrace: _stackTrace,
        onRetry: () {
          setState(() {
            _error = null;
            _stackTrace = null;
          });
        },
      );
    }

    // 使用 try-catch 包裹子 Widget 来捕获构建错误
    try {
      return widget.child;
    } catch (error, stackTrace) {
      // 记录错误
      ErrorHandler.logError('Widget构建异常', error, stackTrace);

      // 更新状态以显示错误 UI
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _error = error;
            _stackTrace = stackTrace;
          });
        }
      });

      // 返回错误 Widget
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(context, error, stackTrace);
      }
      return _DefaultErrorWidget(
        error: error,
        stackTrace: stackTrace,
        onRetry: () {
          setState(() {
            _error = null;
            _stackTrace = null;
          });
        },
      );
    }
  }
}

/// 默认错误显示 Widget
class _DefaultErrorWidget extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback? onRetry;

  const _DefaultErrorWidget({
    required this.error,
    this.stackTrace,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('发生错误'), backgroundColor: Colors.red),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              const Text(
                '应用遇到了一个错误',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (onRetry != null)
                ElevatedButton(onPressed: onRetry, child: const Text('重试')),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // 复制错误信息到剪贴板
                  final errorText =
                      '错误: ${error.toString()}\n\n'
                      '堆栈跟踪:\n${stackTrace?.toString() ?? "无"}';
                  Clipboard.setData(ClipboardData(text: errorText));
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('错误信息已复制到剪贴板')));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                ),
                child: const Text('复制错误信息'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
