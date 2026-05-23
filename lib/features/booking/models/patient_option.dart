import 'package:equatable/equatable.dart';

/// Self or a family member selectable for an appointment.
class PatientOption extends Equatable {
  const PatientOption({
    required this.id,
    required this.name,
    required this.relationship,
    this.isSelf = false,
  });

  final String id;
  final String name;
  final String relationship;
  final bool isSelf;

  static const selfId = 'self';

  static const self = PatientOption(
    id: selfId,
    name: 'Myself',
    relationship: 'Self',
    isSelf: true,
  );

  @override
  List<Object?> get props => [id, name, relationship, isSelf];
}
