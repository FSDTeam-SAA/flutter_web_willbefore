class WarehouseAddress {
  final String? name;
  final String? street1;
  final String? city;
  final String? state;
  final String? zip;
  final String? country;
  final bool isResidential;

  WarehouseAddress({
    this.name,
    this.street1,
    this.city,
    this.state,
    this.zip,
    this.country,
    this.isResidential = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'street1': street1,
        'city': city,
        'state': state,
        'zip': zip,
        'country': country,
        'isResidential': isResidential,
      };

  factory WarehouseAddress.fromJson(Map<String, dynamic> json) => WarehouseAddress(
        name: json['name'] as String?,
        street1: json['street1'] as String?,
        city: json['city'] as String?,
        state: json['state'] as String?,
        zip: json['zip'] as String?,
        country: json['country'] as String?,
        isResidential: json['isResidential'] as bool? ?? false,
      );
}