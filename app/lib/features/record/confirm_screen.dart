import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/hash/record_hash.dart';
import '../../core/providers.dart';
import '../../core/result.dart';
import '../../data/models/application.dart';
import 'record_draft.dart';
import 'record_validation.dart';

/// Read-only review of the draft; any field can be tapped to edit inline.
/// "Sign" hashes, persists, and enqueues the record for sync.
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
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(value.isEmpty ? '—' : value),
      subtitleTextStyle: error != null
          ? TextStyle(color: Theme.of(context).colorScheme.error)
          : null,
      trailing: const Icon(Icons.edit, size: 18),
      onTap: onTap,
      isThreeLine: error != null,
      enabled: onTap != null,
    );
  }

  @override
  Widget build(BuildContext context) {
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
          _field(
            label: 'Product brand name',
            value: _draft.brandName,
            error: _errors['brandName'],
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
              onSave: (value) =>
                  setState(() => _draft = _draft.copyWith(targetPest: value)),
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
          _field(
            label: 'Applied at',
            value: DateFormat('yyyy-MM-dd HH:mm').format(_draft.appliedAt),
            onTap: _editAppliedAt,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _signing ? null : _sign,
            icon: _signing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.draw),
            label: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(_signing ? 'Signing…' : 'Sign'),
            ),
          ),
        ],
      ),
    );
  }
}
