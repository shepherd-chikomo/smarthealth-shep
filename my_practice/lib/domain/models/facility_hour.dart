/// Facility operating hours (matches `/v1/facility/hours` API).
class FacilityHour {
  const FacilityHour({
    required this.dayOfWeek,
    this.opensAt,
    this.closesAt,
    this.isClosed = false,
    this.is24Hours = false,
  });

  final int dayOfWeek;
  final String? opensAt;
  final String? closesAt;
  final bool isClosed;
  final bool is24Hours;

  static const dayLabels = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  static List<FacilityHour> devDefaults() => [
        const FacilityHour(
          dayOfWeek: 0,
          isClosed: true,
        ),
        const FacilityHour(
          dayOfWeek: 1,
          opensAt: '07:30',
          closesAt: '18:00',
        ),
        const FacilityHour(
          dayOfWeek: 2,
          opensAt: '07:30',
          closesAt: '18:00',
        ),
        const FacilityHour(
          dayOfWeek: 3,
          opensAt: '07:30',
          closesAt: '18:00',
        ),
        const FacilityHour(
          dayOfWeek: 4,
          opensAt: '07:30',
          closesAt: '18:00',
        ),
        const FacilityHour(
          dayOfWeek: 5,
          opensAt: '07:30',
          closesAt: '18:00',
        ),
        const FacilityHour(
          dayOfWeek: 6,
          opensAt: '08:00',
          closesAt: '13:00',
        ),
      ];

  factory FacilityHour.fromJson(Map<String, dynamic> json) {
    return FacilityHour(
      dayOfWeek: (json['day_of_week'] ?? json['dayOfWeek'] as num).toInt(),
      opensAt: _time(json['opens_at'] ?? json['opensAt']),
      closesAt: _time(json['closes_at'] ?? json['closesAt']),
      isClosed: json['is_closed'] == true || json['isClosed'] == true,
      is24Hours: json['is_24_hours'] == true || json['is24Hours'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'dayOfWeek': dayOfWeek,
        'opensAt': opensAt,
        'closesAt': closesAt,
        'isClosed': isClosed,
        'is24Hours': is24Hours,
      };

  String get label => dayLabels[dayOfWeek.clamp(0, 6)];

  String get displayLine {
    if (isClosed) return '$label  Closed';
    if (is24Hours) return '$label  Open 24 hours';
    final open = _formatTime(opensAt);
    final close = _formatTime(closesAt);
    return '$label  $open – $close';
  }

  FacilityHour copyWith({
    int? dayOfWeek,
    String? opensAt,
    String? closesAt,
    bool? isClosed,
    bool? is24Hours,
  }) {
    return FacilityHour(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      opensAt: opensAt ?? this.opensAt,
      closesAt: closesAt ?? this.closesAt,
      isClosed: isClosed ?? this.isClosed,
      is24Hours: is24Hours ?? this.is24Hours,
    );
  }

  static String? _time(dynamic raw) {
    if (raw == null) return null;
    final s = raw.toString();
    if (s.length >= 5) return s.substring(0, 5);
    return s;
  }

  static String _formatTime(String? t) {
    if (t == null || t.isEmpty) return '—';
    return t.length >= 5 ? t.substring(0, 5) : t;
  }

  static List<FacilityHour> mergeWeek(List<FacilityHour> fromApi) {
    final byDay = {for (final h in fromApi) h.dayOfWeek: h};
    return List.generate(
      7,
      (i) => byDay[i] ?? FacilityHour(dayOfWeek: i, isClosed: true),
    );
  }
}
