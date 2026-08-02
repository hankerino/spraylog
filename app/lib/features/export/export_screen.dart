import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/providers.dart';

/// State export generation via the generate-export edge function. CSV
/// only for now; PDF is coming soon.
class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  final _stateController = TextEditingController();
  DateTime? _start;
  DateTime? _end;
  String _format = 'csv';
  bool _busy = false;
  String? _error;
  int? _rowCount;
  String? _signedUrl;

  @override
  void dispose() {
    _stateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _start : _end) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() => isStart ? _start = picked : _end = picked);
  }

  String _dateLabel(DateTime? value, String fallback) {
    return value == null ? fallback : DateFormat('yyyy-MM-dd').format(value);
  }

  Future<void> _generate() async {
    final state = _stateController.text.trim().toUpperCase();
    if (state.length != 2 || _start == null || _end == null) {
      setState(() => _error = 'State and both dates are required');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _rowCount = null;
      _signedUrl = null;
    });
    try {
      final response =
          await ref.read(supabaseClientProvider).functions.invoke(
        'generate-export',
        body: {
          'state': state,
          'range_start': DateFormat('yyyy-MM-dd').format(_start!),
          'range_end': DateFormat('yyyy-MM-dd').format(_end!),
          'format': _format,
        },
      );
      if (!mounted) return;
      final data = response.data;
      if (data is! Map) {
        setState(() => _error = 'Unexpected export response');
        return;
      }
      setState(() {
        _rowCount = (data['rows'] as num?)?.toInt();
        _signedUrl = data['signed_url'] as String?;
      });
    } catch (e) {
      if (mounted) setState(() => _error = 'Export failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _download() async {
    final url = _signedUrl;
    if (url == null) return;
    try {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the download link.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('State export'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _stateController,
            decoration: const InputDecoration(
              labelText: 'State (e.g. FL)',
              counterText: '',
            ),
            textCapitalization: TextCapitalization.characters,
            maxLength: 2,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickDate(isStart: true),
                  icon: const Icon(Icons.date_range, size: 18),
                  label: Text(_dateLabel(_start, 'Start')),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickDate(isStart: false),
                  icon: const Icon(Icons.date_range, size: 18),
                  label: Text(_dateLabel(_end, 'End')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _format,
            decoration: const InputDecoration(labelText: 'Format'),
            items: const [
              DropdownMenuItem(value: 'csv', child: Text('CSV')),
              DropdownMenuItem(value: 'pdf', child: Text('PDF')),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _format = v);
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _busy ? null : _generate,
            child: Text(_busy ? 'Generating…' : 'Generate'),
          ),
          if (_rowCount != null) ...[
            const SizedBox(height: 20),
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text('Export ready — $_rowCount rows'),
                subtitle: _signedUrl == null
                    ? const Text('No download link returned.')
                    : null,
                trailing: _signedUrl == null
                    ? null
                    : FilledButton.tonalIcon(
                        onPressed: _download,
                        icon: const Icon(Icons.download),
                        label: const Text('Download'),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
