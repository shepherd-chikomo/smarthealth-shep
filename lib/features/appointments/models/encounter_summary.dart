class EncounterSummary {
  const EncounterSummary({
    required this.id,
    required this.consultationId,
    this.appointmentId,
    this.providerId,
    this.chiefComplaint,
    this.assessment,
    this.plan,
    this.prescriptionsSummary,
    required this.createdAt,
  });

  final String id;
  final String? appointmentId;
  final String consultationId;
  final String? providerId;
  final String? chiefComplaint;
  final String? assessment;
  final String? plan;
  final String? prescriptionsSummary;
  final DateTime createdAt;

  factory EncounterSummary.fromJson(Map<String, dynamic> json) {
    return EncounterSummary(
      id: json['id'] as String,
      appointmentId: json['appointmentId'] as String?,
      consultationId: json['consultationId'] as String,
      providerId: json['providerId'] as String?,
      chiefComplaint: json['chiefComplaint'] as String?,
      assessment: json['assessment'] as String?,
      plan: json['plan'] as String?,
      prescriptionsSummary: json['prescriptionsSummary'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    );
  }
}
