import '../models/posting.dart';
import '../models/user_profile.dart';

/// Usuario "logueado" por defecto para la demo del MVP.
/// Sin backend todavía, todo vive en memoria.
const UserProfile kDemoCurrentUser = UserProfile(
  id: 'me',
  name: 'Alex Rivera',
  universityEmail: 'alex.rivera@universidad.edu',
  career: 'Ingeniería de Sistemas',
  semester: 6,
  skills: ['Flutter', 'Dart', 'UI/UX'],
  contactChannel: ContactChannel.whatsapp,
  contactValue: '+57 300 123 4567',
  bio: 'Busco equipo para proyectos de desarrollo móvil.',
);

/// Directorio de estudiantes simulados para poblar el feed y los matches.
const List<UserProfile> kMockDirectory = [
  UserProfile(
    id: 'u1',
    name: 'María Fernanda Gómez',
    universityEmail: 'maria.gomez@universidad.edu',
    career: 'Diseño Gráfico',
    semester: 5,
    skills: ['Figma', 'Branding', 'Ilustración'],
    contactChannel: ContactChannel.whatsapp,
    contactValue: '+57 301 555 0101',
    bio: 'Diseñadora enfocada en producto digital.',
  ),
  UserProfile(
    id: 'u2',
    name: 'Carlos Andrés Pérez',
    universityEmail: 'carlos.perez@universidad.edu',
    career: 'Ingeniería de Sistemas',
    semester: 7,
    skills: ['Backend', 'Node.js', 'PostgreSQL'],
    contactChannel: ContactChannel.email,
    contactValue: 'carlos.perez@universidad.edu',
    bio: 'Me gusta el backend y las bases de datos.',
  ),
  UserProfile(
    id: 'u3',
    name: 'Laura Sofía Ramírez',
    universityEmail: 'laura.ramirez@universidad.edu',
    career: 'Administración',
    semester: 4,
    skills: ['Finanzas', 'Excel', 'Liderazgo'],
    contactChannel: ContactChannel.whatsapp,
    contactValue: '+57 302 444 0202',
    bio: 'Interesada en emprendimiento y proyectos sociales.',
  ),
  UserProfile(
    id: 'u4',
    name: 'Diego Torres',
    universityEmail: 'diego.torres@universidad.edu',
    career: 'Ingeniería Industrial',
    semester: 8,
    skills: ['Procesos', 'Logística', 'Data Analysis'],
    contactChannel: ContactChannel.email,
    contactValue: 'diego.torres@universidad.edu',
    bio: 'Optimizando procesos con datos.',
  ),
  UserProfile(
    id: 'u5',
    name: 'Valentina Ríos',
    universityEmail: 'valentina.rios@universidad.edu',
    career: 'Psicología',
    semester: 3,
    skills: ['Investigación', 'Comunicación', 'Empatía'],
    contactChannel: ContactChannel.whatsapp,
    contactValue: '+57 304 777 0505',
    bio: 'Aprendiendo sobre UX research.',
  ),
  UserProfile(
    id: 'u6',
    name: 'Andrés Castillo',
    universityEmail: 'andres.castillo@universidad.edu',
    career: 'Ingeniería de Sistemas',
    semester: 9,
    skills: ['Flutter', 'Firebase', 'Clean Architecture'],
    contactChannel: ContactChannel.whatsapp,
    contactValue: '+57 305 222 0606',
    bio: 'Desarrollador móvil, fan de Flutter y Dart.',
  ),
  UserProfile(
    id: 'u7',
    name: 'Camila Restrepo',
    universityEmail: 'camila.restrepo@universidad.edu',
    career: 'Diseño Gráfico',
    semester: 6,
    skills: ['Figma', 'Motion Graphics', 'UX'],
    contactChannel: ContactChannel.email,
    contactValue: 'camila.restrepo@universidad.edu',
    bio: 'Diseño interfaces con foco en accesibilidad.',
  ),
  UserProfile(
    id: 'u8',
    name: 'Santiago Mejía',
    universityEmail: 'santiago.mejia@universidad.edu',
    career: 'Ingeniería Industrial',
    semester: 5,
    skills: ['Logística', 'Excel', 'Power BI'],
    contactChannel: ContactChannel.whatsapp,
    contactValue: '+57 306 333 0707',
    bio: 'Me interesan los proyectos de optimización.',
  ),
  UserProfile(
    id: 'u9',
    name: 'Daniela Vargas',
    universityEmail: 'daniela.vargas@universidad.edu',
    career: 'Comunicación Social',
    semester: 4,
    skills: ['Redacción', 'Locución', 'Marketing'],
    contactChannel: ContactChannel.whatsapp,
    contactValue: '+57 307 444 0808',
    bio: 'Cuento historias que conectan con la gente.',
  ),
  UserProfile(
    id: 'u10',
    name: 'Mateo Herrera',
    universityEmail: 'mateo.herrera@universidad.edu',
    career: 'Ingeniería de Sistemas',
    semester: 2,
    skills: ['Python', 'Machine Learning', 'SQL'],
    contactChannel: ContactChannel.email,
    contactValue: 'mateo.herrera@universidad.edu',
    bio: 'Empezando en ciencia de datos.',
  ),
  UserProfile(
    id: 'u11',
    name: 'Isabella Ospina',
    universityEmail: 'isabella.ospina@universidad.edu',
    career: 'Administración',
    semester: 7,
    skills: ['Gestión de proyectos', 'Scrum', 'Finanzas'],
    contactChannel: ContactChannel.whatsapp,
    contactValue: '+57 308 555 0909',
    bio: 'Lidero equipos hacia entregas a tiempo.',
  ),
  UserProfile(
    id: 'u12',
    name: 'Sara Lucía Peña',
    universityEmail: 'sara.pena@universidad.edu',
    career: 'Psicología',
    semester: 2,
    skills: ['Empatía', 'Escucha activa', 'Investigación'],
    contactChannel: ContactChannel.email,
    contactValue: 'sara.pena@universidad.edu',
    bio: 'Interesada en bienestar universitario.',
  ),
];

