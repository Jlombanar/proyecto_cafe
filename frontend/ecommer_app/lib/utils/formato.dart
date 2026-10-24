/// Formatea un valor en pesos colombianos con separador de miles: 12000 -> $12.000
String formatoPrecio(num valor) {
  final entero = valor.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < entero.length; i++) {
    if (i > 0 && (entero.length - i) % 3 == 0) buffer.write('.');
    buffer.write(entero[i]);
  }
  return '\$$buffer';
}

/// Formatea una fecha como dd/MM/yyyy HH:mm en hora local
String formatoFecha(DateTime fecha) {
  final f = fecha.toLocal();
  String dos(int n) => n.toString().padLeft(2, '0');
  return '${dos(f.day)}/${dos(f.month)}/${f.year} ${dos(f.hour)}:${dos(f.minute)}';
}
