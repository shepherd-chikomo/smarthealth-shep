import 'package:smarthealth_shep/core/location/models/location_models.dart';
import 'package:smarthealth_shep/core/utils/haversine.dart';

/// Searchable catalog of major Zimbabwe cities for manual location entry.
abstract final class ZimbabweCities {
  static const all = <ZimbabweCity>[
    ZimbabweCity(name: 'Harare', latitude: -17.8252, longitude: 31.0335, province: 'Harare'),
    ZimbabweCity(name: 'Bulawayo', latitude: -20.1556, longitude: 28.5847, province: 'Bulawayo'),
    ZimbabweCity(name: 'Mutare', latitude: -18.9707, longitude: 32.6709, province: 'Manicaland'),
    ZimbabweCity(name: 'Gweru', latitude: -19.4500, longitude: 29.8167, province: 'Midlands'),
    ZimbabweCity(name: 'Masvingo', latitude: -20.0667, longitude: 30.8333, province: 'Masvingo'),
    ZimbabweCity(name: 'Kwekwe', latitude: -18.9286, longitude: 29.8149, province: 'Midlands'),
    ZimbabweCity(name: 'Kadoma', latitude: -18.3333, longitude: 29.9167, province: 'Mashonaland West'),
    ZimbabweCity(name: 'Chitungwiza', latitude: -18.0125, longitude: 31.0750, province: 'Harare'),
    ZimbabweCity(name: 'Marondera', latitude: -18.1890, longitude: 31.5512, province: 'Mashonaland East'),
    ZimbabweCity(name: 'Domboshava', latitude: -17.6247, longitude: 31.0714, province: 'Mashonaland East'),
    ZimbabweCity(name: 'Victoria Falls', latitude: -17.9318, longitude: 25.8307, province: 'Matabeleland North'),
    ZimbabweCity(name: 'Hwange', latitude: -18.3644, longitude: 26.5000, province: 'Matabeleland North'),
    ZimbabweCity(name: 'Chinhoyi', latitude: -17.3667, longitude: 30.2000, province: 'Mashonaland West'),
    ZimbabweCity(name: 'Rusape', latitude: -18.5278, longitude: 32.1281, province: 'Manicaland'),
    ZimbabweCity(name: 'Norton', latitude: -17.8833, longitude: 30.7000, province: 'Mashonaland West'),
    ZimbabweCity(name: 'Beitbridge', latitude: -22.2167, longitude: 30.0000, province: 'Matabeleland South'),
    ZimbabweCity(name: 'Kariba', latitude: -16.5167, longitude: 28.8000, province: 'Mashonaland West'),
    ZimbabweCity(name: 'Karoi', latitude: -16.8167, longitude: 29.6833, province: 'Mashonaland West'),
    ZimbabweCity(name: 'Bindura', latitude: -17.3019, longitude: 31.3306, province: 'Mashonaland Central'),
    ZimbabweCity(name: 'Zvishavane', latitude: -20.3269, longitude: 30.0665, province: 'Midlands'),
    ZimbabweCity(name: 'Redcliff', latitude: -19.0333, longitude: 29.7833, province: 'Midlands'),
    ZimbabweCity(name: 'Chegutu', latitude: -18.1300, longitude: 30.1400, province: 'Mashonaland West'),
    ZimbabweCity(name: 'Gokwe', latitude: -18.2047, longitude: 28.9347, province: 'Midlands'),
    ZimbabweCity(name: 'Chipinge', latitude: -20.1883, longitude: 32.6236, province: 'Manicaland'),
    ZimbabweCity(name: 'Shurugwi', latitude: -19.6667, longitude: 30.0000, province: 'Midlands'),
    ZimbabweCity(name: 'Epworth', latitude: -17.8900, longitude: 31.1475, province: 'Harare'),
  ];

  /// Case-insensitive search by city name or province.
  static List<ZimbabweCity> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return List.unmodifiable(all);

    return all
        .where(
          (city) =>
              city.name.toLowerCase().contains(q) ||
              (city.province?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }

  static ZimbabweCity? byName(String name) {
    final normalized = name.trim().toLowerCase();
    for (final city in all) {
      if (city.name.toLowerCase() == normalized) return city;
    }
    return null;
  }

  /// Closest catalog city to [lat]/[lon] by great-circle distance.
  static ZimbabweCity nearestTo(double lat, double lon) {
    ZimbabweCity nearest = all.first;
    var bestKm = double.infinity;
    for (final city in all) {
      final km = haversineDistanceKm(lat, lon, city.latitude, city.longitude);
      if (km < bestKm) {
        bestKm = km;
        nearest = city;
      }
    }
    return nearest;
  }
}
