import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/providers.dart';

/// Weather at the application site, from the fetch-weather edge function.
/// Every field is nullable — the function returns what it could read.
class WeatherReading {
  const WeatherReading({
    this.tempF,
    this.windMph,
    this.windDirection,
    this.weatherSource,
  });

  final double? tempF;
  final double? windMph;
  final String? windDirection;
  final String? weatherSource;

  factory WeatherReading.fromSnakeJson(Map<String, dynamic> json) {
    return WeatherReading(
      tempF: (json['temp_f'] as num?)?.toDouble(),
      windMph: (json['wind_mph'] as num?)?.toDouble(),
      windDirection: json['wind_direction'] as String?,
      weatherSource: json['weather_source'] as String?,
    );
  }
}

/// Client seam for the fetch-weather edge function. Callers treat any
/// throw as "weather unavailable" and leave the fields null.
abstract class WeatherClient {
  Future<WeatherReading> fetch(double lat, double lng);
}

class RemoteWeatherClient implements WeatherClient {
  const RemoteWeatherClient(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<WeatherReading> fetch(double lat, double lng) async {
    final response = await _supabase.functions.invoke(
      'fetch-weather',
      body: {'lat': lat, 'lng': lng},
    );
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw StateError('unexpected fetch-weather response');
    }
    return WeatherReading.fromSnakeJson(data);
  }
}

final weatherClientProvider = Provider<WeatherClient>(
  (ref) => RemoteWeatherClient(ref.watch(supabaseClientProvider)),
);
