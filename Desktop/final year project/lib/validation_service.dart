class ValidationService {
  final List<String> registeredEmails = [
    "example@example.com",
    "user@domain.com"
  ];

  // E-posta doğrulama fonksiyonu
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    } else if (!value.contains('@')) {
      return 'Please enter a valid email with @';
    } else if (!registeredEmails.contains(value)) {
      return 'This email is not registered';
    }
    return null;
  }

  // Şifre doğrulama fonksiyonu
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    } else if (value != "password123") {
      return 'Incorrect password';
    }
    return null;
  }

  // E-posta veya Telefon doğrulama fonksiyonu
  bool validateEmailOrPhone(String value) {
    // Basit bir e-posta doğrulaması
    bool emailValid =
        RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
            .hasMatch(value);

    // Basit bir telefon numarası doğrulaması
    bool phoneValid = RegExp(r"^\+?\d{10,13}$").hasMatch(
        value); // Örnek telefon numarası kontrolü (10-13 haneli numaralar)

    return emailValid ||
        phoneValid; // E-posta veya telefon numarası geçerliyse true döner
  }
}
