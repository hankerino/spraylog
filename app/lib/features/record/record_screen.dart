import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_recognition_error.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../core/theme/spraylog_theme.dart';
import '../../core/widgets/section_header.dart';
import 'record_draft.dart';

/// Manual entry form for a new application record, with walkie-talkie
/// style voice capture: tap to talk, auto-stop on a short pause, tap to
/// stop early. Best-effort parsing — full validation happens on the
/// confirm screen. Voice capture is additive: if speech is unavailable or
/// denied, the form stays fully usable.
class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final _brandNameController = TextEditingController();
  final _rateValueController = TextEditingController();
  final _areaValueController = TextEditingController();
  final _targetPestController = TextEditingController();
  final _stateController = TextEditingController();

  final _speech = stt.SpeechToText();
  bool _speechReady = false;
  bool _initializing = false;
  bool _listening = false;
  String? _transcript;
  String? _speechError;

  String _rateUnit = RecordDraft.rateUnits.first;
  String _areaUnit = RecordDraft.areaUnits.first;
  String _applicationMethod = RecordDraft.applicationMethods.first;
  DateTime _appliedAt = DateTime.now();

  @override
  void dispose() {
    _brandNameController.dispose();
    _rateValueController.dispose();
    _areaValueController.dispose();
    _targetPestController.dispose();
    _stateController.dispose();
    _speech.cancel();
    super.dispose();
  }

  Future<void> _pickAppliedAt() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _appliedAt,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_appliedAt),
    );
    if (time == null || !mounted) return;
    setState(() {
      _appliedAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _toggleListening() async {
    if (_listening) {
      // Stop early; the final result / status callback wraps up.
      await _speech.stop();
      return;
    }
    await _startListening();
  }

  Future<void> _startListening() async {
    setState(() => _speechError = null);

    if (!_speechReady) {
      setState(() => _initializing = true);
      var available = false;
      try {
        available = await _speech.initialize(
          onError: _onSpeechError,
          onStatus: _onSpeechStatus,
        );
      } catch (_) {
        available = false;
      }
      if (!mounted) return;
      setState(() => _initializing = false);
      if (!available) {
        setState(() {
          _speechError =
              'Microphone unavailable or permission denied. You can still fill the form manually.';
        });
        return;
      }
      _speechReady = true;
    }

    setState(() {
      _listening = true;
      _transcript = '';
    });
    try {
      await _speech.listen(
        onResult: _onSpeechResult,
        listenOptions: stt.SpeechListenOptions(
          pauseFor: const Duration(seconds: 3),
          listenFor: const Duration(minutes: 2),
          listenMode: stt.ListenMode.dictation,
          partialResults: true,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _listening = false;
        _speechError =
            'Speech recognition failed to start. Manual entry still works.';
      });
    }
  }

  void _onSpeechResult(stt.SpeechRecognitionResult result) {
    if (!mounted) return;
    setState(() => _transcript = result.recognizedWords);
    if (result.finalResult) _finishListening();
  }

  void _onSpeechStatus(String status) {
    if (!mounted || !_listening) return;
    // Walkie-talkie: the plugin ends the session on pauseFor or listenFor.
    if (status == 'done' || status == 'notListening') {
      _finishListening();
    }
  }

  void _onSpeechError(stt.SpeechRecognitionError error) {
    if (!mounted) return;
    setState(() {
      _listening = false;
      _speechError = _describeSpeechError(error.errorMsg);
    });
  }

  void _finishListening() {
    // Per plugin docs, always end the session explicitly.
    _speech.stop();
    if (!mounted) return;
    setState(() {
      _listening = false;
      if ((_transcript ?? '').trim().isEmpty) {
        _transcript = null;
        _speechError ??=
            'No speech recognized. Try again or fill the form manually.';
      }
    });
  }

  static String _describeSpeechError(String errorMsg) {
    return switch (errorMsg) {
      'error_speech_timeout' || 'error_no_match' =>
        'No speech recognized. Try again or fill the form manually.',
      'error_network' || 'error_network_timeout' =>
        'Network issue during recognition — on-device retry usually works.',
      'error_audio' => 'Microphone is busy or unavailable.',
      'error_permission' || 'error_client' =>
        'Microphone permission denied. Enable it in system settings, or fill the form manually.',
      _ => 'Speech recognition error ($errorMsg). Manual entry still works.',
    };
  }

  void _retry() {
    setState(() {
      _transcript = null;
      _speechError = null;
    });
    _startListening();
  }

  void _continue() {
    final transcript = _transcript?.trim();
    final draft = RecordDraft(
      brandName: _brandNameController.text,
      rateValue: double.tryParse(_rateValueController.text.trim()),
      rateUnit: _rateUnit,
      areaValue: double.tryParse(_areaValueController.text.trim()),
      areaUnit: _areaUnit,
      targetPest: _targetPestController.text,
      applicationMethod: _applicationMethod,
      appliedAt: _appliedAt,
      state: _stateController.text,
      transcript:
          transcript == null || transcript.isEmpty ? null : transcript,
    );
    context.push('/record/confirm', extra: draft);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record application'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader('Product'),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _brandNameController,
                decoration: const InputDecoration(
                  labelText: 'Product brand name',
                ),
                textCapitalization: TextCapitalization.words,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader('Rate & Area'),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    controller: _rateValueController,
                    decoration: const InputDecoration(
                      labelText: 'Rate',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _rateUnit,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Rate unit',
                    ),
                    items: [
                      for (final unit in RecordDraft.rateUnits)
                        DropdownMenuItem(
                          value: unit,
                          child: Text(
                            unit,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _rateUnit = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _areaValueController,
                    decoration: const InputDecoration(
                      labelText: 'Area treated',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _areaUnit,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Area unit',
                    ),
                    items: [
                      for (final unit in RecordDraft.areaUnits)
                        DropdownMenuItem(
                          value: unit,
                          child: Text(
                            unit,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _areaUnit = value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader('Details'),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    controller: _targetPestController,
                    decoration: const InputDecoration(
                      labelText: 'Target pest (optional)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _applicationMethod,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Application method',
                    ),
                    items: [
                      for (final method in RecordDraft.applicationMethods)
                        DropdownMenuItem(value: method, child: Text(method)),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _applicationMethod = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _stateController,
                    decoration: const InputDecoration(
                      labelText: 'State (e.g. FL)',
                      counterText: '',
                    ),
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 2,
                  ),
                  const SizedBox(height: 4),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Applied at'),
                    subtitle: Text(
                      DateFormat('yyyy-MM-dd HH:mm').format(_appliedAt),
                    ),
                    trailing: const Icon(Icons.edit_calendar),
                    onTap: _pickAppliedAt,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader('Voice'),
          _voicePanel(context),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _continue,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Continue'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 60,
            child: FilledButton.icon(
              onPressed: _initializing ? null : _toggleListening,
              style: _listening
                  ? FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                    )
                  : null,
              icon: _initializing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(_listening ? Icons.stop : Icons.mic),
              label: Text(
                _initializing
                    ? 'Starting microphone…'
                    : _listening
                        ? 'Listening… tap to stop'
                        : 'Tap to talk',
                style: const TextStyle(fontSize: 17),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _voicePanel(BuildContext context) {
    final error = _speechError;
    final idle =
        !_listening && _transcript == null && error == null;
    return Card(
      margin: EdgeInsets.zero,
      color: SpraylogTheme.brandSkySoft.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (idle)
              Row(
                children: [
                  Icon(
                    Icons.mic_none,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tap to talk below to dictate this record.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            if (error != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(error)),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    visualDensity: VisualDensity.compact,
                    onPressed: () =>
                        setState(() => _speechError = null),
                  ),
                ],
              ),
            if (_listening)
              Row(
                children: [
                  Icon(
                    Icons.mic,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      (_transcript ?? '').isEmpty
                          ? 'Listening…'
                          : _transcript!,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            if (!_listening && _transcript != null) ...[
              Text(
                _transcript!,
                style: const TextStyle(height: 1.4),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  FilledButton.tonal(
                    onPressed: _continue,
                    child: const Text('Use transcript'),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: _retry,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