/// Publicaciones iniciales del tablero.
List<Posting> buildMockPostings() {
  final now = DateTime.now();
  return [
    Posting(
      id: 'p1',
      authorId: 'u1',
      authorName: 'María Fernanda Gómez',
      authorCareer: 'Diseño Gráfico',
      type: PostType.buscaEquipo,
      title: 'Busco desarrollador para app de reciclaje',
      description:
          'Estoy armando el prototipo de una app que conecta recicladores con '
          'hogares. Ya tengo el diseño en Figma, necesito a alguien que lo '
          'lleve a Flutter para el trabajo final de Diseño.',
      targetCareer: 'Ingeniería de Sistemas',
      createdAt: now.subtract(const Duration(hours: 3)),
      applicantIds: const ['u5'],
    ),
    Posting(
      id: 'p2',
      authorId: 'u2',
      authorName: 'Carlos Andrés Pérez',
      authorCareer: 'Ingeniería de Sistemas',
      type: PostType.grupoEstudio,
      title: 'Grupo de estudio para parcial de Bases de Datos',
      description:
          'Nos reunimos los martes y jueves a las 6pm en la biblioteca para '
          'repasar normalización, SQL y transacciones. Buscamos 2 personas más.',
      targetCareer: 'Ingeniería de Sistemas',
      location: 'Biblioteca central, sala 3',
      createdAt: now.subtract(const Duration(hours: 8)),
      applicantIds: const ['u4', 'me'],
      acceptedIds: const ['me'],
    ),
    Posting(
      id: 'p3',
      authorId: 'u3',
      authorName: 'Laura Sofía Ramírez',
      authorCareer: 'Administración',
      type: PostType.evento,
      title: 'Charla: cómo financiar tu emprendimiento',
      description:
          'Este viernes a las 4pm en el auditorio principal. Invitados del '
          'ecosistema emprendedor del campus. Entrada libre con registro.',
      location: 'Auditorio principal',
      createdAt: now.subtract(const Duration(days: 1, hours: 2)),
    ),
    Posting(
      id: 'p4',
      authorId: 'me',
      authorName: 'Alex Rivera',
      authorCareer: 'Ingeniería de Sistemas',
      type: PostType.buscaEquipo,
      title: 'Necesito diseñador UX para proyecto de tesis',
      description:
          'Mi proyecto de grado es una app de transporte universitario. '
          'Busco un perfil de diseño para el research y los wireframes.',
      targetCareer: 'Diseño Gráfico',
      createdAt: now.subtract(const Duration(days: 2)),
      applicantIds: const ['u1', 'u5'],
    ),
    Posting(
      id: 'p5',
      authorId: 'u6',
      authorName: 'Andrés Castillo',
      authorCareer: 'Ingeniería de Sistemas',
      type: PostType.buscaEquipo,
      title: 'Busco backend en Node para app de tutorías',
      description:
          'Armo junto a Camila el frontend de una app de tutorías entre '
          'estudiantes. Necesito un perfil de backend que monte la API y la '
          'base de datos para la entrega final.',
      targetCareer: 'Ingeniería de Sistemas',
      createdAt: now.subtract(const Duration(hours: 5)),
      applicantIds: const ['u2', 'u10', 'me'],
      acceptedIds: const ['me'],
    ),
    Posting(
      id: 'p6',
      authorId: 'u7',
      authorName: 'Camila Restrepo',
      authorCareer: 'Diseño Gráfico',
      type: PostType.buscaEquipo,
      title: 'Busco desarrollador Flutter para rediseño de portafolio',
      description:
          'Tengo el rediseño visual listo en Figma y quiero pasarlo a una app '
          'web en Flutter. Busco a alguien que domine widgets y animaciones.',
      targetCareer: 'Ingeniería de Sistemas',
      createdAt: now.subtract(const Duration(hours: 12)),
      applicantIds: const ['u6'],
    ),
    Posting(
      id: 'p7',
      authorId: 'u11',
      authorName: 'Isabella Ospina',
      authorCareer: 'Administración',
      type: PostType.grupoEstudio,
      title: 'Grupo de estudio para parcial de Finanzas',
      description:
          'Repasaremos VPN, TIR y flujo de caja. Nos juntamos miércoles y '
          'viernes a las 5pm. Buscamos 3 personas más.',
      targetCareer: 'Administración',
      location: 'Biblioteca, sala 6',
      createdAt: now.subtract(const Duration(hours: 6)),
      applicantIds: const ['u3'],
    ),
    Posting(
      id: 'p8',
      authorId: 'u10',
      authorName: 'Mateo Herrera',
      authorCareer: 'Ingeniería de Sistemas',
      type: PostType.grupoEstudio,
      title: 'Preparación del parcial de Cálculo Multivariable',
      description:
          'Resolveremos ejercicios de la lista y exámenes pasados. Nos '
          'reunimos en el bloque de aulas, martes 4pm.',
      targetCareer: 'Ingeniería de Sistemas',
      location: 'Bloque B, aula 204',
      createdAt: now.subtract(const Duration(hours: 14)),
      applicantIds: const ['u4', 'u6'],
      acceptedIds: const ['u6'],
    ),
    Posting(
      id: 'p9',
      authorId: 'u12',
      authorName: 'Sara Lucía Peña',
      authorCareer: 'Psicología',
      type: PostType.grupoEstudio,
      title: 'Grupo para practicar entrevistas de UX research',
      description:
          'Busco compañeros para role-play de entrevistas y análisis de '
          'resultados. Nos vemos jueves a las 3pm.',
      targetCareer: 'Psicología',
      location: 'Sala de estudio 2',
      createdAt: now.subtract(const Duration(hours: 20)),
      applicantIds: const ['u5', 'u1'],
    ),
    Posting(
      id: 'p10',
      authorId: 'u9',
      authorName: 'Daniela Vargas',
      authorCareer: 'Comunicación Social',
      type: PostType.evento,
      title: 'Taller de oratoria y presentaciones efectivas',
      description:
          'Taller gratuito este sábado a las 10am en el auditorio auxiliar. '
          'Cupos limitados, trae tu credencial.',
      location: 'Auditorio auxiliar',
      createdAt: now.subtract(const Duration(days: 1, hours: 5)),
    ),
    Posting(
      id: 'p11',
      authorId: 'u8',
      authorName: 'Santiago Mejía',
      authorCareer: 'Ingeniería Industrial',
      type: PostType.evento,
      title: 'Feria de emprendimiento e innovación',
      description:
          'El campus reúne proyectos estudiantiles y empresas. Jueves y '
          'viernes en la plazoleta central, entrada libre.',
      location: 'Plazoleta central',
      createdAt: now.subtract(const Duration(days: 2, hours: 4)),
    ),
    Posting(
      id: 'p12',
      authorId: 'u6',
      authorName: 'Andrés Castillo',
      authorCareer: 'Ingeniería de Sistemas',
      type: PostType.buscaEquipo,
      title: 'Hackathon: busco equipo de 3 para reto de impacto social',
      description:
          'La universidad organiza un hackathon de 24 horas. Quiero armar un '
          'equipo con diseño, backend y comunicación.',
      targetCareer: 'Diseño Gráfico',
      createdAt: now.subtract(const Duration(minutes: 45)),
      applicantIds: const ['u7', 'u9'],
    ),
  ];
}
