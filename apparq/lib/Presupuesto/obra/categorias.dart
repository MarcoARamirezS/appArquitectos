class Categoria {
  final String titulo;
  final List<String> opciones;

  Categoria(this.titulo, this.opciones);
}

List<Categoria> categorias = [
  Categoria('A', [
    'Hospitales',
    'Unidades médicas de especialidades',
    'Centros de Salud con Servicios Ampliados (CESSA)',
    'Laboratorios clínicos o especializados en salud'
  ]),
  Categoria('B', [
    'Módulo Deportivo multidisciplinario',
    'Auditorios o Teatros'
  ]),
  Categoria('C', [
    'Edificios de Infraestructura de seguridad o penitenciaria',
    'Academias de policía',
    'Edificios de procuración de justicia y Órganos auxiliares',
    'Edificios administrativos',
    'Edificios de infraestructura educativa de nivel superior medio superior y básica',
    'Centros de Atención Integral y Servicios Esenciales en Salud (CAISES)',
    'Unidades de Salud para Atención Primaria o Servicios Básicos (UMAPS)',
    'Laboratorios de ciencias o tecnología',
    'Clínicas',
    'Vivienda unifamiliar o plurifamiliar',
    'Laboratorios clínicos o especializados en salud',
    'Edificios de atención Animal'
  ]),
  Categoria('D', [
    'Canchas deportivas de concreto con cubierta',
    'Canchas empastadas',
    'Pista de atletismo',
    'Canchas al aire libre andadores plazas'
  ]),
  Categoria('E', [
    'Construcción o adecuación de estación de servicio de combustible',
    'Sistemas de elevación vertical',
    'Sistemas de elementos estructurales prefabricados para edificación',
    'Rastros',
    'Obras para la Disposición final Recolección y acarreo de residuos sólidos.',
    'Mecánica teatral aérea y de piso',
    'Imagen urbana y Paisajismo',
    'Estructuras metálicas para edificación',
    'Estructuras metálicas ligeras tanques elevados espectaculares de estructura metálica torres de telecomunicaciones estructuras metálicas mayores para trasmisión',
    'Naves Industriales',
    'Trabajos y Obra de Edificación básica',
    'Terracerías'
  ]),
  Categoria('F', [
    'Instalaciones en Albercas',
    'Ductos Subterráneos para servicios',
    'Instalaciones de gas lp',
    'Instalaciones de gases medicinales',
    'Instalaciones de aire acondicionado (HVAC)',
    'Sistema de protección contra incendios',
    'Calentadores solares para sistemas hidráulicos',
    'Instalaciones especiales voz, datos y fibra óptica.',
    'Mecánica teatral aérea y de piso',
    'Sistemas de elevación vertical',
    'Instalaciones eléctricas media y alta tensión'
  ]),
];
