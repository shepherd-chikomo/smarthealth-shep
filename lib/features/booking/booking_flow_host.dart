import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthealth_shep/features/booking/bloc/booking_bloc.dart';
import 'package:smarthealth_shep/features/booking/data/booking_repository.dart';
import 'package:smarthealth_shep/features/booking/screens/booking_date_screen.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';

/// Hosts the booking flow [BookingBloc] and starts at the date screen.
class BookingFlowHost extends StatelessWidget {
  const BookingFlowHost({
    super.key,
    required this.providerId,
    this.provider,
    this.repository,
    this.facilityId,
    this.serviceId,
  });

  final String providerId;
  final ProviderModel? provider;
  final BookingRepository? repository;
  final String? facilityId;
  final String? serviceId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookingBloc(
        providerId: providerId,
        repository: repository,
        facilityId: facilityId,
        serviceId: serviceId,
      ),
      child: BookingDateScreen(),
    );
  }
}
