String pluralize(String singular, int count) {
  if (count == 1) {
    return singular;
  }

  if (singular.isEmpty) {
    return singular;
  }

  final bool isUpperCase = singular == singular.toUpperCase();

  final String lastChar = singular.substring(singular.length - 1).toLowerCase();
  
  String result;

  if (['a', 'e', 'o', 'u'].contains(lastChar)) {
    result = '${singular}s';
  } else if (lastChar == 'l') {
    result = '${singular.substring(0, singular.length - 1)}is';
  } else if (lastChar == 'm') {
    result = '${singular.substring(0, singular.length - 1)}ns';
  } else if (lastChar == 'r' || lastChar == 'z') {
     result = '${singular}es';
  } else if (lastChar == 's') {
    result = singular;
  } else {
    result = '${singular}s';
  }

  return isUpperCase ? result.toUpperCase() : result;
}