class Validators {
  static String? notEmpty(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ce champ est requis';
    return null;
  }
}