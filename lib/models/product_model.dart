import 'package:flutter_quill/quill_delta.dart';

import 'category.dart' as cat;

class Product {
  final String name;

  final double price;
  final double discount;
  final List<dynamic> images;
  final Delta details;
  final int stock;
  final int delivery;
  final int timesSold;
  final String company;
  final cat.Category category;
  final String size;
  final String gender;
  final String targetAge;
  final List<int> rating;
  final String postDate;
  final String id;

  Product(
      {required this.name,
      required this.price,
      required this.discount,
      required this.images,
      required this.details,
      required this.stock,
      required this.delivery,
      this.timesSold = 0,
      required this.id,
      required this.company,
      required this.category,
      required this.size,
      required this.gender,
      required this.targetAge,
      this.rating = const [0],
      required this.postDate});

  factory Product.fromMap(Map<String, dynamic> map) {
    if (map['name'] == null || map['price'] == null) {
      throw const FormatException('Missing required fields: name or price');
    }
    return Product(
      name: map['name'],
      id: map['id'],
      price: (map['price'] as num).toDouble(),
      discount: (map['discount'] as num).toDouble(),
      images: List<dynamic>.from(map['images'] ?? []),
      details: map['details'] ?? '',
      stock: map['stock'] ?? 0,
      delivery: map['delivery'] ?? 0,
      timesSold: map['timesSold'] ?? 0,
      company: map['company']?.toString() ?? '',
      category: cat.Category.fromMap(map['category']),
      size: map['size'].toString(),
      gender: map['gender'].toString(),
      targetAge: map['targetAge'].toString(),
      rating: List<int>.from(map['rating'] ?? []),
      postDate: map['postDate'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'id': id,
      'price': price,
      'discount': discount,
      'images': images,
      'details': details,
      'stock': stock,
      'delivery': delivery,
      'timesSold': timesSold,
      'company': company,
      'category': category.toMap(),
      'size': size,
      'gender': gender,
      'targetAge': targetAge,
      'rating': rating,
      'postDate': postDate,
    };
  }

  Product copyWith({
    String? name,
    double? price,
    double? discount,
    List<dynamic>? images,
    Delta? details,
    int? stock,
    int? delivery,
    int? timesSold,
    String? company,
    cat.Category? category,
    String? size,
    String? gender,
    String? targetAge,
    List<int>? rating,
    DateTime? postDate,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      images: images ?? this.images,
      details: details ?? this.details,
      stock: stock ?? this.stock,
      delivery: delivery ?? this.delivery,
      timesSold: timesSold ?? this.timesSold,
      company: company ?? this.company,
      category: category ?? this.category,
      size: size ?? this.size,
      gender: gender ?? this.gender,
      targetAge: targetAge ?? this.targetAge,
      rating: rating ?? this.rating,
      postDate: postDate.toString(),
    );
  }

  @override
  String toString() {
    return 'Product(id: $id,name: $name, price: $price, discount: $discount, images: $images, details: $details, stock: $stock, delivery: $delivery, timesSold: $timesSold, company: $company, category: $category, size: $size, gender: $gender, targetAge: $targetAge, rating: $rating, postDate: $postDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Product &&
        other.name == name &&
        other.price == price &&
        other.discount == discount &&
        other.images == images &&
        other.details == details &&
        other.stock == stock &&
        other.delivery == delivery &&
        other.id == id &&
        other.timesSold == timesSold &&
        other.company == company &&
        other.category == category &&
        other.size == size &&
        other.gender == gender &&
        other.targetAge == targetAge &&
        other.rating == rating &&
        other.postDate == postDate;
  }

  @override
  int get hashCode {
    return Object.hash(
      name,
      price,
      discount,
      images,
      details,
      stock,
      delivery,
      timesSold,
      id,
      company,
      category,
      size,
      gender,
      targetAge,
      rating,
      postDate,
    );
  }

  int avgRating() {
    return (rating.reduce((value, element) => value + element) / rating.length)
        .toInt();
  }
}
