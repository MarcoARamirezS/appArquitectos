class Ponderacion {
  String categoria;
  double porcentaje;
  List<SubPonderacion> subPonderaciones;

  Ponderacion({required this.categoria, required this.porcentaje, required this.subPonderaciones});
}

class SubPonderacion {
  String nombre;
  double porcentaje;

  SubPonderacion({required this.nombre, required this.porcentaje});
}

List<Ponderacion> ponderaciones = [
  Ponderacion(
    categoria: "Diseño conceptual",
    porcentaje: 0.11,  // 11% para Diseño Conceptual
    subPonderaciones: [
      SubPonderacion(nombre: "Programa arquitectónico definitivo", porcentaje: 0.15),
      SubPonderacion(nombre: "Memoria descriptiva del concepto arquitectónico", porcentaje: 0.10),
      SubPonderacion(nombre: "Esquema funcional (plantas básicas)", porcentaje: 0.30),
      SubPonderacion(nombre: "Imagen conceptual (perspectivas volumétricas)", porcentaje: 0.15),
      SubPonderacion(nombre: "Estimado de costos de obra", porcentaje: 0.10),
      SubPonderacion(nombre: "Dictamen de uso de suelo", porcentaje: 0.10),
      SubPonderacion(nombre: "Dictamen de impacto ambiental", porcentaje: 0.10),
    ],
  ),
  Ponderacion(
    categoria: "Anteproyecto",
    porcentaje: 0.20,  // 20% para Anteproyecto
    subPonderaciones: [
      SubPonderacion(nombre: "Memoria descriptiva del proyecto", porcentaje: 0.10),
      SubPonderacion(nombre: "Plantas cortes y fachadas a escala convencional", porcentaje: 0.30),
      SubPonderacion(nombre: "Apuntes en perspectivas", porcentaje: 0.05),
      SubPonderacion(nombre: "Criterio estructural", porcentaje: 0.10),
      SubPonderacion(nombre: "Criterios de instalaciones", porcentaje: 0.10),
      SubPonderacion(nombre: "Especificaciones generales", porcentaje: 0.15),
      SubPonderacion(nombre: "Estimado de costos a nivel de partidas", porcentaje: 0.10),
      SubPonderacion(nombre: "Dictamen de INAH", porcentaje: 0.10),
    ],
  ),
  Ponderacion(
    categoria: "Diseño ejecutivo",
    porcentaje: 0.35,  // 35% para Diseño Ejecutivo
    subPonderaciones: [
      SubPonderacion(nombre: "Planos de localización y de conjunto", porcentaje: 0.05),
      SubPonderacion(nombre: "Planos arquitectónicos detallados", porcentaje: 0.10),
      SubPonderacion(nombre: "Detalles constructivos", porcentaje: 0.10),
      SubPonderacion(nombre: "Planos detallados de herrería y/o cancelería y/o carpintería", porcentaje: 0.10),
      SubPonderacion(nombre: "Planos de albañilería", porcentaje: 0.10),
      SubPonderacion(nombre: "Planos de acabados", porcentaje: 0.10),
      SubPonderacion(nombre: "Catálogo de especificaciones particulares", porcentaje: 0.10),
      SubPonderacion(nombre: "Perspectivas detalladas", porcentaje: 0.10),
      SubPonderacion(nombre: "Presupuesto con cantidades de obra y análisis de precios unitarios", porcentaje: 0.10),
      SubPonderacion(nombre: "Programa de obra", porcentaje: 0.05),
      SubPonderacion(nombre: "Firma de Perito responsable de Proyecto (P. R. P.)", porcentaje: 0.10),
    ],
  ),
  Ponderacion(
    categoria: "Estructural",
    porcentaje: 0.12,  // 12% para Estructura
    subPonderaciones: [
      SubPonderacion(nombre: "Memoria de cálculo estructural", porcentaje: 0.35),
      SubPonderacion(nombre: "Planos detallados de cimentación con especificaciones", porcentaje: 0.25),
      SubPonderacion(nombre: "Planos estructurales detallados con especificaciones", porcentaje: 0.15),
      SubPonderacion(nombre: "Detalles estructurales", porcentaje: 0.15),
      SubPonderacion(nombre: "Firma de director Corresponsable en estructuras (en su caso)", porcentaje: 0.10),
    ],
  ),
  Ponderacion(
    categoria: "Instalación eléctrica",
    porcentaje: 0.10,  // 10% para Instalación Eléctrica
    subPonderaciones: [
      SubPonderacion(nombre: "Memoria técnica", porcentaje: 0.25),
      SubPonderacion(nombre: "Planos detallados de instalación eléctrica con especificaciones", porcentaje: 0.35),
      SubPonderacion(nombre: "Relación de equipos fijos y sus características", porcentaje: 0.10),
      SubPonderacion(nombre: "Cuadro de cargas", porcentaje: 0.10),
      SubPonderacion(nombre: "Diagrama unifilar", porcentaje: 0.10),
      SubPonderacion(nombre: "Firma del Director Corresponsable en instalación Eléctrica", porcentaje: 0.10),
    ],
  ),
  Ponderacion(
    categoria: "Instalación hidrosanitaria",
    porcentaje: 0.08,  // 8% para Instalación Hidrosanitaria
    subPonderaciones: [
      SubPonderacion(nombre: "Memoria técnica", porcentaje: 0.15),
      SubPonderacion(nombre: "Planos detallados de instalación hidráulica con especificaciones", porcentaje: 0.20),
      SubPonderacion(nombre: "Planos detallados de instalación sanitaria con especificaciones", porcentaje: 0.20),
      SubPonderacion(nombre: "Relación de equipos fijos, mecánicas y sus características", porcentaje: 0.05),
      SubPonderacion(nombre: "Cuadros de gastos hidráulico y descargas", porcentaje: 0.10),
      SubPonderacion(nombre: "Isométricos y despiece", porcentaje: 0.20),
      SubPonderacion(nombre: "Firma de director Corresponsable en instalaciones hidrosanitarias", porcentaje: 0.10),
    ],
  ),
  Ponderacion(
    categoria: "Instalación de gas",
    porcentaje: 0.04,  // 4% para Instalación de Gas
    subPonderaciones: [
      SubPonderacion(nombre: "Memoria técnica", porcentaje: 0.25),
      SubPonderacion(nombre: "Planos detallados de instalación de gas con especificaciones", porcentaje: 0.35),
      SubPonderacion(nombre: "Relación de equipos fijos, mecánicas y sus características", porcentaje: 0.10),
      SubPonderacion(nombre: "Cuadros de gastos hidráulico y descargas", porcentaje: 0.10),
      SubPonderacion(nombre: "Isométricos y despiece", porcentaje: 0.10),
      SubPonderacion(nombre: "Firma de Director Corresponsable", porcentaje: 0.10),
    ],
  )
];

