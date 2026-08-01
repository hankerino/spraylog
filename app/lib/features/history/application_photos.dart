import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/widgets/section_header.dart';

/// Signed URLs (1h) for a record's photos. Online-only: the
/// `application_photos` read and URL signing both need connectivity; any
/// error resolves to an empty list so the strip hides silently.
final recordPhotoUrlsProvider =
    FutureProvider.family<List<String>, String>((ref, applicationId) async {
  final client = ref.watch(supabaseClientProvider);
  try {
    final rows = await client
        .from('application_photos')
        .select('storage_path')
        .eq('application_id', applicationId)
        .order('taken_at');
    return [
      for (final row in rows)
        await client.storage
            .from('application-photos')
            .createSignedUrl(row['storage_path'] as String, 3600),
    ];
  } catch (_) {
    return const [];
  }
});

/// "Photos" section (header + horizontal thumbnail strip) for a record;
/// hides entirely when there are no photos or they can't be loaded.
class RecordPhotosSection extends ConsumerWidget {
  const RecordPhotosSection({required this.applicationId, super.key});

  final String applicationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urls = ref.watch(recordPhotoUrlsProvider(applicationId));
    final photos = urls.valueOrNull ?? const <String>[];
    if (photos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const SectionHeader('Photos'),
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: photos.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                photos[index],
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
