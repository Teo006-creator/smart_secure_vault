import 'package:encrypt/encrypt.dart' as encrypt;

class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  // In a real app, this key should be derived from the user's master password
  // using a Key Derivation Function like PBKDF2. For this innovation demo,
  // we'll use a fixed salt + user-specific master seed logic.
  
  encrypt.Key _deriveKey(String masterPassword) {
    // Ensuring the key is exactly 32 bytes for AES-256
    final keyString = masterPassword.padRight(32, '0').substring(0, 32);
    return encrypt.Key.fromUtf8(keyString);
  }

  String encryptData(String plainText, String masterPassword) {
    final key = _deriveKey(masterPassword);
    final iv = encrypt.IV.fromSecureRandom(16); // Secure random IV for each entry
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    // Return both IV and ciphertext joined by a separator
    return "${iv.base64}:${encrypted.base64}";
  }

  String decryptData(String ivAndCiphertext, String masterPassword) {
    try {
      final parts = ivAndCiphertext.split(':');
      if (parts.length != 2) return "[Error: Formato inválido]";
      
      final iv = encrypt.IV.fromBase64(parts[0]);
      final ciphertext = parts[1];
      
      final key = _deriveKey(masterPassword);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      
      return encrypter.decrypt64(ciphertext, iv: iv);
    } catch (e) {
      return "[Error al desencriptar]";
    }
  }

  // Simple password strength calculator (0 to 1.0)
  double calculateStrength(String password) {
    if (password.isEmpty) return 0.0;
    double strength = 0.0;
    if (password.length >= 8) strength += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[!@#\$&*~]').hasMatch(password)) strength += 0.25;
    return strength;
  }
}
