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
    final c = AppColors.of(context);

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
              // ── Icon ──
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: c.accentSoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.dns_rounded,
                    size: 30,
                    color: c.accent,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Connect to server',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: c.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Enter your Tabbr server URL',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: c.inkSecondary,
                ),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.url,
                autocorrect: false,
                style: TextStyle(color: c.ink, fontSize: 14),
                decoration: const InputDecoration(
                  labelText: 'Server URL',
                  hintText: 'http://localhost:8000',
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: _status != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Row(
                          children: [
                            Icon(
                              _statusOk
                                  ? Icons.check_circle_rounded
                                  : Icons.error_outline_rounded,
                              color: _statusOk ? c.positive : c.negative,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _status!,
                                style: TextStyle(
                                  color: _statusOk ? c.positive : c.negative,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),
              // ── Save button (ink filled) ──
              Opacity(
                opacity: _saving || _testing ? 0.6 : 1.0,
                child: Material(
                  color: c.ink,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    onTap: _saving || _testing ? null : _save,
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      child: _saving
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: c.background,
                              ),
                            )
                          : Text(
                              'Save and continue',
                              style: TextStyle(
                                color: c.background,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // ── Test button (outlined) ──
              SizedBox(
                height: 48,
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