class AspectosProyecto {
  final String titulo;
  final List<String> subtitulos;

  AspectosProyecto(this.titulo, this.subtitulos);
}

List<AspectosProyecto> aspectosProyecto = [
  AspectosProyecto('Diseño conceptual', [
    'Programa arquitectónico definitivo',
    'Memoria descriptiva del concepto arquitectónico',
    'Esquema funcional (plantas básicas)',
    'Imagen conceptual (perspectivas volumétricas)',
    'Estimado de costos de obra',
    'Dictamen de uso de suelo',
    'Dictamen de impacto ambiental',
  ]),
  AspectosProyecto('Anteproyecto', [
    'Memoria descriptiva del proyecto',
    'Plantas cortes y fachadas a escala convencional',
    'Apuntes en perspectivas',
    'Criterio estructural',
    'Criterios de instalaciones',
    'Especificaciones generales',
    'Estimado de costos a nivel de partidas',
    'Dictamen de INAH',
  ]),
  AspectosProyecto('Diseño ejecutivo', [
    'Planos de localización y de conjunto',
    'Planos arquitectónicos detallados',
    'Detalles constructivos',
    'Planos detallados de herrería y/o cancelería y/o carpintería',
    'Planos de albañilería',
    'Planos de acabados',
    'Catálogo de especificaciones particulares',
    'Perspectivas detalladas',
    'Presupuesto con cantidades de obra y análisis de precios unitarios',
    'Programa de obra',
    'Firma de Perito responsable de Proyecto (P. R. P.)',
  ]),
  AspectosProyecto('Estructural', [
    'Memoria de cálculo estructural',
    'Planos detallados de cimentación con especificaciones',
    'Planos estructurales detallados con especificaciones',
    'Detalles estructurales',
    'Firma de director Corresponsable en estructuras (en su caso)',
  ]),
  AspectosProyecto('Instalación eléctrica', [
    'Memoria técnica',
    'Planos detallados de instalación eléctrica con especificaciones',
    'Relación de equipos fijos y sus características',
    'Cuadro de cargas',
    'Diagrama unifilar',
    'Firma del Director Corresponsable en instalación Eléctrica',
  ]),
  AspectosProyecto('Instalación hidrosanitaria', [
    'Memoria técnica',
    'Planos detallados de instalación hidráulica con especificaciones',
    'Planos detallados de instalación sanitaria con especificaciones',
    'Relación de equipos fijos, mecánicas y sus características',
    'Cuadros de gastos hidráulico y descargas',
    'Isométricos y despiece',
    'Firma de director Corresponsable en instalaciones hidrosanitarias',
  ]),
  AspectosProyecto('Instalación de gas', [
    'Memoria técnica',
    'Planos detallados de instalación de gas con especificaciones',
    'Relación de equipos fijos, mecánicas y sus características',
    'Cuadros de gastos hidráulico y descargas',
    'Isométricos y despiece',
    'Firma de Director Corresponsable en instalaciones hidrosanitarias',
  ]),
];