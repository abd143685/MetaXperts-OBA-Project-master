class ProductsModel{
  int? id;
  String? product_code;
  String?product_name;
  String? uom;
  String? price;
  String? brand;
  dynamic? quantity;

  ProductsModel({
    this.id,
    this.product_code,
    this.product_name,
    this.uom,
    this.price,
    this.brand,
    this.quantity
  });

  // Create a factory constructor to create a Product instance from a map
  factory ProductsModel.fromMap(Map<dynamic, dynamic> json) {
    return ProductsModel(
      id: json['id'],
      product_code: json['product_code'],
      product_name: json['product_name'],
      uom: json['uom'],
      price: json['price'],
      brand: json['brand'],
      quantity: json['quantity']
    );
  }

  // Create a method to convert a Product instance to a map
  Map<String, dynamic> toMap() {
    return {
      'id':id,
      'product_code': product_code,
      'product_name': product_name,
      'uom': uom,
      'price': price,
      'brand': brand,
      'quantity':quantity
    };
  }
}
