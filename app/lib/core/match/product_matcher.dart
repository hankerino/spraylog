import '../../data/models/product.dart';

/// A catalogue entry with its match score (0..1).
class ProductMatch {
  const ProductMatch({required this.product, required this.score});

  final ProductModel product;
  final double score;
}

/// Outcome of a matcher run: [candidates] holds every entry scoring above
/// 0.5 (best first); [best] is the top candidate, but only when it clears
/// [matchThreshold] — below that nothing is forced on the user.
class ProductMatchResult {
  const ProductMatchResult({
    required this.best,
    required this.candidates,
    required this.topScore,
  });

  final ProductMatch? best;
  final List<ProductMatch> candidates;
  final double topScore;
}

/// Minimum score for a confident automatic match.
const matchThreshold = 0.75;

/// Deterministic voice/typo-tolerant matcher over the local catalogue.
/// Normalizes speak-spell forms ("two" → 2, "e w" → "ew"), then scores by
/// exact match, token-sort similarity on brand name and aliases, and a
/// prefix boost.
class ProductMatcher {
  const ProductMatcher._();

  static const _candidateFloor = 0.5;
  static const _prefixBoost = 0.85;
  static const _prefixMinLength = 3;

  static const _spokenNumbers = {
    'one': '1',
    'two': '2',
    'to': '2',
    'too': '2',
    'three': '3',
    'four': '4',
    'for': '4',
    'five': '5',
    'six': '6',
    'seven': '7',
    'eight': '8',
    'nine': '9',
  };

  static ProductMatchResult match(
    String query,
    List<ProductModel> catalogue,
  ) {
    final normalizedQuery = normalize(query);
    if (normalizedQuery.isEmpty || catalogue.isEmpty) {
      return const ProductMatchResult(
        best: null,
        candidates: [],
        topScore: 0,
      );
    }

    final scored = <ProductMatch>[];
    for (final product in catalogue) {
      final score = _score(normalizedQuery, product);
      if (score > _candidateFloor) {
        scored.add(ProductMatch(product: product, score: score));
      }
    }
    scored.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      return byScore != 0
          ? byScore
          : a.product.brandName.compareTo(b.product.brandName);
    });

    final topScore = scored.isEmpty ? 0.0 : scored.first.score;
    return ProductMatchResult(
      best: topScore >= matchThreshold ? scored.first : null,
      candidates: scored,
      topScore: topScore,
    );
  }

  static double _score(String normalizedQuery, ProductModel product) {
    final name = normalize(product.brandName);
    if (name.isEmpty) return 0;

    var score = _tokenSortRatio(normalizedQuery, name);
    if (normalizedQuery == name) score = 1.0;

    for (final alias in product.brandAliases) {
      final normalizedAlias = normalize(alias);
      if (normalizedAlias.isEmpty) continue;
      if (normalizedQuery == normalizedAlias) {
        score = 1.0;
        break;
      }
      final aliasScore = _tokenSortRatio(normalizedQuery, normalizedAlias);
      if (aliasScore > score) score = aliasScore;
    }

    // Prefix boost: "dimen" confidently means Dimension 2EW.
    final queryCompact = normalizedQuery.replaceAll(' ', '');
    final nameCompact = name.replaceAll(' ', '');
    if (queryCompact.length >= _prefixMinLength &&
        nameCompact.startsWith(queryCompact) &&
        score < _prefixBoost) {
      score = _prefixBoost;
    }

    return score;
  }

  /// Lowercase, alnum-only, collapsed spaces; expands spoken numbers and
  /// merges consecutive single-character tokens ("e w" → "ew",
  /// "s c" → "sc").
  static String normalize(String input) {
    final lowered = input.toLowerCase();
    final buffer = StringBuffer();
    for (final codeUnit in lowered.codeUnits) {
      final isDigit = codeUnit >= 0x30 && codeUnit <= 0x39;
      final isLetter = codeUnit >= 0x61 && codeUnit <= 0x7A;
      buffer.write(isDigit || isLetter ? String.fromCharCode(codeUnit) : ' ');
    }

    final rawTokens =
        buffer.toString().split(' ').where((token) => token.isNotEmpty);
    final tokens = [
      for (final token in rawTokens) _spokenNumbers[token] ?? token,
    ];

    final merged = <String>[];
    var i = 0;
    while (i < tokens.length) {
      if (tokens[i].length == 1) {
        final run = StringBuffer(tokens[i]);
        while (i + 1 < tokens.length && tokens[i + 1].length == 1) {
          i++;
          run.write(tokens[i]);
        }
        merged.add(run.toString());
      } else {
        merged.add(tokens[i]);
      }
      i++;
    }

    return merged.join(' ');
  }

  /// Levenshtein similarity over the token-sorted forms of both strings.
  static double _tokenSortRatio(String a, String b) {
    String sortTokens(String value) {
      final tokens = value.split(' ')..sort();
      return tokens.join(' ');
    }

    final sortedA = sortTokens(a);
    final sortedB = sortTokens(b);
    if (sortedA == sortedB) return 1.0;
    final maxLength =
        sortedA.length > sortedB.length ? sortedA.length : sortedB.length;
    if (maxLength == 0) return 1.0;
    return 1 - _levenshtein(sortedA, sortedB) / maxLength;
  }

  static int _levenshtein(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    var previous = List<int>.generate(b.length + 1, (index) => index);
    for (var i = 1; i <= a.length; i++) {
      final current = List<int>.filled(b.length + 1, 0);
      current[0] = i;
      for (var j = 1; j <= b.length; j++) {
        final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
        var value = previous[j] + 1;
        if (current[j - 1] + 1 < value) value = current[j - 1] + 1;
        if (previous[j - 1] + cost < value) value = previous[j - 1] + cost;
        current[j] = value;
      }
      previous = current;
    }
    return previous[b.length];
  }
}
