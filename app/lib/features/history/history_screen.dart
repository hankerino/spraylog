import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import 'history_filters.dart';
import 'sync_status_chip.dart';

/// Local application records, newest first, with per-record sync state and
/// a client-side filter bar (works fully offline).
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _applicatorController = TextEditingController();
  final _customerController = TextEditingController();
  final _productController = TextEditingController();

  HistoryFilters _filters = const HistoryFilters();
  bool _filtersOpen = false;

  @override
  void dispose() {
    _applicatorController.dispose();
    _customerController.dispose();
    _productController.dispose();
    super.dispose();
  }

  void _apply() {
    setState(() {
      _filters = _filters.copyWith(
        applicator: _applicatorController.text,
        customer: _customerController.text,
        product: _productController.text,
      );
    });
  }

  void _clear() {
    setState(() {
      _applicatorController.clear();
      _customerController.clear();
      _productController.clear();
      _filters = const HistoryFilters();
    });
  }

  Future<void> _pickDate({required bool isStart}) async {
    final current = isStart ? _filters.start : _filters.end;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _filters = isStart
          ? _filters.copyWith(start: picked)
          : _filters.copyWith(end: picked);
    });
  }

  String _dateLabel(DateTime? value, String fallback) {
    return value == null ? fallback : DateFormat('yyyy-MM-dd').format(value);
  }

  @override
  Widget build(BuildContext context) {
    final applications = ref.watch(applicationsProvider);
    final pending = ref.watch(pendingOutboxProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: _filters.isEmpty
                  ? null
                  : Theme.of(context).colorScheme.primary,
            ),
            tooltip: 'Filters',
            onPressed: () => setState(() => _filtersOpen = !_filtersOpen),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_filtersOpen) _filterBar(context),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(applicationsProvider);
                ref.invalidate(pendingOutboxProvider);
              },
              child: applications.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (error, _) => ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('Failed to load records: $error'),
                    ),
                  ],
                ),
                data: (records) {
                  if (records.isEmpty) {
                    return ListView(
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              'No records yet. Record your first application.',
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  final filtered = applyHistoryFilters(records, _filters);
                  if (filtered.isEmpty) {
                    return ListView(
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(24),
                          child:
                              Center(child: Text('No records match the filters.')),
                        ),
                      ],
                    );
                  }
                  final pendingIds = {
                    for (final item in pending.valueOrNull ?? const [])
                      item.id,
                  };
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final record = filtered[index];
                      final isPending = pendingIds.contains(record.id);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(record.brandName),
                          subtitle: Text(
                            '${DateFormat('yyyy-MM-dd HH:mm').format(record.appliedAt.toLocal())} · ${record.state}',
                          ),
                          trailing: SyncStatusChip(
                            signed: record.signedAt != null,
                            pending: isPending,
                          ),
                          onTap: () => context.push('/history/${record.id}'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterBar(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDate(isStart: true),
                    icon: const Icon(Icons.date_range, size: 18),
                    label: Text(_dateLabel(_filters.start, 'Start')),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDate(isStart: false),
                    icon: const Icon(Icons.date_range, size: 18),
                    label: Text(_dateLabel(_filters.end, 'End')),
                  ),
                ),
                if (_filters.start != null || _filters.end != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    tooltip: 'Clear dates',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => setState(
                      () => _filters = _filters.copyWith(clearDates: true),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _applicatorController,
              decoration: const InputDecoration(
                labelText: 'Applicator',
                isDense: true,
              ),
              onChanged: (_) => _apply(),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _customerController,
              decoration: const InputDecoration(
                labelText: 'Customer',
                isDense: true,
              ),
              onChanged: (_) => _apply(),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _productController,
              decoration: const InputDecoration(
                labelText: 'Product',
                isDense: true,
              ),
              onChanged: (_) => _apply(),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _clear,
                child: const Text('Clear all'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
