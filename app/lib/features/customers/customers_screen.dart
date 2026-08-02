import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/result.dart';
import '../../data/models/customer.dart';
import '../../data/models/site.dart';
import '../../data/repositories/customers_repository.dart';
import '../record/record_draft.dart';

/// Customers & their sites. Direct remote access for now — offline cache
/// is a later concern, so this screen needs connectivity.
class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  final _searchController = TextEditingController();
  List<CustomerModel>? _customers;
  String? _error;
  int _refreshTick = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final result = await ref
        .read(customersRepositoryProvider)
        .list(query: _searchController.text);
    if (!mounted) return;
    setState(() {
      switch (result) {
        case Success(:final value):
          _customers = value;
          _error = null;
        case Failure(:final error):
          _error = error.message;
      }
    });
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _addCustomer() async {
    final profile = await ref.read(currentProfileProvider.future);
    if (profile == null || !mounted) return;
    final created = await showModalBottomSheet<CustomerModel>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CustomerForm(companyId: profile.companyId),
    );
    if (created != null) {
      _snack('Customer "${created.name}" added');
      _load();
    }
  }

  Future<void> _addSite(CustomerModel customer) async {
    final profile = await ref.read(currentProfileProvider.future);
    if (profile == null || !mounted) return;
    final created = await showModalBottomSheet<SiteModel>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _SiteForm(
        companyId: profile.companyId,
        customerId: customer.id,
      ),
    );
    if (created != null) {
      _snack('Site "${created.label}" added');
      setState(() => _refreshTick++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customers = _customers;
    final error = _error;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCustomer,
        icon: const Icon(Icons.person_add),
        label: const Text('Add customer'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search customers',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => _load(),
            ),
          ),
          Expanded(
            child: error != null
                ? Center(child: Text(error))
                : customers == null
                    ? const Center(child: CircularProgressIndicator())
                    : customers.isEmpty
                        ? const Center(
                            child: Text('No customers yet. Add your first.'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: customers.length,
                            itemBuilder: (context, index) {
                              final customer = customers[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ExpansionTile(
                                  leading: const Icon(Icons.person_outline),
                                  title: Text(customer.name),
                                  subtitle: Text(
                                    [
                                      if (customer.phone != null)
                                        customer.phone!,
                                      if (customer.email != null)
                                        customer.email!,
                                      if (customer.notifyVia != 'none')
                                        'notify: ${customer.notifyVia}',
                                      if (customer.smsCarrier != null)
                                        smsCarrierLabels[
                                                customer.smsCarrier] ??
                                            customer.smsCarrier!,
                                    ].join(' · '),
                                  ),
                                  children: [
                                    _SitesList(
                                      key: ValueKey(
                                        '${customer.id}:$_refreshTick',
                                      ),
                                      customerId: customer.id,
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: TextButton.icon(
                                        onPressed: () => _addSite(customer),
                                        icon: const Icon(Icons.add_location_alt),
                                        label: const Text('Add site'),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class _SitesList extends ConsumerWidget {
  const _SitesList({required this.customerId, super.key});

  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Result<List<SiteModel>>>(
      future: ref.read(customersRepositoryProvider).listSites(customerId),
      builder: (context, snapshot) {
        final result = snapshot.data;
        if (result == null) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (result is Failure<List<SiteModel>>) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(result.error.message),
          );
        }
        final sites = (result as Success<List<SiteModel>>).value;
        if (sites.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('No sites yet.'),
            ),
          );
        }
        return Column(
          children: [
            for (final site in sites)
              ListTile(
                dense: true,
                leading: const Icon(Icons.place_outlined),
                title: Text(site.label),
                subtitle: Text(
                  [
                    if (site.address != null) site.address!,
                    if (site.state != null) site.state!,
                    if (site.areaValue != null)
                      '${site.areaValue} ${site.areaUnit ?? ''}',
                  ].join(' · '),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CustomerForm extends ConsumerStatefulWidget {
  const _CustomerForm({required this.companyId});

  final String companyId;

  @override
  ConsumerState<_CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends ConsumerState<_CustomerForm> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  String _notifyVia = 'none';
  String? _smsCarrier;
  bool _busy = false;
  String? _error;

  bool get _carrierVisible =>
      _notifyVia == 'sms' || _phone.text.trim().isNotEmpty;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Name is required');
      return;
    }
    if (_notifyVia == 'sms' && _smsCarrier == null) {
      setState(() => _error = 'Carrier is required for SMS notices');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref.read(customersRepositoryProvider).addCustomer(
          companyId: widget.companyId,
          name: _name.text,
          phone: _phone.text,
          email: _email.text,
          notifyVia: _notifyVia,
          smsCarrier: _smsCarrier,
        );
    if (!mounted) return;
    switch (result) {
      case Success(:final value):
        Navigator.of(context).pop(value);
      case Failure(:final error):
        setState(() {
          _busy = false;
          _error = error.message;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: [
            Text('Add customer',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phone,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _notifyVia,
              decoration: const InputDecoration(labelText: 'Notify via'),
              items: const [
                DropdownMenuItem(value: 'none', child: Text('none')),
                DropdownMenuItem(value: 'sms', child: Text('sms')),
                DropdownMenuItem(value: 'email', child: Text('email')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _notifyVia = value);
              },
            ),
            if (_carrierVisible) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _smsCarrier,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Mobile carrier (for SMS notices)',
                  hintText: 'Needed for free SMS delivery',
                ),
                items: [
                  for (final entry in smsCarrierLabels.entries)
                    DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                ],
                onChanged: (value) => setState(() => _smsCarrier = value),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : _save,
              child: Text(_busy ? 'Saving…' : 'Save customer'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SiteForm extends ConsumerStatefulWidget {
  const _SiteForm({required this.companyId, required this.customerId});

  final String companyId;
  final String customerId;

  @override
  ConsumerState<_SiteForm> createState() => _SiteFormState();
}

class _SiteFormState extends ConsumerState<_SiteForm> {
  final _label = TextEditingController();
  final _address = TextEditingController();
  final _state = TextEditingController();
  final _areaValue = TextEditingController();
  String _areaUnit = RecordDraft.areaUnits.first;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _label.dispose();
    _address.dispose();
    _state.dispose();
    _areaValue.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_label.text.trim().isEmpty) {
      setState(() => _error = 'Label is required');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref.read(customersRepositoryProvider).addSite(
          companyId: widget.companyId,
          customerId: widget.customerId,
          label: _label.text,
          address: _address.text,
          state: _state.text,
          areaValue: double.tryParse(_areaValue.text.trim()),
          areaUnit: _areaUnit,
        );
    if (!mounted) return;
    switch (result) {
      case Success(:final value):
        Navigator.of(context).pop(value);
      case Failure(:final error):
        setState(() {
          _busy = false;
          _error = error.message;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: [
            Text('Add site', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _label,
              decoration:
                  const InputDecoration(labelText: 'Label (e.g. Front lawn)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _address,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _state,
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
                  child: TextField(
                    controller: _areaValue,
                    decoration: const InputDecoration(labelText: 'Area'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _areaUnit,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Area unit'),
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
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : _save,
              child: Text(_busy ? 'Saving…' : 'Save site'),
            ),
          ],
        ),
      ),
    );
  }
}
