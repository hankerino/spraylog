import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/hash/record_hash.dart';
import '../../core/providers.dart';
import '../../core/result.dart';
import '../../core/theme/spraylog_theme.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/application.dart';
import 'extraction_client.dart';
import 'record_draft.dart';
import 'record_validation.dart';

/// Read-only review of the draft; any field can be tapped to edit inline.
/// "Sign" hashes, persists, and enqueues the record for sync.
///
/// When the draft carries a voice [RecordDraft.transcript], extraction runs
/// on arrival; any failure (stub, offline, unsupported) leaves every field
/// manual with an inline hint.
class ConfirmScreen extends ConsumerStatefulWidget {
  const ConfirmScreen({required this.draft, super.key});

  final RecordDraft draft;

  @override
  ConsumerState<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends ConsumerState<ConfirmScreen> {
  late RecordDraft _draft = widget.draft;
  Map<String, String> _errors = const {};
  bool _signing = false;

  bool _extracting = false;
  bool _extractionUnavailable = false;
  bool _productNeedsManualPick = false;
  double? _extractionConfidence;
  ExtractionResult? _lastExtraction;

  @override
  void initState() {
    super.initState();
    final transcript = _draft.transcript;
    if (transcript != null && transcript.isNotEmpty) {
      _runExtraction(transcript);
    }
  }

  Future<void> _runExtraction(String transcript) async {
    setState(() => _extracting = true);
    try {
      final result =
          await ref.read(extractionClientProvider).extract(transcript);
      if (!mounted) return;
      setState(() => _applyExtraction(result));
    } catch (_) {
      // Stub, offline, unsupported — the manual path is the fallback.
      if (!mounted) return;
      setState(() => _extractionUnavailable = true);
    } finally {
      if (mounted) setState(() => _extracting = false);
    }
  }

  void _applyExtraction(ExtractionResult result) {
    _lastExtraction = result;
    _extractionConfidence = result.confidence;
    if (result.isLowConfidence) _productNeedsManualPick = true;

    var updated = _draft;
    final product = result.spokenProduct;
    if (product != null && product.isNotEmpty) {
      updated = updated.copyWith(brandName: product);
    }
    if (result.rateValue != null) {
      updated = updated.copyWith(rateValue: result.rateValue);
    }
    final rateUnit = result.rateUnit;
    if (rateUnit != null && RecordDraft.rateUnits.contains(rateUnit)) {
      updated = updated.copyWith(rateUnit: rateUnit);
    }
    if (result.areaValue != null) {
      updated = updated.copyWith(areaValue: result.areaValue);
    }
    final areaUnit = result.areaUnit;
    if (areaUnit != null && RecordDraft.areaUnits.contains(areaUnit)) {
      updated = updated.copyWith(areaUnit: areaUnit);
    }
    final pest = result.targetPest;
    if (pest != null && pest.isNotEmpty) {
      updated = updated.copyWith(targetPest: pest);
    }
    final method = result.applicationMethod;
    if (method != null && RecordDraft.applicationMethods.contains(method)) {
      updated = updated.copyWith(applicationMethod: method);
    }
    _draft = updated;
  }

  Future<void> _editText({
    required String title,
    required String initial,
    required ValueChanged<String> onSave,
    bool numeric = false,
  }) async {
    final controller = TextEditingController(text: initial);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: numeric
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) => Navigator.of(context).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null) onSave(result);
  }

  Future<void> _editChoice({
    required String title,
    required List<String> options,
    required ValueChanged<String> onSave,
  }) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(title),
        children: [
          for (final option in options)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(option),
              child: Text(option),
            ),
        ],
      ),
    );
    if (result != null) onSave(result);
  }

  Future<void> _editAppliedAt() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _draft.appliedAt,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_draft.appliedAt),
    );
    if (time == null || !mounted) return;
    setState(() {
      _draft = _draft.copyWith(
        appliedAt: DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        ),
      );
    });
  }

  Future<void> _sign() async {
    final errors = RecordValidation.validateDraft(_draft);
    setState(() => _errors = errors);
    if (errors.isNotEmpty) return;

    setState(() => _signing = true);
    try {
      final userId = ref.read(authStateProvider).valueOrNull?.userId;
      final profile = await ref.read(currentProfileProvider.future);
      if (userId == null || profile == null || profile.companyId.isEmpty) {
        _showError('No signed-in profile; cannot sign record.');
        return;
      }

      final repository = ref.read(applicationRepositoryProvider);
      final latest = await repository.latestSignedHash(profile.companyId);
      final prevHash = switch (latest) {
        Success(:final value) => value ?? genesisPrevHash,
        Failure() => genesisPrevHash,
      };

      final now = DateTime.now().toUtc();
      final transcript = _draft.transcript?.trim();
      var record = ApplicationModel(
        id: const Uuid().v4(),
        companyId: profile.companyId,
        applicatorId: userId,
        state: _draft.state.trim().toUpperCase(),
        appliedAt: _draft.appliedAt,
        productId: 'manual',
        epaRegNo: '',
        brandName: _draft.brandName.trim(),
        rateValue: _draft.rateValue!,
        rateUnit: _draft.rateUnit,
        areaValue: _draft.areaValue!,
        areaUnit: _draft.areaUnit,
        targetPest: _draft.targetPest.trim().isEmpty
            ? null
            : _draft.targetPest.trim(),
        applicationMethod: _draft.applicationMethod,
        transcript:
            transcript == null || transcript.isEmpty ? null : transcript,
        extractionConfidence: _extractionConfidence,
        signedAt: now,
        signedBy: userId,
        prevHash: prevHash,
      );
      final recordHash = computeRecordHash(
        canonicalPayload(record),
        prevHash,
      );
      record = record.copyWith(recordHash: recordHash);

      final saved = await repository.save(record);
      if (saved is Failure) {
        _showError(saved.error.message);
        return;
      }

      final enqueued = await ref.read(outboxServiceProvider).enqueue(
            id: record.id,
            entity: 'application',
            operation: 'insert',
            payload: jsonEncode(record.toSnakeJson()),
          );
      if (enqueued is Failure) {
        _showError(enqueued.error.message);
        return;
      }

      ref.invalidate(applicationsProvider);
      ref.invalidate(pendingOutboxProvider);
      if (mounted) context.go('/history/${record.id}');
    } finally {
      if (mounted) setState(() => _signing = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _field({
    required String label,
    required String value,
    String? error,
    String? warning,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: [
          Flexible(child: Text(label)),
          if (warning != null) ...[
            const SizedBox(width: 6),
            Icon(
              Icons.warning_amber,
              size: 18,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ],
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value.isEmpty ? '—' : value),
          if (warning != null)
            Text(
              warning,
              style: TextStyle(
                color: Theme.of(context).colorScheme.tertiary,
                fontSize: 12,
              ),
            ),
        ],
      ),
      subtitleTextStyle: error != null
          ? TextStyle(color: Theme.of(context).colorScheme.error)
          : null,
      trailing: const Icon(Icons.edit, size: 18),
      onTap: onTap,
      isThreeLine: error != null || warning != null,
      enabled: onTap != null,
    );
  }

  Widget _sectionCard(List<Widget> fields) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            for (var i = 0; i < fields.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              fields[i],
            ],
          ],
        ),
      ),
    );
  }

  Widget _transcriptCard(BuildContext context) {
    final transcript = _draft.transcript;
    if (transcript == null || transcript.isEmpty) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                Icons.mic_none,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'No voice transcript — record was entered manually.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Voice transcript',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(
              transcript,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            if (_extracting)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(),
              ),
            if (_extractionUnavailable)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Extraction unavailable — fill the fields manually.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              ),
            if (_lastExtraction != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Extraction confidence ${(_extractionConfidence! * 100).round()}%',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final extraction = _lastExtraction;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm record'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_errors.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _errors.values.join('\n'),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          const SectionHeader('Record'),
          _sectionCard([
            _field(
              label: 'Product brand name',
              value: _draft.brandName,
              error: _errors['brandName'],
              warning: _productNeedsManualPick
                  ? 'Low-confidence extraction — needs manual pick'
                  : null,
              onTap: () => _editText(
                title: 'Product brand name',
                initial: _draft.brandName,
                onSave: (value) =>
                    setState(() => _draft = _draft.copyWith(brandName: value)),
              ),
            ),
            _field(
              label: 'Rate',
              value: _draft.rateValue == null
                  ? ''
                  : '${_draft.rateValue} ${_draft.rateUnit}',
              error: _errors['rateValue'],
              onTap: () => _editText(
                title: 'Rate',
                initial: _draft.rateValue?.toString() ?? '',
                numeric: true,
                onSave: (value) => setState(
                  () => _draft = _draft.copyWith(
                    rateValue: double.tryParse(value.trim()),
                  ),
                ),
              ),
            ),
            _field(
              label: 'Rate unit',
              value: _draft.rateUnit,
              onTap: () => _editChoice(
                title: 'Rate unit',
                options: RecordDraft.rateUnits,
                onSave: (value) =>
                    setState(() => _draft = _draft.copyWith(rateUnit: value)),
              ),
            ),
            _field(
              label: 'Area treated',
              value: _draft.areaValue == null
                  ? ''
                  : '${_draft.areaValue} ${_draft.areaUnit}',
              error: _errors['areaValue'],
              onTap: () => _editText(
                title: 'Area treated',
                initial: _draft.areaValue?.toString() ?? '',
                numeric: true,
                onSave: (value) => setState(
                  () => _draft = _draft.copyWith(
                    areaValue: double.tryParse(value.trim()),
                  ),
                ),
              ),
            ),
            _field(
              label: 'Area unit',
              value: _draft.areaUnit,
              onTap: () => _editChoice(
                title: 'Area unit',
                options: RecordDraft.areaUnits,
                onSave: (value) =>
                    setState(() => _draft = _draft.copyWith(areaUnit: value)),
              ),
            ),
            _field(
              label: 'Target pest',
              value: _draft.targetPest,
              onTap: () => _editText(
                title: 'Target pest',
                initial: _draft.targetPest,
                onSave: (value) => setState(
                  () => _draft = _draft.copyWith(targetPest: value),
                ),
              ),
            ),
            _field(
              label: 'Application method',
              value: _draft.applicationMethod,
              onTap: () => _editChoice(
                title: 'Application method',
                options: RecordDraft.applicationMethods,
                onSave: (value) => setState(
                  () => _draft = _draft.copyWith(applicationMethod: value),
                ),
              ),
            ),
            _field(
              label: 'Applied at',
              value: DateFormat('yyyy-MM-dd HH:mm').format(_draft.appliedAt),
              onTap: _editAppliedAt,
            ),
          ]),
          const SizedBox(height: 20),
          const SectionHeader('Site & Weather'),
          _sectionCard([
            _field(
              label: 'State',
              value: _draft.state,
              error: _errors['state'],
              onTap: () => _editText(
                title: 'State (e.g. FL)',
                initial: _draft.state,
                onSave: (value) =>
                    setState(() => _draft = _draft.copyWith(state: value)),
              ),
            ),
            if (extraction?.siteHint != null)
              _field(label: 'Site', value: extraction!.siteHint!),
            if (extraction?.tempF != null)
              _field(label: 'Temp (F)', value: '${extraction!.tempF}'),
            if (extraction?.windMph != null ||
                extraction?.windDirection != null)
              _field(
                label: 'Wind',
                value: [
                  if (extraction!.windMph != null)
                    '${extraction.windMph} mph',
                  if (extraction.windDirection != null)
                    extraction.windDirection!,
                ].join(' '),
              ),
          ]),
          const SizedBox(height: 20),
          const SectionHeader('Extraction'),
          _transcriptCard(context),
          const SizedBox(height: 20),
          const SectionHeader('Sign-off'),
          Opacity(
            opacity: _signing ? 0.7 : 1,
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      SpraylogTheme.brandTurf,
                      SpraylogTheme.brandTurfDark,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _signing ? null : _sign,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_signing)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          else
                            const Icon(Icons.draw, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            _signing ? 'Signing…' : 'Sign',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Signing locks the record and chains its hash.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
