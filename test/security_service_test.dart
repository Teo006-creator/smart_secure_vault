import 'package:flutter_test/flutter_test.dart';
import 'package:smart_secure_vault/services/security_service.dart';

void main() {
  group('SecurityService Tests', () {
    final securityService = SecurityService();
    const masterPassword = 'my_secure_master_password';

    test('Encryption and Decryption should work with random IV', () {
      const plainText = 'secret_data_123';
      
      final encrypted1 = securityService.encryptData(plainText, masterPassword);
      final encrypted2 = securityService.encryptData(plainText, masterPassword);
      
      // Verification: Two encryptions of the same text should be different because of random IV
      expect(encrypted1, isNot(equals(encrypted2)));
      
      // Verification: Decryption should recover the original text
      final decrypted1 = securityService.decryptData(encrypted1, masterPassword);
      final decrypted2 = securityService.decryptData(encrypted2, masterPassword);
      
      expect(decrypted1, equals(plainText));
      expect(decrypted2, equals(plainText));
    });

    test('Decryption with wrong password should fail', () {
      const plainText = 'secret_data_123';
      final encrypted = securityService.encryptData(plainText, masterPassword);
      
      final decryptedWithWrongPass = securityService.decryptData(encrypted, 'wrong_password');
      expect(decryptedWithWrongPass, isNot(equals(plainText)));
    });
  });
}
