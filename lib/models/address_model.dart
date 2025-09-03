class AddressModel {
  final String id;
  final String userId;
  final String name;
  final String phoneNumber;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String pincode;
  final String landmark;
  final AddressType type;
  final bool isDefault;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime? updatedAt;

  AddressModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.phoneNumber,
    required this.addressLine1,
    this.addressLine2 = '',
    required this.city,
    required this.state,
    required this.pincode,
    this.landmark = '',
    this.type = AddressType.home,
    this.isDefault = false,
    this.latitude,
    this.longitude,
    required this.createdAt,
    this.updatedAt,
  });

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      addressLine1: map['addressLine1'] ?? '',
      addressLine2: map['addressLine2'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      pincode: map['pincode'] ?? '',
      landmark: map['landmark'] ?? '',
      type: AddressType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => AddressType.home,
      ),
      isDefault: map['isDefault'] ?? false,
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'id': id,
      'userId': userId,
      'name': name,
      'phoneNumber': phoneNumber,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'pincode': pincode,
      'landmark': landmark,
      'type': type.name,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };

    // Only add latitude/longitude if they are not null
    if (latitude != null) {
      map['latitude'] = latitude;
    }
    if (longitude != null) {
      map['longitude'] = longitude;
    }

    return map;
  }

  Map<String, dynamic> toCreateMap() {
    final map = {
      'userId': userId,
      'name': name,
      'phoneNumber': phoneNumber,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'pincode': pincode,
      'landmark': landmark,
      'type': type.name,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };

    // Only add latitude/longitude if they are not null
    if (latitude != null) {
      map['latitude'] = latitude;
    }
    if (longitude != null) {
      map['longitude'] = longitude;
    }

    return map;
  }

  String get fullAddress {
    String address = addressLine1;
    if (addressLine2.isNotEmpty) address += ', $addressLine2';
    if (landmark.isNotEmpty) address += ', $landmark';
    address += ', $city, $state - $pincode';
    return address;
  }

  String get typeDisplayName {
    switch (type) {
      case AddressType.home:
        return 'Home';
      case AddressType.work:
        return 'Work';
      case AddressType.other:
        return 'Other';
    }
  }
}

enum AddressType { home, work, other }

extension AddressModelCopyWith on AddressModel {
  AddressModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? phoneNumber,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? pincode,
    String? landmark,
    AddressType? type,
    bool? isDefault,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      landmark: landmark ?? this.landmark,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
