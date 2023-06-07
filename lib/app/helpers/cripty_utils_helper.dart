import 'dart:convert';
import 'package:crypto/crypto.dart';

class CriptyUtilsHelper {
  CriptyUtilsHelper._();
  static String generateSha256Gash(String password) {
    final bytes = utf8.encode(password);
    
    return  sha256.convert(bytes).toString();
    
  }
}
