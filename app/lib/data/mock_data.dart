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
  ];
}
