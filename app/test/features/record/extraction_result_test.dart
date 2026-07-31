import 'package:flutter_test/flutter_test.dart';
import 'package:spraylog/features/record/extraction_client.dart';

void main() {
  test('ExtractionResult JSON round-trips all fields', () {
    const result = ExtractionResult(
      confidence: 0.92,
      spokenProduct: 'Roundup ProMax',
      rateValue: 1.5,
      rateUnit: 'oz_per_1000sqft',
      areaValue: 5000,
      areaUnit: 'sqft',
      targetPest: 'crabgrass',
      applicationMethod: 'broadcast',
      siteHint: 'front lawn',
      tempF: 84,
      windMph: 6.5,
      windDirection: 'NW',
      unparsedRemainder: 'near the mailbox',
    );

    final decoded = ExtractionResult.fromJson(result.toJson());

    expect(decoded.confidence, result.confidence);
    expect(decoded.spokenProduct, result.spokenProduct);
    expect(decoded.rateValue, result.rateValue);
    expect(decoded.rateUnit, result.rateUnit);
    expect(decoded.areaValue, result.areaValue);
    expect(decoded.areaUnit, result.areaUnit);
    expect(decoded.targetPest, result.targetPest);
    expect(decoded.applicationMethod, result.applicationMethod);
    expect(decoded.siteHint, result.siteHint);
    expect(decoded.tempF, result.tempF);
    expect(decoded.windMph, result.windMph);
    expect(decoded.windDirection, result.windDirection);
    expect(decoded.unparsedRemainder, result.unparsedRemainder);
  });

  test('ExtractionResult round-trips a confidence-only payload', () {
    final decoded = ExtractionResult.fromJson(
      const ExtractionResult(confidence: 0.3).toJson(),
    );

    expect(decoded.confidence, 0.3);
    expect(decoded.spokenProduct, isNull);
    expect(decoded.rateValue, isNull);
    expect(decoded.unparsedRemainder, isNull);
  });

  test('ExtractionResult parses snake_case JSON from the edge function', () {
    final decoded = ExtractionResult.fromJson(const {
      'confidence': 0.81,
      'spoken_product': 'Speedzone',
      'rate_value': 1.1,
      'rate_unit': 'oz_per_1000sqft',
      'temp_f': 77,
      'wind_mph': 4,
      'wind_direction': 'S',
    });

    expect(decoded.confidence, 0.81);
    expect(decoded.spokenProduct, 'Speedzone');
    expect(decoded.rateValue, 1.1);
    expect(decoded.tempF, 77);
    expect(decoded.windMph, 4.0);
    expect(decoded.areaValue, isNull);
  });

  test('confidence gate flags anything below 0.75', () {
    expect(
      const ExtractionResult(confidence: 0.74).isLowConfidence,
      isTrue,
    );
    expect(
      const ExtractionResult(confidence: 0.75).isLowConfidence,
      isFalse,
    );
    expect(
      const ExtractionResult(confidence: 0.9).isLowConfidence,
      isFalse,
    );
  });
}
