import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// 网络状态
enum NetworkStatus {
  /// 在线
  online,
  /// 离线
  offline,
  /// 未知
  unknown,
}

/// 网络信息抽象接口
abstract class INetworkInfo {
  /// 当前是否在线
  Future<bool> get isConnected;

  /// 当前网络状态
  Future<NetworkStatus> get status;

  /// 网络状态流
  Stream<NetworkStatus> get onStatusChange;
}

/// 网络信息实现
class NetworkInfo implements INetworkInfo {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final _statusController = StreamController<NetworkStatus>.broadcast();

  NetworkInfo({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  @override
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return _isConnected(results);
  }

  @override
  Future<NetworkStatus> get status async {
    final results = await _connectivity.checkConnectivity();
    return _mapToStatus(results);
  }

  @override
  Stream<NetworkStatus> get onStatusChange => _statusController.stream;

  /// 开始监听网络状态变化
  void startListening() {
    _subscription?.cancel();
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _statusController.add(_mapToStatus(results));
    });
  }

  /// 停止监听
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// 释放资源
  void dispose() {
    stopListening();
    _statusController.close();
  }

  bool _isConnected(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return false;
    }
    return results.any((r) =>
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet);
  }

  NetworkStatus _mapToStatus(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return NetworkStatus.offline;
    }
    if (results.any((r) =>
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet)) {
      return NetworkStatus.online;
    }
    return NetworkStatus.unknown;
  }
}
