import 'cart_model.dart';
import 'address_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<CartItem> items;
  final AddressModel deliveryAddress;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final DateTime orderDate;
  final DateTime? estimatedDelivery;
  final DateTime? deliveredAt;
  final String? notes;
  final String? trackingId;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.deliveryAddress,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    this.status = OrderStatus.placed,
    this.paymentMethod = PaymentMethod.cashOnDelivery,
    required this.orderDate,
    this.estimatedDelivery,
    this.deliveredAt,
    this.notes,
    this.trackingId,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return OrderModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      items: (map['items'] as List<dynamic>?)
          ?.map((item) => CartItem.fromMap(item))
          .toList()
          ?? [],
      deliveryAddress: AddressModel.fromMap(map['deliveryAddress']),
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
      deliveryFee: (map['deliveryFee'] ?? 0.0).toDouble(),
      total: (map['total'] ?? 0.0).toDouble(),
      status: OrderStatus.values.firstWhere(
            (e) => e.toString() == 'OrderStatus.${map['status']}',
        orElse: () => OrderStatus.placed,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
            (e) => e.toString() == 'PaymentMethod.${map['paymentMethod']}',
        orElse: () => PaymentMethod.cashOnDelivery,
      ),
      orderDate: parseDate(map['orderDate']) ?? DateTime.now(),
      estimatedDelivery: parseDate(map['estimatedDelivery']),
      deliveredAt: parseDate(map['deliveredAt']),
      notes: map['notes'],
      trackingId: map['trackingId'],
    );
  }


  Map<String, dynamic> toCreateMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'deliveryAddress': deliveryAddress.toMap(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'status': status.name,
      'paymentMethod': paymentMethod.name,
      'orderDate': orderDate.toIso8601String(),
      'estimatedDelivery': estimatedDelivery?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'notes': notes,
      'trackingId': trackingId,
    };
  }


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'deliveryAddress': deliveryAddress.toMap(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'status': status.name,
      'paymentMethod': paymentMethod.name,
      'orderDate': orderDate.toIso8601String(),
      'estimatedDelivery': estimatedDelivery?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'notes': notes,
      'trackingId': trackingId,
    };
  }

  String get statusDisplayName {
    switch (status) {
      case OrderStatus.placed:
        return 'Order Placed';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.packed:
        return 'Packed';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  int get itemsCount => items.fold(0, (sum, item) => sum + item.quantity.ceil());
}

enum OrderStatus {
  placed,
  confirmed,
  preparing,
  packed,
  outForDelivery,
  delivered,
  cancelled,
}

enum PaymentMethod {
  cashOnDelivery,
  card,
  upi,
  netBanking,
  wallet,
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.cashOnDelivery:
        return 'Cash on Delivery';
      case PaymentMethod.card:
        return 'Credit/Debit Card';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.netBanking:
        return 'Net Banking';
      case PaymentMethod.wallet:
        return 'Wallet';
    }
  }

  String get icon {
    switch (this) {
      case PaymentMethod.cashOnDelivery:
        return '💵';
      case PaymentMethod.card:
        return '💳';
      case PaymentMethod.upi:
        return '📱';
      case PaymentMethod.netBanking:
        return '🏦';
      case PaymentMethod.wallet:
        return '👛';
    }
  }

  bool get isOnline {
    return this != PaymentMethod.cashOnDelivery;
  }
}

extension OrderModelCopyWith on OrderModel {
  OrderModel copyWith({
    String? id,
    String? userId,
    List<CartItem>? items,
    AddressModel? deliveryAddress,
    double? subtotal,
    double? deliveryFee,
    double? total,
    OrderStatus? status,
    PaymentMethod? paymentMethod,
    DateTime? orderDate,
    DateTime? estimatedDelivery,
    DateTime? deliveredAt,
    String? notes,
    String? trackingId,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      orderDate: orderDate ?? this.orderDate,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      notes: notes ?? this.notes,
      trackingId: trackingId ?? this.trackingId,
    );
  }
}
