import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/api_config.dart';
import '../config/theme.dart';
import '../services/api_service.dart';

class ServerSetupScreen extends StatefulWidget {
  const ServerSetupScreen({super.key});

  @override
  State<ServerSetupScreen> createState() => _ServerSetupScreenState();
}

class _ServerSetupScreenState extends State<ServerSetupScreen> {
  late final TextEditingController _controller;
  bool _testing = false;
  bool _saving = false;
  String? _status;
  bool _statusOk = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context.read<ApiConfig>().serverUrl,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _test() async {
    setState(() {
      _testing = true;
      _status = null;
    });
    final config = context.read<ApiConfig>();
    final api = ApiService(config);
    final url = _controller.text.trim();
    if (url.isEmpty) {
      setState(() {
        _testing = false;
        _status = 'Please enter a server URL';
        _statusOk = false;
      });
      return;
    }
    await config.setServerUrl(url);
    final ok = await api.testConnection();
    if (!mounted) return;
    setState(() {
      _testing = false;
      _status = ok
          ? 'Connected successfully'
          : 'Could not reach the server. Check the URL and try again.';
      _statusOk = ok;
    });
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _status = null;
    });
    final config = context.read<ApiConfig>();
    final api = ApiService(config);
    final url = _controller.text.trim();
    if (url.isEmpty) {
      setState(() {
        _saving = false;
        _status = 'Please enter a server URL';
        _statusOk = false;
      });
      return;
    }
    await config.setServerUrl(url);
    final ok = await api.testConnection();
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _status = 'Could not reach the server. Check the URL and try again.';
        _statusOk = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Gradient circle with cloud icon
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x447C5CFC),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.cloud_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Connect to server',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your Tabbr server URL',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 36),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.url,
                autocorrect: false,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Server URL',
                  hintText: 'http://localhost:8000',
                ),
              ),
              // Status message
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: _status != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Row(
                          children: [
                            Icon(
                              _statusOk
                                  ? Icons.check_circle_rounded
                                  : Icons.error_outline_rounded,
                              color: _statusOk
                                  ? AppTheme.positive
                                  : AppTheme.negative,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _status!,
                                style: TextStyle(
                                  color: _statusOk
                                      ? AppTheme.positive
                                      : AppTheme.negative,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 28),
              // Save button (gradient)
              GestureDetector(
                onTap: _saving || _testing ? null : _save,
                child: Opacity(
                  opacity: _saving || _testing ? 0.5 : 1.0,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x447C5CFC),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _saving
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Save and continue',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Test button (outline)
              SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: _saving || _testing ? null : _test,
                  child: _testing
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Test connection'),
                ),
              ),
              const Spacer(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}