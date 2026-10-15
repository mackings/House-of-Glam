/// A single tracking event returned by GET /tracking/carrier/:carrierTrackingNumber.
class CarrierTrackingEvent {
  final String status;
  final DateTime? timestamp;
  final String description;

  const CarrierTrackingEvent({
    required this.status,
    required this.timestamp,
    required this.description,
  });

  factory CarrierTrackingEvent.fromJson(Map<String, dynamic> json) {
    return CarrierTrackingEvent(
      status: (json['status'] ?? '').toString(),
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? ''),
      description: (json['description'] ?? '').toString(),
    );
  }
}

/// Live shipment tracking info for a Fez waybill, via
/// GET /tracking/carrier/:carrierTrackingNumber?carrier=fez.
class CarrierTrackingInfo {
  final String carrier;
  final String orderNumber;
  final String status;
  final String? statusDescription;
  final String? senderName;
  final String? senderAddress;
  final String? recipientName;
  final String? recipientAddress;
  final String? recipientState;
  final DateTime? createdAt;
  final String? proofOfDelivery;
  final List<CarrierTrackingEvent> events;

  const CarrierTrackingInfo({
    required this.carrier,
    required this.orderNumber,
    required this.status,
    this.statusDescription,
    this.senderName,
    this.senderAddress,
    this.recipientName,
    this.recipientAddress,
    this.recipientState,
    this.createdAt,
    this.proofOfDelivery,
    this.events = const [],
  });

  factory CarrierTrackingInfo.fromJson(Map<String, dynamic> json) {
    final rawEvents = (json['events'] as List?) ?? const [];
    return CarrierTrackingInfo(
      carrier: (json['carrier'] ?? 'fez').toString(),
      orderNumber: (json['orderNumber'] ?? json['trackingNumber'] ?? '')
          .toString(),
      status: (json['status'] ?? '').toString(),
      statusDescription: json['statusDescription']?.toString(),
      senderName: json['senderName']?.toString(),
      senderAddress: json['senderAddress']?.toString(),
      recipientName: json['recipientName']?.toString(),
      recipientAddress: json['recipientAddress']?.toString(),
      recipientState: json['recipientState']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      proofOfDelivery: json['proofOfDelivery']?.toString(),
      events:
          rawEvents
              .whereType<Map>()
              .map(
                (e) => CarrierTrackingEvent.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList(),
    );
  }

  bool get isDelivered => status.toUpperCase() == 'DELIVERED';

  /// A human-readable status label from statusDescription when available,
  /// falling back to a title-cased version of the raw status code
  /// (e.g. "IN_TRANSIT" -> "In Transit").
  String get displayStatus {
    if (statusDescription != null && statusDescription!.trim().isNotEmpty) {
      return statusDescription!;
    }
    if (status.isEmpty) return 'Unknown';
    return status
        .split('_')
        .map(
          (word) =>
              word.isEmpty
                  ? word
                  : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}

/// Result wrapper for the carrier tracking call — Fez/the backend reports
/// failures (e.g. wrong carrier query param, waybill not found) as non-2xx
/// responses with a `message`, surfaced here instead of throwing so the UI
/// can always show something concrete.
class CarrierTrackingResult {
  final CarrierTrackingInfo? info;
  final String? errorMessage;

  const CarrierTrackingResult({this.info, this.errorMessage});

  factory CarrierTrackingResult.fromJson(Map<String, dynamic> json) {
    final success = json['success'] == true;
    final rawData = json['data'];
    if (success && rawData is Map) {
      return CarrierTrackingResult(
        info: CarrierTrackingInfo.fromJson(Map<String, dynamic>.from(rawData)),
      );
    }
    return CarrierTrackingResult(
      errorMessage:
          json['message']?.toString() ?? 'Unable to fetch tracking info.',
    );
  }

  bool get hasInfo => info != null;
}
