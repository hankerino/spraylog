import 'package:flutter/material.dart';

import '../../core/match/product_matcher.dart';
import '../../data/models/product.dart';
import 'validation_client.dart';

/// Modal product picker: search field + matcher-scored list over the local
/// catalogue. When [preloaded] candidates are supplied (from the
/// validate-application function) and the search box is untouched, they are
/// shown instead of the catalogue. Pops with the selected [ProductModel],
/// or null when dismissed.
class ProductPickerSheet extends StatefulWidget {
  const ProductPickerSheet({
    required this.catalogue,
    this.initialQuery = '',
    this.preloaded = const [],
    super.key,
  });

  final List<ProductModel> catalogue;
  final String initialQuery;

  /// Server-ranked candidates shown before the user types a search.
  final List<PickerCandidate> preloaded;

  @override
  State<ProductPickerSheet> createState() => _ProductPickerSheetState();
}

class _ProductPickerSheetState extends State<ProductPickerSheet> {
  late final TextEditingController _search =
      TextEditingController(text: widget.initialQuery);
  late String _query = widget.initialQuery;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<ProductMatch> get _results {
    if (_query.trim().isEmpty) {
      return [
        for (final product in widget.catalogue)
          ProductMatch(product: product, score: 1),
      ];
    }
    return ProductMatcher.match(_query, widget.catalogue).candidates;
  }

  @override
  Widget build(BuildContext context) {
    final searching = _query.trim().isNotEmpty;
    final showPreloaded = !searching && widget.preloaded.isNotEmpty;
    final results = _results;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _search,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Search products',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            Flexible(
              child: showPreloaded
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.preloaded.length,
                      itemBuilder: (context, index) {
                        final candidate = widget.preloaded[index];
                        return ListTile(
                          title: Text(candidate.brandName),
                          subtitle: Text(
                            'EPA ${candidate.epaRegNo}'
                            ' · ${(candidate.score * 100).round()}%',
                          ),
                          onTap: () => Navigator.of(context).pop(
                            ProductModel(
                              id: candidate.productId,
                              epaRegNo: candidate.epaRegNo,
                              brandName: candidate.brandName,
                              updatedAt: DateTime.fromMillisecondsSinceEpoch(
                                0,
                                isUtc: true,
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : results.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(24),
                          child:
                              Text('No matching products in the catalogue.'),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final match = results[index];
                            final product = match.product;
                            return ListTile(
                              title: Text(product.brandName),
                              subtitle: Text(
                                'EPA ${product.epaRegNo}'
                                '${searching ? ' · ${(match.score * 100).round()}%' : ''}',
                              ),
                              onTap: () => Navigator.of(context).pop(product),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
