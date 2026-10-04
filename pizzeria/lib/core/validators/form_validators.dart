class FormValidators {
  static String? requiredField(String? value, [String message = 'Este campo es obligatorio']) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo es obligatorio';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingresa un correo electrónico válido (ej. usuario@dominio.com)';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  static String? positiveNumber(String? value, [String message = 'Ingresa un número válido']) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    final number = double.tryParse(value.trim());
    if (number == null || number <= 0) {
      return message;
    }
    return null;
  }

  static String? validUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La URL de la imagen es obligatoria';
    }
    final uri = Uri.tryParse(value.trim());
    if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
      return 'Ingresa una URL válida (http/https)';
    }
    return null;
  }

  static String? coordinate(String? value, {required bool isLatitude}) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    final num = double.tryParse(value.trim());
    if (num == null) return 'Ingresa un número decimal válido';
    if (isLatitude && (num < -90 || num > 90)) {
      return 'La latitud debe estar entre -90 y 90';
    }
    if (!isLatitude && (num < -180 || num > 180)) {
      return 'La longitud debe estar entre -180 y 180';
    }
    return null;
  }
}
