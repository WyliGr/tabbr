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
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // ── Icon ──
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppTheme.accentSoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.dns_rounded,
                    size: 34,
                    color: AppTheme.accent,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Connect to server',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: AppTheme.ink,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Enter your Tabbr server URL',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.inkSecondary,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.url,
                autocorrect: false,
                style: const TextStyle(color: AppTheme.ink, fontSize: 15),
                decoration: const InputDecoration(
                  labelText: 'Server URL',
                  hintText: 'http://localhost:8000',
                ),
              ),
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
              // ── Save button (ink filled) ──
              Opacity(
                opacity: _saving || _testing ? 0.6 : 1.0,
                child: Material(
                  color: AppTheme.ink,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    onTap: _saving || _testing ? null : _save,
                    child: Container(
                      height: 52,
                      alignment: Alignment.center,
                      child: _saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.background,
                              ),
                            )
                          : const Text(
                              'Save and continue',
                              style: TextStyle(
                                color: AppTheme.background,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // ── Test button (outlined) ──
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: _saving || _testing ? null : _test,
                  child: _testing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
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