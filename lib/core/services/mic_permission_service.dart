import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

class MicPermissionService extends StatefulWidget {
  final WidgetBuilder builder;
  const MicPermissionService({super.key, required this.builder});

  @override
  State<MicPermissionService> createState() => _MicPermissionServiceState();
}

class _MicPermissionServiceState extends State<MicPermissionService> {
  bool _isChecking = true;
  bool _granted = false;
  bool _permanentlyDenied = false;
  @override
  void initState() {
    super.initState();
    _checkAndRequest();
  }

  Future<void> _checkAndRequest() async {
    setState(() {
      _isChecking = true;
      _permanentlyDenied = false;
    });
    final status = await Permission.microphone.status;
    if (status.isGranted) {
      setState(() {
        _isChecking = false;
        _granted = true;
      });
      return;
    }
    final req = await Permission.microphone.request();
    if (req.isGranted) {
      setState(() {
        _isChecking = false;
        _granted = true;
      });
      return;
    }
    setState(() {
      _isChecking = false;
      _granted = false;
      _permanentlyDenied = req.isPermanentlyDenied;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_granted) {
      return widget.builder(context);
    }
    return  Scaffold(
      appBar: AppBar(title: const Text('Microphone Permission')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            const Text(
              'Scribe needs access to your microphone to record meetings.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            if (_permanentlyDenied)
              const Text(
                'Microphone permission is permanently denied. Please enable it from system Settings.',
                style: TextStyle(color: Colors.orange),
              ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Go back to home if user declines
                      context.goNamed('mainScreen');
                    },
                    child: const Text('Not now'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_permanentlyDenied) {
                        await openAppSettings();
                        // After returning from settings, re-check
                        await _checkAndRequest();
                      } else {
                        await _checkAndRequest();
                      }
                    },
                    child: Text(_permanentlyDenied ? 'Open Settings' : 'Allow'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}