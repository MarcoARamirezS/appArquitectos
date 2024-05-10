class Ponderacion {
  double porcentaje;
  List<SubPonderacion> subPonderaciones;

  Ponderacion({required this.porcentaje, required this.subPonderaciones});
}

class SubPonderacion {
  String nombre;
  double porcentaje;

  SubPonderacion({required this.nombre, required this.porcentaje});
}

// Ejemplo de cómo podrías estructurar esto para una categoría
List<Ponderacion> ponderaciones = [
  Ponderacion(
    porcentaje: 0.11,  // 11% para Diseño Conceptual
    subPonderaciones: [
      SubPonderacion(nombre: "Programa Arquitectónico definitivo", porcentaje: 0.15),
      SubPonderacion(nombre: "Memoria descriptiva del concepto arquitectónico", porcentaje: 0.10),
      // Añade más subponderaciones aquí
    ],
  ),
  // Añade más categorías aquí
];
