import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/api_config.dart';
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                Icons.cloud_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Tabbr',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your Tabbr server URL',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.url,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Server URL',
                  hintText: 'http://localhost:8000',
                ),
              ),
              if (_status != null) ...[
                const SizedBox(height: 12),
                Text(
                  _status!,
                  style: TextStyle(
                    color: _status!.startsWith('Connected')
                        ? Colors.greenAccent
                        : Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving || _testing ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save and continue'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _saving || _testing ? null : _test,
                child: _testing
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Test connection'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
