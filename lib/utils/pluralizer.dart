String pluralize(String singular, int count) {
  if (count == 1) {
    return singular;
  }

  if (singular.isEmpty) {
    return singular;
  }

  final String lastChar = singular.substring(singular.length - 1);
  if (['a', 'e', 'o', 'u'].contains(lastChar)) {
    return '${singular}s';
  }

  if (lastChar == 'l') {
    return '${singular.substring(0, singular.length - 1)}is';
  }

  if (lastChar == 'm') {
    return '${singular.substring(0, singular.length - 1)}ns';
  }
  
  if (lastChar == 'r' || lastChar == 'z') {
     return '${singular}es';
  }
  
  if (lastChar == 's') {
    return singular;
  }
  
  return '${singular}s';
}