import 'package:meat_delivery/models/Inventory.dart';

enum Status {
  confirmed,
  pickedUp,
  delivered,
  cancelled
}

class Orders {
  final Status status;
  final List<Inventory> orderDetails;
  final String address;
  final String user;

  Orders({
    required this.status,
    required this.orderDetails,
    required this.address,
    required this.user,
  });

}