import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/hash/record_hash.dart';
import '../../core/match/product_matcher.dart';
import '../../core/providers.dart';
import '../../core/result.dart';
import '../../core/sync/catalogue_sync.dart';
import '../../core/sync/photo_uploader.dart';
import '../../core/theme/spraylog_theme.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/application.dart';
import '../../data/models/product.dart';
import 'extraction_client.dart';
import 'product_picker_sheet.dart';
import 'record_draft.dart';
import 'record_validation.dart';
import 'validation_client.dart';
import 'weather_client.dart';

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

  ValidationOutcome? _validation;
  bool _validating = false;
  final _overrideController = TextEditingController();

  @override
  void dispose() {
    _overrideController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final transcript = _draft.transcript;
    if (transcript != null && transcript.isNotEmpty) {
      _runExtraction(transcript);
    }
    _autofillLocation();
    _runValidation();
  }

  /// Best-effort GPS autofill: any failure (denied permission, service
  /// off, no fix indoors) simply leaves lat/lng null.
  Future<void> _autofillLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _draft = _draft.copyWith(
          lat: position.latitude,
          lng: position.longitude,
        );
      });
      await _fetchWeather();
    } catch (_) {
      // Silent by design — offline/no-permission is normal in the field.
    }
  }

  /// Weather for the resolved coordinates; any error leaves the fields
  /// null silently.
  Future<void> _fetchWeather() async {
    final lat = _draft.lat;
    final lng = _draft.lng;
    if (lat == null || lng == null) return;
    try {
      final reading = await ref.read(weatherClientProvider).fetch(lat, lng);
      if (!mounted) return;
      setState(() {
        _draft = _draft.copyWith(
          tempF: reading.tempF,
          windMph: reading.windMph,
          windDirection: reading.windDirection,
          weatherSource: reading.weatherSource,
        );
      });
    } catch (_) {
      // Offline/function error: weather stays null.
    }
  }

  /// Authoritative product/rate resolve via the validate-application
  /// function. Runs when brandName + state are present; any error is
  /// swallowed (manual path and the local matcher picker stay available).
  Future<void> _runValidation({bool openPickerOnMiss = true}) async {
    if (_draft.brandName.trim().isEmpty ||
        _draft.state.trim().length != 2) {
      return;
    }
    setState(() => _validating = true);
    try {
      final outcome =
          await ref.read(validationClientProvider).validate(_draft);
      if (!mounted) return;
      setState(() => _applyValidation(outcome));
      if (!outcome.matched && openPickerOnMiss && mounted) {
        final catalogue =
            ref.read(productsCatalogueProvider).valueOrNull ?? const [];
        await _pickProduct(catalogue, preloaded: outcome.pickerCandidates);
      }
    } catch (_) {
      // Offline/function error: never block the manual path.
    } finally {
      if (mounted) setState(() => _validating = false);
    }
  }

  void _applyValidation(ValidationOutcome outcome) {
    _validation = outcome;
    if (outcome.matched) {
      _draft = _draft.copyWith(
        brandName: outcome.brandName ?? _draft.brandName,
        productId: outcome.productId,
        epaRegNo: outcome.epaRegNo,
        signalWord: outcome.signalWord,
      );
      _productNeedsManualPick = false;
    }
  }

  Future<void> _attachPhoto() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
        imageQuality: 70,
      );
      if (picked == null || !mounted) return;
      setState(() {
        _draft = _draft.copyWith(
          photoPaths: [...?_draft.photoPaths, picked.path],
        );
      });
    } catch (_) {
      // Camera unavailable/denied: photos are optional, stay silent.
    }
  }

  Future<void> _runExtraction(String transcript) async {
    setState(() => _extracting = true);
    try {
      final result =
          await ref.read(extractionClientProvider).extract(transcript);
      if (!mounted) return;
      setState(() => _applyExtraction(result));
      // Resolve whatever the extraction prefilled.
      await _runValidation();
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

  /// True when the product needs a catalogue pick: extraction flagged low
  /// confidence, or the current text scores below [matchThreshold] against
  /// a non-empty local catalogue. Already-resolved products (picker or
  /// validate-application) never need a pick.
  bool _needsProductPick(List<ProductModel>? catalogue) {
    if (_draft.productId != null) return false;
    if (_productNeedsManualPick) return true;
    if (catalogue == null || catalogue.isEmpty) return false;
    final brand = _draft.brandName.trim();
    if (brand.isEmpty) return false;
    return ProductMatcher.match(brand, catalogue).topScore < matchThreshold;
  }

  Future<void> _pickProduct(
    List<ProductModel> catalogue, {
    List<PickerCandidate> preloaded = const [],
  }) async {
    // Free-text fallback stays as-is when nothing can be listed.
    if (catalogue.isEmpty && preloaded.isEmpty) return;
    final selected = await showModalBottomSheet<ProductModel>(
      context: context,
      isScrollControlled: true,
      builder: (context) => ProductPickerSheet(
        catalogue: catalogue,
        initialQuery: _draft.brandName,
        preloaded: preloaded,
      ),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _draft = _draft.copyWith(
        brandName: selected.brandName,
        productId: selected.id,
        epaRegNo: selected.epaRegNo,
      );
      _productNeedsManualPick = false;
    });
    // Re-resolve the picked product (rate flag depends on it), but don't
    // bounce the user straight back into the picker on a miss.
    await _runValidation(openPickerOnMiss: false);
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

    final rateFlag = _validation?.rateFlag;
    final overrideReason = _overrideController.text.trim();
    if (!RecordValidation.canSign(
      rateFlag: rateFlag,
      overrideReason: overrideReason,
    )) {
      _showError('Override reason required to sign a flagged record.');
      return;
    }

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
        productId: _draft.productId ?? 'manual',
        epaRegNo: _draft.epaRegNo ?? '',
        brandName: _draft.brandName.trim(),
        rateValue: _draft.rateValue!,
        rateUnit: _draft.rateUnit,
        areaValue: _draft.areaValue!,
        areaUnit: _draft.areaUnit,
        targetPest: _draft.targetPest.trim().isEmpty
            ? null
            : _draft.targetPest.trim(),
        applicationMethod: _draft.applicationMethod,
        lat: _draft.lat,
        lng: _draft.lng,
        tempF: _draft.tempF,
        windMph: _draft.windMph,
        windDirection: _draft.windDirection,
        weatherSource: _draft.weatherSource,
        rateFlag: rateFlag,
        overrideReason: overrideReason.isEmpty ? null : overrideReason,
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

      final photos = _draft.photoPaths;
      if (photos != null && photos.isNotEmpty) {
        // Fire-and-forget: uploads happen online at sign time only and a
        // failed photo never blocks the record. Offline photo sync via
        // the outbox is a follow-up; files stay on device until then.
        unawaited(
          ref.read(photoUploaderProvider).upload(
                companyId: profile.companyId,
                applicationId: record.id,
                filePaths: photos,
                lat: _draft.lat,
                lng: _draft.lng,
              ),
        );
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

  Widget _flagBanner(String message) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.flag, size: 18, color: scheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: scheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }

  /// "87°F · wind 4 mph WNW · openweathermap" from the draft's weather
  /// fields, or null when nothing was autofilled.
  String? _weatherSummary() {
    final parts = <String>[
      if (_draft.tempF != null) '${_draft.tempF!.round()}°F',
      if (_draft.windMph != null || _draft.windDirection != null)
        'wind'
        '${_draft.windMph != null ? ' ${_draft.windMph!.round()} mph' : ''}'
        '${_draft.windDirection != null ? ' ${_draft.windDirection}' : ''}',
      if (_draft.weatherSource != null) _draft.weatherSource!,
    ];
    return parts.isEmpty ? null : parts.join(' · ');
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
    final catalogue = ref.watch(productsCatalogueProvider).valueOrNull;
    final catalogueReady = catalogue != null && catalogue.isNotEmpty;
    final needsPick = _needsProductPick(catalogue);
    final productWarning = !needsPick
        ? null
        : _productNeedsManualPick
            ? 'Low-confidence extraction — needs manual pick'
            : 'Not matched in the catalogue — pick a product';
    final validation = _validation;
    final rateFlag = validation?.rateFlag;
    final resolved = validation?.matched == true && _draft.productId != null;
    final canSign = RecordValidation.canSign(
      rateFlag: rateFlag,
      overrideReason: _overrideController.text,
    );
    final weatherSummary = _weatherSummary();
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
              warning: productWarning,
              onTap: () => _editText(
                title: 'Product brand name',
                initial: _draft.brandName,
                onSave: (value) {
                  setState(() => _draft = _draft.copyWith(brandName: value));
                  _runValidation();
                },
              ),
            ),
            if (_validating)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('Validating product…', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            if (resolved && !_validating)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 18,
                      color: SpraylogTheme.brandTurf,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Resolved: ${_draft.brandName} · EPA ${_draft.epaRegNo}'
                        '${_draft.signalWord != null ? ' · ${_draft.signalWord}' : ''}',
                        style: const TextStyle(
                          color: SpraylogTheme.brandTurfDark,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (needsPick && catalogueReady)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: OutlinedButton.icon(
                  onPressed: () => _pickProduct(catalogue),
                  icon: const Icon(Icons.search),
                  label: const Text('Pick product'),
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
                onSave: (value) {
                  setState(
                    () => _draft = _draft.copyWith(
                      rateValue: double.tryParse(value.trim()),
                    ),
                  );
                  _runValidation();
                },
              ),
            ),
            if (rateFlag == 'over_label')
              _flagBanner(
                'Above label maximum'
                '${validation?.rateMaxValue != null ? ' (${validation!.rateMaxValue} ${validation.rateMaxUnit ?? ''})' : ''}',
              ),
            _field(
              label: 'Rate unit',
              value: _draft.rateUnit,
              onTap: () => _editChoice(
                title: 'Rate unit',
                options: RecordDraft.rateUnits,
                onSave: (value) {
                  setState(() => _draft = _draft.copyWith(rateUnit: value));
                  _runValidation();
                },
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
                onSave: (value) {
                  setState(() => _draft = _draft.copyWith(state: value));
                  _runValidation();
                },
              ),
            ),
            if (rateFlag == 'unregistered_in_state')
              _flagBanner('Not registered in ${_draft.state.trim().toUpperCase()}'),
            if (weatherSummary != null)
              _field(label: 'Weather', value: weatherSummary),
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
          if (rateFlag != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: _overrideController,
                decoration: const InputDecoration(
                  labelText: 'Override reason (required)',
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          if ((_draft.photoPaths ?? []).isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                height: 64,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _draft.photoPaths!.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_draft.photoPaths![index]),
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OutlinedButton.icon(
              onPressed: _attachPhoto,
              icon: const Icon(Icons.photo_camera),
              label: Text(
                (_draft.photoPaths ?? []).isEmpty
                    ? 'Attach photo'
                    : 'Attach another photo',
              ),
            ),
          ),
          Opacity(
            opacity: (_signing || !canSign) ? 0.7 : 1,
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
                    onTap: (_signing || !canSign) ? null : _sign,
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
