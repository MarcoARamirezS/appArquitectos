final Map<String, double> factorDeCosto = {
  'a-1': 1.39,
  'a-2': 1.06,
  'a-3': 1.55,
  'a-4': 1.24,
  'a-5': 1.20,
  'a-6': 1.16,
  'co-1': 1.45,  // AGENCIA AUTOMOTRIZ. Clase 4. Área de exhibición, ventas, taller, área de refacciones. Estructura de acero
  'co-2': 1.04,  // Centros de Abastos
  'co-3': 2.12,  // Centros Comerciales
  'co-4': 1.86,  // Centros de Exposiciones
  'co-5': 1.79,  // Edificios Comerciales y Oficinas
  'co-6': 1.89,  // Farmacias y Drogerías
  'co-7': 1.89,  // Ferreterías y Tlapalerías
  'co-8': 2.07,  // Joyerías
  'co-9': 1.89,  // Librerías
  'co-10': 1.04,  // Mercados
  'co-11': 1.69,  // Supermercados y Autoservicios
  'co-12': 1.66,  // Interiorismo Comercial
  'co-13': 1.94,  // TIENDA DEPARTAMENTAL. Clase 5. Estructura mixta (Concreto y acero)
  'co-14': 2.07,  // Tiendas Especializadas
  'co-15': 1.37,  // Locales Comerciales
  'co-16': 0.62,  // Stands
  'co-17': 1.10,  // TIENDA DE CONVENIENCIA. Clase 4. Estructura de concreto y cubierta con estructura de acero y tiendas de Abarrotes
  'co-18': 1.69,  // TIENDA DE AUTOSERVICIO. Estructura Metálica, estacionamiento superficial descubierto (Tienda de equipo de cómputo y papelería) Centros comerciales
  'co-19': 1.86,  // Centros de exposiciones (Áreas de exposición)
  'co-20': 1.60,  // EDIFICIO PARA OFICINAS. Clase 2 baja 4 niveles. Estructura de concreto, muros de block, losa reticular sin estacionamiento, 2 fachadas Edificios comerciales y oficinas
  'co-21': 1.79,  // EDIFICIO PARA OFICINAS. Clase 4 media 8 niveles. Estructura mixta, 2 fachadas con elevador y estacionamiento en planta baja parte del edificio
  'co-22': 1.80,  // EDIFICIO PARA OFICINAS. Clase 4 media 6 niveles. Estructura de concreto, elevador y estacionamiento. En planta baja
  'co-23': 1.04,  // Mercados (no incluye áreas de estacionamiento)
  'co-24': 1.69,  // Supermercados y autoservicios
  'co-25': 1.04,  // Centros de Abastos (Centros de Acopio o Distribución) (no incluye estacionamientos)
  'co-26': 0.90,  // Distribuidores de bebidas (no incluye estacionamientos ni patios de maniobras)
  'mc-1': 1.45,  // Agencia de Noticias
  'mc-2': 1.55,  // Centrales Telefónicas
  'mc-3': 1.14,  // Centros de Internet
  'mc-4': 1.24,  // Edificios de Correos
  'mc-5': 1.24,  // Edificios de Telégrafos
  'mc-6': 2.28,  // Estudios de Audio y Video
  'mc-7': 1.97,  // Estudios de Cine
  'mc-8': 2.17,  // Estudios de TV
  'mc-9': 1.14,  // Paquetería y Envíos
  'mc-10': 1.24, // Prensa
  'mc-11': 1.59, // Radiodifusoras
  'mc-12': 0.30, // Torres de Líneas de Alta Tensión 115-440 kva
  'mc-13': 0.30, // Torres de Aerogeneradores Eléctricos
  'mc-14': 0.30, // Paneles de Generación Solar Eléctricos
  'mc-15': 0.30, // Sub Estaciones Eléctricas
  'mc-16': 2.69, // Torres de control aéreo
  'mc-17': 1.25, // Editoriales (Editora de libros, revistas o periódicos)
  'mc-18': 1.30, // Estudios de audio y video
  'mc-19': 1.04, // Salas de espera
  't-1': 2.07,  // Aeropuertos
  't-2': 2.07,  // Terminales Aéreas
  't-3': 1.27,  // Hangares
  't-4': 2.69,  // Torres de Control
  't-5': 0.31,  // Obra Exterior
  't-6': 1.24,  // Casetas de Peaje
  't-7': 1.35,  // Centrales de Autobuses
  't-8': 1.35,  // Estaciones de Ferrocarril
  't-9': 1.76,  // Estaciones de Transporte Colectivo
  't-10': 1.76, // Instalaciones Portuarias
  't-11': 1.04, // Paraderos de Autobuses
  't-12': 0.58, // Talleres de Mantenimiento
  't-13': 1.04, // Taquillas y Salas de Espera
  't-14': 1.45, // Agencia de Noticias
  't-15': 1.14, // Centros de Internet
  't-16': 1.04, // Paraderos de Autobuses
  't-17': 1.24, // Casetas de Peaje
  't-18': 1.14, // Paquetería y Envíos
  'c-1': 1.35,  // Auditorios
  'c-2': 1.45,  // Bibliotecas
  'c-3': 1.24,  // Casas de Cultura
  'c-4': 1.24,  // Centros de Arte
  'c-5': 1.35,  // Editoriales
  'c-6': 1.55,  // Galerías de Arte
  'c-7': 2.48,  // Monumentos
  'c-8': 1.55,  // Museos
  'c-9': 2.07,  // Pabellones Internacionales y Nacionales
  'c-10': 2.17, // Salas de Concierto
  'c-11': 1.24, // Talleres de Arte
  'c-12': 2.07, // Teatros
  'c-13': 1.45, // Bibliotecas
  'c-14': 1.20, // Cinetecas
  'c-15': 0.90, // Centros de difusión cultural
  'c-16': 1.24, // Galerías de Arte
  'c-17': 1.24, // Hemerotecas
  'c-18': 1.10, // Salas de lectura
  'd-1': 3.01,  // Albercas Recreativas
  'd-2': 1.45,  // Boliche
  'd-3': 0.21,  // Canchas Descubiertas
  'd-4': 1.24,  // Clubes Deportivos
  'd-5': 0.83,  // Gimnasios y Canchas Cubiertas
  'd-6': 0.0,  // Club's de Golf
  'd-7': 1.24,  // clubes deportivos
  'd-8': 0.04,  // Campo de Golf
  'd-9': 0.0,  // Club's de Tiro
  'd-10': 1.24, // Casa Club
  'd-11': 0.04, // Campo de Tiro
  'd-12': 1.04, // Unidades Deportivas
  'd-13': 1.45, // Boliche
  'ec-1': 1.08, // Academias
  'ec-2': 1.45, // Centros de Investigación
  'ec-3': 1.35, // Campus de Educación Superior
  'ec-4': 1.15, // Escuelas Preescolares
  'ec-5': 1.15, // Escuelas Primarias
  'ec-6': 1.15, // Escuelas Secundarias
  'ec-7': 1.39, // Escuelas Preparatorias
  'ec-8': 1.39, // Escuelas Vocacionales
  'ec-9': 1.39, // Escuelas Técnicas
  'ec-10': 1.45, // Escuelas de Educación Especial
  'ec-11': 1.45, // Escuelas de Educación Superior
  'ec-12': 1.24, // Internados
  'ec-13': 1.45, // Laboratorios
  'ec-14': 1.45, // Laboratorios de Enseñanza
  'ec-15': 1.39, // Normales
  'ec-16': 1.45, // Laboratorios de investigación
  'ec-17': 1.40, // Observatorios
  'ec-18': 1.35, // ESCUELA SUPERIOR. Calidad popular, estructura de concreto.
  'ec-19': 1.40, // ESCUELA SUPERIOR. Calidad privada
  'ec-20': 1.08, // Áreas deportivas
  'ec-21': 1.35, // Campus universitarios
  'ec-22': 0.0,
  'ec-23': 1.39, //Escuelas de idiomas
  'fb-1': 1.20, //Bancos
  'fb-2': 1.28, //Casas de Bolsa
  'fb-3': 1.28, //Casas de Cambio
  'fb-4': 1.22, //Oficinas Centrales y Regionales
  'fb-5': 1.20, //Organizaciones Auxiliares
  'fb-6': 1.25, //Cajas populares 
  'g-1': 1.14,  // Archivos
  'g-2': 0.0,   // Bases Militares
  'g-3': 1.35,  // Edificios
  'g-4': 0.06,  // Obra Exterior
  'g-5': 1.20,  // Cuarteles Militares
  'g-6': 1.38,  // Oficinas Estatales
  'g-7': 1.38,  // Oficinas Federales
  'g-8': 1.05,  // Oficinas Municipales
  'g-9': 1.64,  // Palacios de Gobierno
  'g-10': 1.59, // Sedes Judiciales
  'g-11': 1.59, // Sedes Legislativas
  'g-12': 1.59, // Juzgados
  'g-13': 1.59, // Agencias del Ministerio Público
  'g-14': 1.35, // Bases aéreas
  'g-15': 1.20, // Cuarteles
  'h-1': 1.04,  // Vivienda de 60 a 100 m²
  'h-2': 0.85,  // Pies de Casa (Vivienda Popular en 36 m²)
  'h-3': 0.9,   // Vivienda Unifamiliar Popular (Vivienda económica hasta 60 m²)
  'h-4': 1.1,   // Vivienda Unifamiliar Media (de 61 a 100 m²)
  'h-5': 1.2,   // Vivienda Unifamiliar Media (De 101 a 150 m²)
  'h-6': 1.25,  // Vivienda Unifamiliar Media (de 151 a 200m²)
  'h-7': 1.3,   // Vivienda Unifamiliar Alta (De 201 a 300 m²)
  'h-8': 1.5,   // Residencias(Casas de Lujo 301 a 500)
  'h-9': 1.6,   // Residencias(Casas de Lujo 501 en adelante)
  'h-10': 0.95, // Edificio para Departamentos Clase 2 baja 2 niveles interés social. Sala-comedor, cocina, un baño, 2 recámaras y patio de servicio
  'h-11': 1.04, // Edificio para Departamentos Clase 2 baja 4 niveles interés social. Sala-comedor, cocina, un baño, 2 recámaras, y patio de servicio
  'h-12': 1.35, // Edificio para Departamentos Clase 4 media 4 niveles, Sala-comedor, cocina, patio de servicio, 1 baño, y 2 recámaras. 4 fachadas, estructura de acero y muro de tabique
  'h-13': 1.5,  // Edificio para Departamentos Clase 5 media Alta 5 niveles en adelante. Sala-comedor, cocina, patio de servicio, 2 baños y 3 recámaras. Estacionamiento P.B. y elevador. Estructura de acero.
  'h-14': 1.7,  // Edificio para Departamentos Clase 5 media alta 7 niveles. 2 fachadas. Sala-comedor, cocina, patio de servicio, 2 baños y 3 recámaras. Estacionamiento 2 sótanos y elevador. Estructura de acero.
  'h-15': 1.1,  // Edificio para Departamentos interés social más de 4 niveles
  'h-16': 1.55, // Edificio para Departamentos medio residencial de más de 5 niveles
  'h-17': 1.7,  // Edificio para Departamentos residencial de lujo de más de 7 niveles
  'p-1': 0.06,  // Áreas Exteriores
  'p-2': 0.55,  // Bodegas y Almacenes
  'p-3': 1.22,  // Laboratorios
  'p-4': 0.57,  // Talleres
  'p-5': 0.8,   // Áreas de empleados (comedor, baños)
  'p-6': 1.1,   // Laboratorios
  'p-7': 0.86,  // Plantas industriales completas (Maquiladoras) hasta 3,000 m²
  'p-8': 0.86,  // Plantas de artículos electrónicos hasta 3,000 m²
  'p-9': 0.55,  // Parques industriales hasta 5,000 m²
  'p-10': 0.4,  // Andenes
  'p-11': 0.6,  // Bodegas y almacenes hasta 1,600 m²
  'p-12': 0.5,  // Naves industriales hasta 3,000 m²
  'p-13': 0.6,  // Talleres hasta 1,600 m²
  'p-14': 0.55, // Industria ligera hasta 5,000 m²
  'p-15': 0.6,  // Industria mediana hasta 5,000 m²
  'p-16': 0.8,  // Industria pesada hasta 5,000 m²
  'p-17': 0.5,  // Industria ligera hasta 10,000 m²
  'p-18': 0.55, // Industria mediana hasta 10,000 m²
  'p-19': 0.7,  // Industria pesada hasta 10,000 m²
  'p-20': 0.4,  // Industria ligera más de 10,000 m²
  'p-21': 0.5,  // Industria mediana más de 10,000 m²
  'p-22': 0.6,  // Industria pesada más de 10,000 m²
  'p-23': 1.18, // Oficinas
  'p-24': 1.14, // Servicios del Personal
  'p-25': 1.14, // Casetas de Seguridad Pública
  'p-26': 0.0,  // Centros de Readaptación Social
  'p-27': 1.18, // Edificios
  'p-28': 0.06, // Obra Exterior
  'p-29': 0.0,  // Centros Tutelares
  'p-30': 1.18, // Edificios
  'p-31': 0.06, // Obra Exterior
  'p-32': 1.2,  // Cuarteles de Seguridad Pública
  'p-33': 0.0,  // Estaciones de Bomberos
  'p-34': 1.18, // Edificios
  'p-35': 0.06, // Obra Exterior
  'p-36': 0.0,  // Estaciones de Policía
  'p-37': 1.18, // Edificios
  'p-38': 0.06, // Obra Exterior
  'p-39': 1.22, // Laboratorios Especializados
  'p-40': 1.3,  // SEMEFO's
  're-1': 1.3,   // Arenas Deportivas
  're-2': 1.86,  // Autódromos
  're-3': 1.04,  // Billares
  're-4': 1.3,   // Centros Nocturnos
  're-5': 1.76,  // Cines
  're-6': 1.32,  // Estadios
  're-7': 1.86,  // Hipódromo
  're-8': 0.04,  // Jardines (zoológico, botánicos)
  're-9': 1.45,  // Lienzos Charros
  're-10': 1.3,  // Palenques
  're-11': 0.04, // Parques
  're-12': 1.86, // Planetarios
  're-13': 0.05, // Plazas Públicas
  're-14': 1.41, // Plazas de Toros
  're-15': 1.6,  // Salones de Fiesta
  're-16': 1.55, // Edificios
  're-17': 0.06, // Obra exterior
  're-18': 1.4,  // Teatros
  're-19': 1.3,  // Auditorios
  're-20': 1.3,  // Bares
  're-21': 1.1,  // Video centros
  're-22': 1.1,  // Video juegos
  're-23': 1.1,  // Balnearios
  're-24': 2.05, // Parques Tecnológicos
  're-25': 1.4,  // Salones de Fiesta
  're-26': 0.9,  // Canchas Deportivas y áreas Lúdicas
  're-27': 1.6,  // Casinos
  're-28': 1.1,  // Altares
  're-29': 1.3,  // Casas de retiro (espiritual)
  're-30': 1.1,  // Oficinas administrativas
  're-31': 1.1,  // Velatorios
  'r-1': 1.86,  // Basilicas y Catedrales
  'r-2': 1.97,  // Capillas
  'r-3': 1.3,   // Casas Pastorales
  'r-4': 1.2,   // Conventos y Monasterios
  'r-5': 1.76,  // Iglesias
  'r-6': 1.55,  // Sede Arzobispal
  's-1': 1.14,  // Centros de Rehabilitación Física
  's-2': 1.08,  // Centros de Salud
  's-5': 1.04,  // Dispensarios
  's-6': 1.24,  // Laboratorio de Análisis Clínicos
  's-7': 1.24,  // Laboratorio de Rayos X
  's-8': 1.92,  // Hospitales
  's-9': 1.22,  // Laboratorios Especializados
  's-10': 1.04, // Unidades de Servicio Médico
  's-11': 1.04, // Centros Antirrábicos
  's-12': 1.7,  // Balnearios termales
  's-13': 1.07, // Clínicas
  's-14': 0.8,  // Baños públicos
  's-15': 1.08, // Consultorios
  'SEG-1': 1.34,  // Casetas
  'SEG-2': 1.1,   // Archivos
  'SEG-3': 1.14,  // Correccionales
  'SEG-4': 1.22,  // Laboratorios especializados
  'SEG-5': 1.4,   // Cárceles
  'SEG-6': 1.18,  // Centros de readaptación social
  'SEG-7': 1.2,   // Cuarteles
  'SEG-8': 1.18,  // Delegaciones (Policía, Tránsito o Bomberos)
  'SEG-9': 1.2,   // Departamentos de Tránsito
  'SEG-10': 1.4,  // Estaciones de bomberos
  'SEG-11': 1.4,  // Estaciones de policías
  'SEG-12': 1.2,  // Oficinas administrativas
  'SEG-13': 1.3,  // SEMEFO's
  'tu-1': 1.14,  // Agencias de Viaje
  'tu-2': 0.0,   // Balnearios
  'tu-3': 1.14,  // Edificios
  'tu-4': 0.06,  // Obra Exterior
  'tu-5': 0.05,  // Camping
  'tu-6': 2.01,  // Centros de Convenciones
  'tu-7': 3.39,  // Complejos Hoteleros
  'tu-8': 0.06,  // Complejos y Hoteles (Obra Exterior)
  'tu-9': 2.82,  // Hoteles de cinco estrellas
  'tu-10': 1.94, // Hoteles de cuatro estrellas
  'tu-11': 1.55, // Hoteles de tres estrellas o menos
  'tu-12': 1.45, // Moteles
  'tu-13': 0.06, // Trailer Park
  'tu-14': 2.07, // SPA's
  'ab-1': 1.86,  // Bares y Cantinas
  'ab-2': 1.45,  // Cafeterías
  'ab-3': 1.24,  // Cocinas Rápidas
  'ab-4': 1.18,  // Comedores
  'ab-5': 1.76,  // Restaurantes
  'v-1': 1.33,  // Baños Públicos
  'v-2': 1.0,   // Estacionamientos Descubiertos
  'v-3': 1.16,  // Estacionamientos Cubiertos
  'v-4': 1.33,  // Gasolineras
};