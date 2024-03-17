class Subcategoria {
  final String titulo;
  final List<String> opciones;

  Subcategoria(this.titulo, this.opciones);
}

class Categoria {
  final String titulo;
  final List<Subcategoria> subcategorias;

  Categoria(this.titulo, this.subcategorias);
}

List<Categoria> categorias = [
  Categoria('A', [
    Subcategoria('Hospitales', []),
    Subcategoria('Unidades médicas de especialidades', []),
    Subcategoria('Centros de Salud con Servicios Ampliados (CESSA)', []),
    Subcategoria('Laboratorios clínicos o especializados en salud', []),
  ]),
  Categoria('B', [
    Subcategoria('Módulo Deportivo multidisciplinario', [
      'Cancha de usos múltiples con recubrimiento acrílico de 633.75 m2',
      'Cancha de usos múltiples sin recubrimiento acrílico de 633.75 m2',
      'Techado de cancha de usos múltiples de 751.08 m2',
    ]),
    Subcategoria('Auditorios o Teatros', []),
  ]),
  Categoria('C', [
    Subcategoria('Edificios de Infraestructura de seguridad o penitenciaria', []),
    Subcategoria('Academias de policía', []),
    Subcategoria('Edificios de procuración de justicia y Órganos auxiliares', []),
    Subcategoria('Edificios administrativos', []),
    Subcategoria('Edificios de infraestructura educativa de nivel superior medio superior y básica', [
      'Aula asilada e 2.00 E.E. En estructura U-1C de 92.18 m2',
      'Aula asilada de 6.00 x 8.00 mts en sistema tradicional',
      'Techado cancha de usos múltiples infraestructura educativa 872.16 m2',
    ]),
    Subcategoria('Centros de Atención Integral y Servicios Esenciales en Salud (CAISES)', []),
    Subcategoria('Unidades de Salud para Atención Primaria o Servicios Básicos (UMAPS)', [
      'UMPAS un consultorio',
      'UMPAS dos consultorios',
      'UMPAS tres consultorios',
      'UMPAS cuatro consultorios',
    ]),
    Subcategoria('Laboratorios de ciencias o tecnología', []),
    Subcategoria('Clínicas', []),
    Subcategoria('Vivienda unifamiliar o plurifamiliar', []),
    Subcategoria('Laboratorios clínicos o especializados en salud', []),
    Subcategoria('Edificios de atención Animal', []),
  ]),
  Categoria('D', [
    Subcategoria('Canchas deportivas de concreto con cubierta', []),
    Subcategoria('Canchas empastadas', [
      'Cancha de futbol siete de 34 x 54 m',
      'Cancha de futbol soccer prácticas de 64.40 x 94.40 m',
    ]),
    Subcategoria('Pista de atletismo', []),
    Subcategoria('Canchas al aire libre andadores plazas', [
      'Gimnasio al aire libre de 64 m2',
    ]),
  ]),
  Categoria('E', [
    Subcategoria('Construcción o adecuación de estación de servicio de combustible', []),
    Subcategoria('Sistemas de elevación vertical', []),
    Subcategoria('Sistemas de elementos estructurales prefabricados para edificación', []),
    Subcategoria('Rastros', []),
    Subcategoria('Obras para la Disposición final Recolección y acarreo de residuos sólidos.', []),
    Subcategoria('Mecánica teatral aérea y de piso', []),
    Subcategoria('Imagen urbana y Paisajismo', [
      'Espacios públicos plaza 1839 m2',
      'Guarnición regular 246.50 m y 7 m de arroyo vehicular',
      'Guarnición semi-integral 235.47 m y 7 m de arroyo vehicular',
    ]),
    Subcategoria('Estructuras metálicas para edificación', []),
    Subcategoria('Estructuras metálicas ligeras tanques elevados espectaculares de estructura metálica torres de telecomunicaciones estructuras metálicas mayores para trasmisión', []),
    Subcategoria('Naves Industriales', []),
    Subcategoria('Trabajos y Obra de Edificación básica', [
      'Barda perimetral – cimentación de zapatas aisladas módulo de 18.20 m',
      'Barda perimetral – cimentación de zapata corrida módulo de 18.20 m',
      'Barda perimetral – cimentación de mampostería módulo de 18.20 m',
    ]),
    Subcategoria('Terracerías', []),
  ]),
  Categoria('F', [
    Subcategoria('Instalaciones en Albercas', []),
    Subcategoria('Ductos Subterráneos para servicios', [
      'Línea de conducción 14.49 m',
      'Línea de distribución 7.95 m',
    ]),
    Subcategoria('Instalaciones de gas lp', []),
    Subcategoria('Instalaciones de gases medicinales', []),
    Subcategoria('Instalaciones de aire acondicionado (HVAC)', []),
    Subcategoria('Sistema de protección contra incendios', []),
    Subcategoria('Calentadores solares para sistemas hidráulicos', []),
    Subcategoria('Instalaciones especiales voz, datos y fibra óptica.', []),
    Subcategoria('Mecánica teatral aérea y de piso', []),
    Subcategoria('Sistemas de elevación vertical', []),
    Subcategoria('Instalaciones eléctricas media y alta tensión', []),
  ]),
];