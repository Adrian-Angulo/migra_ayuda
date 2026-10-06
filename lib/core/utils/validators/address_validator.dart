class AddressValidator {

  static final RegExp _addressRegExp = RegExp(
    r'^(Calle|Cl\.?|Carrera|Cra\.?|Avenida|Av\.?|Diagonal|Dg\.?|Transversal|Tv\.?)\s+\d+[a-zA-Z]?\s*(#|No\.?)\s*\d+[a-zA-Z]?\s*-\s*\d+,\s*Pasto$',
    caseSensitive: false,
  );

  static String? validate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La dirección es requerida';
    }

    final trimmed = value.trim();

    if (!trimmed.toLowerCase().endsWith('pasto')) {
      return 'La dirección debe terminar con la ciudad: , Pasto';
    }

    if (!_addressRegExp.hasMatch(trimmed)) {
      return 'Formato requerido: Calle/Carrera 123 #45-67, Pasto';
    }
    return null;
  }
}
