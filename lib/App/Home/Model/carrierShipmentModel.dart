/// Result of POST /tracking/createCarrierShipment — creates a real Fez
/// shipment for a material order and returns its waybill number. Fez has no
/// PDF label the way FedEx did; the waybill number is the sole identifier.
class CarrierShipmentResult {
  final bool success;
  final String message;
  final String? trackingId;
  final String? carrier;
  final String? carrierTrackingNumber;
  final String? serviceType;

  const CarrierShipmentResult({
    required this.success,
    required this.message,
    this.trackingId,
    this.carrier,
    this.carrierTrackingNumber,
    this.serviceType,
  });

  factory CarrierShipmentResult.fromJson(Map<String, dynamic> json) {
    final success = json['success'] == true;
    final rawData = json['data'];
    final data =
        rawData is Map ? Map<String, dynamic>.from(rawData) : const {};

    return CarrierShipmentResult(
      success: success,
      message:
          json['message']?.toString() ??
          (success
              ? 'Shipment created successfully'
              : 'Failed to create shipment'),
      trackingId: data['trackingId']?.toString(),
      carrier: data['carrier']?.toString(),
      carrierTrackingNumber:
          (data['carrierTrackingNumber'] ?? data['waybillNumber'])
              ?.toString(),
      serviceType: data['serviceType']?.toString(),
    );
  }

  bool get hasWaybill =>
      carrierTrackingNumber != null && carrierTrackingNumber!.isNotEmpty;
}
