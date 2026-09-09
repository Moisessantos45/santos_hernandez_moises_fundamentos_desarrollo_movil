class Booking {
  final String fullName;
  final String email;
  final String destination;
  final String transport;
  final List<String> extras;
  final bool receiveNotifications;
  final double budget;
  final DateTime? travelDate;
  final String? tripImageUrl;

  const Booking({
    required this.fullName,
    required this.email,
    required this.destination,
    required this.transport,
    required this.extras,
    required this.receiveNotifications,
    required this.budget,
    required this.travelDate,
    this.tripImageUrl,
  });

  Booking copyWith({
    String? fullName,
    String? email,
    String? destination,
    String? transport,
    List<String>? extras,
    bool? receiveNotifications,
    double? budget,
    DateTime? travelDate,
    String? tripImageUrl,
  }) {
    return Booking(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      destination: destination ?? this.destination,
      transport: transport ?? this.transport,
      extras: extras ?? this.extras,
      receiveNotifications: receiveNotifications ?? this.receiveNotifications,
      budget: budget ?? this.budget,
      travelDate: travelDate ?? this.travelDate,
      tripImageUrl: tripImageUrl ?? this.tripImageUrl,
    );
  }

  String get formattedDate {
    if (travelDate == null) return '';
    final day = travelDate!.day.toString().padLeft(2, '0');
    final month = travelDate!.month.toString().padLeft(2, '0');
    final year = travelDate!.year.toString();

    return '$day/$month/$year';
  }

  String get formattedExtras {
    if (extras.isEmpty) return 'Ninguno';
    return extras.join(', ');
  }
}
