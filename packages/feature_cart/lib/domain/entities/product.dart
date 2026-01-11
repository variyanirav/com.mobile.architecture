import 'package:equatable/equatable.dart';

/// Product entity representing an item that can be added to cart
class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [id, name, description, price, imageUrl];

  @override
  String toString() => 'Product(id: $id, name: $name, price: \$$price)';
}
