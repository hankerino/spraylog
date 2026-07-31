import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'record_draft.dart';

/// Manual entry form for a new application record. Best-effort parsing —
/// full validation happens on the confirm screen.
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

  void _continue() {
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
          TextField(
            controller: _brandNameController,
            decoration: const InputDecoration(
              labelText: 'Product brand name',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _rateValueController,
                  decoration: const InputDecoration(
                    labelText: 'Rate',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _rateUnit,
                  decoration: const InputDecoration(
                    labelText: 'Rate unit',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final unit in RecordDraft.rateUnits)
                      DropdownMenuItem(value: unit, child: Text(unit)),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _rateUnit = value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _areaValueController,
                  decoration: const InputDecoration(
                    labelText: 'Area treated',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _areaUnit,
                  decoration: const InputDecoration(
                    labelText: 'Area unit',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final unit in RecordDraft.areaUnits)
                      DropdownMenuItem(value: unit, child: Text(unit)),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _areaUnit = value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _targetPestController,
            decoration: const InputDecoration(
              labelText: 'Target pest (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _applicationMethod,
            decoration: const InputDecoration(
              labelText: 'Application method',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final method in RecordDraft.applicationMethods)
                DropdownMenuItem(value: method, child: Text(method)),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _applicationMethod = value);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _stateController,
            decoration: const InputDecoration(
              labelText: 'State (e.g. FL)',
              border: OutlineInputBorder(),
              counterText: '',
            ),
            textCapitalization: TextCapitalization.characters,
            maxLength: 2,
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Applied at'),
            subtitle: Text(
              DateFormat('yyyy-MM-dd HH:mm').format(_appliedAt),
            ),
            trailing: const Icon(Icons.edit_calendar),
            onTap: _pickAppliedAt,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _continue,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}
