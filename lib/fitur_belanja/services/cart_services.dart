import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sportwatch_ng/config.dart' as app_config;

class CartService {
  static Uri _cartEndpoint([String path = ""]) {
    final suffix = path.isEmpty
        ? ""
        : path.endsWith('/')
        ? path
        : "$path/";
    return Uri.parse(app_config.baseUrl).resolve("/cart/$suffix");
  }

  static Future<Map<String, dynamic>> getCart() async {
    final res = await http.get(_cartEndpoint());
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> add(int productId) async {
    final res = await http.post(
      _cartEndpoint('add'),
      body: {"product_id": productId.toString(), "qty": "1"},
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateQty(int itemId, int qty) async {
    final res = await http.post(
      _cartEndpoint('update'),
      body: {"item_id": itemId.toString(), "qty": qty.toString()},
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> removeItem(int itemId) async {
    final res = await http.post(
      _cartEndpoint('remove'),
      body: {"item_id": itemId.toString()},
    );
    return jsonDecode(res.body);
  }
}
