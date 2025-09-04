import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../utils/android_optimizations.dart';
import '../services/agent_api_service.dart';

/// Performance monitoring overlay for debugging
class PerformanceDebugOverlay extends StatefulWidget {
  final Widget child;
  
  const PerformanceDebugOverlay({Key? key, required this.child}) : super(key: key);

  @override
  State<PerformanceDebugOverlay> createState() => _PerformanceDebugOverlayState();
}

class _PerformanceDebugOverlayState extends State<PerformanceDebugOverlay> {
  bool _showDebugInfo = false;
  bool _systemHealthy = false;
  String _lastHealthCheck = 'Not checked';
  Duration _lastResponseTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      _checkSystemHealth();
    }
  }

  Future<void> _checkSystemHealth() async {
    final stopwatch = Stopwatch()..start();
    try {
      await AgentApiService.getSystemHealth();
      setState(() {
        _systemHealthy = true;
        _lastHealthCheck = 'Success';
        _lastResponseTime = stopwatch.elapsed;
      });
    } catch (e) {
      setState(() {
        _systemHealthy = false;
        _lastHealthCheck = 'Failed: ${e.toString().split(':').first}';
        _lastResponseTime = stopwatch.elapsed;
      });
    }
    stopwatch.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          widget.child,
          if (kDebugMode)
            Positioned(
              top: 50,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showDebugInfo = !_showDebugInfo;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _systemHealthy ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.bug_report,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          if (kDebugMode && _showDebugInfo)
            Positioned(
              top: 100,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Debug Info',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _debugInfoRow('Platform', AndroidOptimizations.isAndroidEmulator ? 'Android Emulator' : 'Real Device'),
                    _debugInfoRow('API URL', AgentApiService.baseUrl),
                    _debugInfoRow('Timeout', '${AgentApiService.timeoutDuration.inSeconds}s'),
                    _debugInfoRow('Health', _systemHealthy ? 'Healthy' : 'Unhealthy'),
                    _debugInfoRow('Last Check', _lastHealthCheck),
                    _debugInfoRow('Response Time', '${_lastResponseTime.inMilliseconds}ms'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _checkSystemHealth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(120, 30),
                      ),
                      child: const Text('Recheck', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _debugInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
