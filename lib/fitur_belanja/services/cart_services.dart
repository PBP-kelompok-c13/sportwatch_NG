import 'dart:convert';
import 'package:http/http.dart' as http;

class CartService {
  static const baseUrl = "http://127.0.0.1:8000/api/cart/";

  static Future<Map<String, dynamic>> getCart() async {
    final res = await http.get(Uri.parse(baseUrl));
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> add(int productId) async {
    final res = await http.post(
      Uri.parse('${baseUrl}add/'),
      body: {"product_id": productId.toString(), "qty": "1"},
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateQty(int itemId, int qty) async {
    final res = await http.post(
      Uri.parse('${baseUrl}update/'),
      body: {"item_id": itemId.toString(), "qty": qty.toString()},
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> removeItem(int itemId) async {
    final res = await http.post(
      Uri.parse('${baseUrl}remove/'),
      body: {"item_id": itemId.toString()},
    );
    return jsonDecode(res.body);
  }
}
