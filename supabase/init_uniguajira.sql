-- =============================================================================
-- Match Universitario · Universidad de La Guajira (Uniguajira)
-- Esquema PostgreSQL + Políticas RLS (Supabase) + Semilla de Demostración
-- =============================================================================

-- 1. TABLA DE PERFILES DE ESTUDIANTES (profiles)
CREATE TABLE IF NOT EXISTS public.profiles (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  university_email TEXT NOT NULL DEFAULT '',
  career TEXT NOT NULL DEFAULT '',
  semester INT NOT NULL DEFAULT 1,
  skills TEXT[] NOT NULL DEFAULT '{}',
  contact_channel TEXT NOT NULL DEFAULT 'whatsapp',
  contact_value TEXT NOT NULL DEFAULT '',
  bio TEXT NOT NULL DEFAULT '',
  headline TEXT NOT NULL DEFAULT '',
  faculty TEXT NOT NULL DEFAULT 'Facultad de Ingeniería',
  campus TEXT NOT NULL DEFAULT 'Sede Riohacha',
  availability TEXT NOT NULL DEFAULT 'Disponible para Proyectos y Estudio',
  diplomas TEXT[] NOT NULL DEFAULT '{}',
  projects TEXT[] NOT NULL DEFAULT '{}',
  languages TEXT[] NOT NULL DEFAULT ARRAY['Español'],
  portfolio_url TEXT NOT NULL DEFAULT '',
  avatar_url TEXT,
  photo_base64 TEXT,
  banner_preset INT NOT NULL DEFAULT 0,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_profiles_email
  ON public.profiles (LOWER(university_email));

-- 2. TABLA DE CONVOCATORIAS / PUBLICACIONES (postings)
CREATE TABLE IF NOT EXISTS public.postings (
  id TEXT PRIMARY KEY,
  author_id TEXT NOT NULL,
  author_name TEXT NOT NULL,
  author_career TEXT NOT NULL,
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  target_career TEXT,
  location TEXT,
  applicant_ids TEXT[] NOT NULL DEFAULT '{}',
  accepted_ids TEXT[] NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_postings_created_at
  ON public.postings (created_at DESC);

CREATE INDEX IF NOT EXISTS idx_postings_author_id
  ON public.postings (author_id);

-- 3. ROW LEVEL SECURITY (RLS) PARA SUPABASE (Lectura y escritura abierta para el MVP)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.postings ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public' AND tablename = 'profiles' AND policyname = 'profiles_public_access'
  ) THEN
    CREATE POLICY profiles_public_access ON public.profiles
      FOR ALL USING (true) WITH CHECK (true);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public' AND tablename = 'postings' AND policyname = 'postings_public_access'
  ) THEN
    CREATE POLICY postings_public_access ON public.postings
      FOR ALL USING (true) WITH CHECK (true);
  END IF;
END $$;

-- Permisos para roles de Supabase (si existen en el motor)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'anon') THEN
    GRANT SELECT, INSERT, UPDATE, DELETE ON public.profiles TO anon;
    GRANT SELECT, INSERT, UPDATE, DELETE ON public.postings TO anon;
  END IF;
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'authenticated') THEN
    GRANT SELECT, INSERT, UPDATE, DELETE ON public.profiles TO authenticated;
    GRANT SELECT, INSERT, UPDATE, DELETE ON public.postings TO authenticated;
  END IF;
END $$;

-- 4. SEMILLA INICIAL DE PERFILES DE DEMOSTRACIÓN (13 estudiantes de Uniguajira)
INSERT INTO public.profiles (
  id, name, university_email, career, semester, skills,
  contact_channel, contact_value, bio, headline, faculty, campus,
  availability, diplomas, projects, languages, portfolio_url, banner_preset
) VALUES
(
  'u13', 'Alex Rivera', 'alex.rivera@uniguajira.edu.co', 'Ingeniería de Sistemas', 6,
  ARRAY['Flutter', 'Dart', 'UI/UX', 'PostgreSQL'],
  'whatsapp', '+57 300 123 4567',
  'Busco equipo para proyectos de desarrollo móvil e impacto regional en La Guajira.',
  'Desarrollador Mobile Flutter · Semillero de Innovación',
  'Facultad de Ingeniería', 'Sede Riohacha', 'Buscando equipo de Tesis',
  ARRAY['Diplomado en Desarrollo de Apps Móviles', 'Semillero de Investigación en IA Aplicada'],
  ARRAY['App de Transporte Estudiantil Uniguajira', 'Ganador 2° puesto Hackathon Caribe'],
  ARRAY['Español', 'Inglés B1'], 'github.com/alexrivera-dev', 0
),
(
  'u1', 'María Fernanda Gómez', 'maria.gomez@uniguajira.edu.co', 'Diseño Gráfico', 5,
  ARRAY['Figma', 'Branding', 'Ilustración', 'Design Systems'],
  'whatsapp', '+57 301 555 0101',
  'Diseñadora enfocada en producto digital, experiencia de usuario e identidad cultural.',
  'Product Designer UI/UX · Creativa Visual',
  'Facultad de Ciencias Sociales y Humanas', 'Sede Riohacha', 'Disponible para Hackathons y Proyectos',
  ARRAY['Diplomado en Diseño UX/UI Centrado en el Usuario', 'Certificación Google UX Design'],
  ARRAY['Rediseño App Reciclaje Guajira Verde', 'Identidad Visual Feria Cultural Wayuu'],
  ARRAY['Español', 'Inglés B2'], 'behance.net/mafe-ux', 1
),
(
  'u2', 'Carlos Andrés Pérez', 'carlos.perez@uniguajira.edu.co', 'Ingeniería de Sistemas', 7,
  ARRAY['Backend', 'Node.js', 'PostgreSQL', 'Docker'],
  'email', 'carlos.perez@uniguajira.edu.co',
  'Apasionado por arquitectura backend, bases de datos relacionales y despliegue en contenedores.',
  'Arquitecto Backend & Bases de Datos · Monitor Académico',
  'Facultad de Ingeniería', 'Sede Riohacha', 'Abierto a Grupos de Estudio y Tesis',
  ARRAY['Diplomado en Arquitectura Cloud y Microservicios', 'Monitor Académico de Bases de Datos II'],
  ARRAY['API REST de Gestión de Tutorías', 'Sistema de Inventario con PostgreSQL y Docker'],
  ARRAY['Español', 'Inglés B1'], 'github.com/carlosperez-db', 2
),
(
  'u3', 'Laura Sofía Ramírez', 'laura.ramirez@uniguajira.edu.co', 'Administración de Empresas', 4,
  ARRAY['Finanzas', 'Excel', 'Liderazgo', 'Pitch Deck'],
  'whatsapp', '+57 302 444 0202',
  'Interesada en emprendimiento tecnológico, modelos de negocio sostenibles y proyectos sociales.',
  'Estrategia de Negocios & Finanzas · Líder de Emprendimiento',
  'Facultad de Ciencias Económicas y Administrativas', 'Sede Riohacha', 'Disponible para Proyectos e Innovación',
  ARRAY['Diplomado en Formulación de Proyectos de Inversión', 'Semillero de Emprendimiento Uniguajira'],
  ARRAY['Coordinadora Charla Financiamiento Emprendedor', 'Modelo Financiero para Startups Estudiantiles'],
  ARRAY['Español', 'Wayuunaiki'], 'linkedin.com/in/laurasofia-admin', 3
),
(
  'u4', 'Diego Torres', 'diego.torres@uniguajira.edu.co', 'Ingeniería Industrial', 8,
  ARRAY['Procesos', 'Logística', 'Data Analysis', 'Power BI'],
  'email', 'diego.torres@uniguajira.edu.co',
  'Optimizando procesos logísticos e industriales mediante analítica de datos.',
  'Analista de Datos y Procesos · 8° Semestre',
  'Facultad de Ingeniería', 'Sede Maicao', 'Buscando equipo de Tesis',
  ARRAY['Diplomado en Gerencia de Operaciones y Logística', 'Curso Avanzado de Power BI y Python para Datos'],
  ARRAY['Dashboard de Eficiencia Logística Portuaria'],
  ARRAY['Español', 'Inglés B2'], '', 0
),
(
  'u5', 'Valentina Ríos', 'valentina.rios@uniguajira.edu.co', 'Psicología', 3,
  ARRAY['Investigación', 'Comunicación', 'UX Research', 'Empatía'],
  'whatsapp', '+57 304 777 0505',
  'Investigando cómo las personas interactúan con la tecnología y el bienestar estudiantil.',
  'Psicología & UX Research · Semillero Cognitivo',
  'Facultad de Ciencias Sociales y Humanas', 'Sede Riohacha', 'Disponible para Proyectos Interdisciplinarios',
  ARRAY['Semillero de Psicología Social y Comunitaria', 'Taller de Métodos Cualitativos y Entrevistas'],
  ARRAY['Estudio de Bienestar Universitario en Época de Parciales'],
  ARRAY['Español'], '', 1
),
(
  'u6', 'Andrés Castillo', 'andres.castillo@uniguajira.edu.co', 'Ingeniería de Sistemas', 9,
  ARRAY['Flutter', 'Firebase', 'Clean Architecture', 'Git'],
  'whatsapp', '+57 305 222 0606',
  'Desarrollador móvil de último año, fan de Flutter, Dart y hackathons de impacto social.',
  'Tech Lead Estudiantil · Flutter & Clean Architecture',
  'Facultad de Ingeniería', 'Sede Riohacha', 'Armando equipo para Hackathon 24h',
  ARRAY['Diplomado en Ingeniería de Software Moderna', 'Mentor del Club de Programación Uniguajira'],
  ARRAY['Plataforma de Tutorías P2P entre Estudiantes', 'Finalista Maratón Nacional de Programación'],
  ARRAY['Español', 'Inglés C1'], 'github.com/andrescastillo-dev', 2
),
(
  'u7', 'Camila Restrepo', 'camila.restrepo@uniguajira.edu.co', 'Diseño Gráfico', 6,
  ARRAY['Figma', 'Motion Graphics', 'UX', 'Prototipado'],
  'email', 'camila.restrepo@uniguajira.edu.co',
  'Diseño interfaces accesibles y animaciones interactivas para productos digitales.',
  'UI Motion & Accesibilidad Digital',
  'Facultad de Ciencias Sociales y Humanas', 'Sede Riohacha', 'Disponible para Proyectos Web/Móvil',
  ARRAY['Diplomado en Animación Digital y Diseño Interactivo'],
  ARRAY['Portafolio Interactivo de Arte Guajiro'],
  ARRAY['Español', 'Inglés B1'], '', 3
),
(
  'u8', 'Santiago Mejía', 'santiago.mejia@uniguajira.edu.co', 'Ingeniería Industrial', 5,
  ARRAY['Logística', 'Excel', 'Power BI', 'Scrum'],
  'whatsapp', '+57 306 333 0707',
  'Me interesan los proyectos de optimización y las ferias de innovación en el campus.',
  'Gestión de Proyectos & Innovación Industrial',
  'Facultad de Ingeniería', 'Sede Fonseca', 'Organizador de Eventos y Equipos',
  ARRAY['Certificación Scrum Fundamentals'],
  ARRAY['Feria de Emprendimiento e Innovación Uniguajira'],
  ARRAY['Español'], '', 0
),
(
  'u9', 'Daniela Vargas', 'daniela.vargas@uniguajira.edu.co', 'Comunicación Social', 4,
  ARRAY['Redacción', 'Locución', 'Marketing Digital', 'Storytelling'],
  'whatsapp', '+57 307 444 0808',
  'Cuento historias que conectan con la gente. Apoyo en pitch y comunicación para equipos.',
  'Estratega de Comunicación & Pitch para Proyectos',
  'Facultad de Ciencias Sociales y Humanas', 'Sede Riohacha', 'Disponible para Pitch de Hackathons y Eventos',
  ARRAY['Diplomado en Comunicación Estratégica y Medios Digitales'],
  ARRAY['Taller de Oratoria y Presentaciones Efectivas'],
  ARRAY['Español', 'Wayuunaiki'], '', 1
),
(
  'u10', 'Mateo Herrera', 'mateo.herrera@uniguajira.edu.co', 'Ingeniería de Sistemas', 2,
  ARRAY['Python', 'Machine Learning', 'SQL', 'Cálculo'],
  'email', 'mateo.herrera@uniguajira.edu.co',
  'Empezando en ciencia de datos y armando grupos de estudio de matemáticas.',
  'Ciencia de Datos en Formación · Semillero IA',
  'Facultad de Ingeniería', 'Sede Riohacha', 'Abierto a Grupos de Estudio',
  ARRAY['Curso Intensivo de Python para Ciencia de Datos'],
  ARRAY['Análisis Predictivo de Deserción Estudiantil'],
  ARRAY['Español', 'Inglés B1'], '', 2
),
(
  'u11', 'Isabella Ospina', 'isabella.ospina@uniguajira.edu.co', 'Administración de Empresas', 7,
  ARRAY['Gestión de proyectos', 'Scrum', 'Finanzas Corporativas'],
  'whatsapp', '+57 308 555 0909',
  'Lidero equipos interdisciplinarios hacia entregas a tiempo con foco financiero.',
  'Project Manager Estudiantil · Finanzas',
  'Facultad de Ciencias Económicas y Administrativas', 'Sede Riohacha', 'Abierta a Grupos de Estudio y Proyectos',
  ARRAY['Diplomado en Gerencia Financiera y Evaluación de Proyectos'],
  ARRAY['Consultoría Junior para Mipymes de Riohacha'],
  ARRAY['Español', 'Inglés B2'], '', 3
),
(
  'u12', 'Sara Lucía Peña', 'sara.pena@uniguajira.edu.co', 'Psicología', 2,
  ARRAY['Empatía', 'Escucha activa', 'Investigación'],
  'email', 'sara.pena@uniguajira.edu.co',
  'Interesada en bienestar universitario e investigación social.',
  'Investigación Cualitativa & Bienestar',
  'Facultad de Ciencias Sociales y Humanas', 'Sede Villanueva', 'Disponible para Grupos de Estudio',
  ARRAY['Semillero de Investigación en Salud Mental'],
  ARRAY['Guía de Adaptación a la Vida Universitaria'],
  ARRAY['Español'], '', 1
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  university_email = EXCLUDED.university_email,
  career = EXCLUDED.career,
  semester = EXCLUDED.semester,
  skills = EXCLUDED.skills,
  contact_channel = EXCLUDED.contact_channel,
  contact_value = EXCLUDED.contact_value,
  bio = EXCLUDED.bio,
  headline = EXCLUDED.headline,
  faculty = EXCLUDED.faculty,
  campus = EXCLUDED.campus,
  availability = EXCLUDED.availability,
  diplomas = EXCLUDED.diplomas,
  projects = EXCLUDED.projects,
  languages = EXCLUDED.languages,
  portfolio_url = EXCLUDED.portfolio_url,
  banner_preset = EXCLUDED.banner_preset;

-- 5. SEMILLA INICIAL DE CONVOCATORIAS Y MATCHES DEL CAMPUS (12 avisos, 8 matches activos)
INSERT INTO public.postings (
  id, author_id, author_name, author_career, type, title, description,
  target_career, location, applicant_ids, accepted_ids, created_at
) VALUES
(
  'p1', 'u1', 'María Fernanda Gómez', 'Diseño Gráfico', 'buscaEquipo',
  'Busco desarrollador para app de reciclaje',
  'Estoy armando el prototipo de una app que conecta recicladores con hogares. Ya tengo el diseño en Figma, necesito a alguien que lo lleve a Flutter para el trabajo final de Diseño.',
  'Ingeniería de Sistemas', NULL,
  ARRAY['u5'], ARRAY[]::TEXT[], NOW() - INTERVAL '3 hours'
),
(
  'p2', 'u2', 'Carlos Andrés Pérez', 'Ingeniería de Sistemas', 'grupoEstudio',
  'Grupo de estudio para parcial de Bases de Datos',
  'Nos reunimos los martes y jueves a las 6pm en la biblioteca para repasar normalización, SQL y transacciones. Buscamos 2 personas más.',
  'Ingeniería de Sistemas', 'Biblioteca central, sala 3',
  ARRAY['u4', 'u13'], ARRAY['u13'], NOW() - INTERVAL '8 hours'
),
(
  'p3', 'u3', 'Laura Sofía Ramírez', 'Administración de Empresas', 'evento',
  'Charla: cómo financiar tu emprendimiento',
  'Este viernes a las 4pm en el auditorio principal. Invitados del ecosistema emprendedor del campus. Entrada libre con registro.',
  NULL, 'Auditorio principal',
  ARRAY[]::TEXT[], ARRAY[]::TEXT[], NOW() - INTERVAL '26 hours'
),
(
  'p4', 'u13', 'Alex Rivera', 'Ingeniería de Sistemas', 'buscaEquipo',
  'Necesito diseñador UX para proyecto de tesis',
  'Mi proyecto de grado es una app de transporte universitario. Busco un perfil de diseño para el research y los wireframes.',
  'Diseño Gráfico', NULL,
  ARRAY['u1', 'u5'], ARRAY['u1'], NOW() - INTERVAL '48 hours'
),
(
  'p5', 'u6', 'Andrés Castillo', 'Ingeniería de Sistemas', 'buscaEquipo',
  'Busco backend en Node para app de tutorías',
  'Armo junto a Camila el frontend de una app de tutorías entre estudiantes. Necesito un perfil de backend que monte la API y la base de datos para la entrega final.',
  'Ingeniería de Sistemas', NULL,
  ARRAY['u2', 'u10', 'u13'], ARRAY['u2'], NOW() - INTERVAL '5 hours'
),
(
  'p6', 'u7', 'Camila Restrepo', 'Diseño Gráfico', 'buscaEquipo',
  'Busco desarrollador Flutter para rediseño de portafolio',
  'Tengo el rediseño visual listo en Figma y quiero pasarlo a una app web en Flutter. Busco a alguien que domine widgets y animaciones.',
  'Ingeniería de Sistemas', NULL,
  ARRAY['u6', 'u13'], ARRAY['u6'], NOW() - INTERVAL '12 hours'
),
(
  'p7', 'u11', 'Isabella Ospina', 'Administración de Empresas', 'grupoEstudio',
  'Grupo de estudio para parcial de Finanzas',
  'Repasaremos VPN, TIR y flujo de caja. Nos juntamos miércoles y viernes a las 5pm. Buscamos 3 personas más.',
  'Administración de Empresas', 'Biblioteca, sala 6',
  ARRAY['u3', 'u8'], ARRAY['u3'], NOW() - INTERVAL '6 hours'
),
(
  'p8', 'u10', 'Mateo Herrera', 'Ingeniería de Sistemas', 'grupoEstudio',
  'Preparación del parcial de Cálculo Multivariable',
  'Resolveremos ejercicios de la lista y exámenes pasados. Nos reunimos en el bloque de aulas, martes 4pm.',
  'Ingeniería de Sistemas', 'Bloque B, aula 204',
  ARRAY['u4', 'u6'], ARRAY['u6'], NOW() - INTERVAL '14 hours'
),
(
  'p9', 'u12', 'Sara Lucía Peña', 'Psicología', 'grupoEstudio',
  'Grupo para practicar entrevistas de UX research',
  'Busco compañeros para role-play de entrevistas y análisis de resultados. Nos vemos jueves a las 3pm.',
  'Psicología', 'Sala de estudio 2',
  ARRAY['u5', 'u1'], ARRAY['u5'], NOW() - INTERVAL '20 hours'
),
(
  'p10', 'u9', 'Daniela Vargas', 'Comunicación Social', 'evento',
  'Taller de oratoria y presentaciones efectivas',
  'Taller gratuito este sábado a las 10am en el auditorio auxiliar. Cupos limitados, trae tu credencial.',
  NULL, 'Auditorio auxiliar',
  ARRAY[]::TEXT[], ARRAY[]::TEXT[], NOW() - INTERVAL '29 hours'
),
(
  'p11', 'u8', 'Santiago Mejía', 'Ingeniería Industrial', 'evento',
  'Feria de emprendimiento e innovación',
  'El campus reúne proyectos estudiantiles y empresas. Jueves y viernes en la plazoleta central, entrada libre.',
  NULL, 'Plazoleta central',
  ARRAY[]::TEXT[], ARRAY[]::TEXT[], NOW() - INTERVAL '52 hours'
),
(
  'p12', 'u6', 'Andrés Castillo', 'Ingeniería de Sistemas', 'buscaEquipo',
  'Hackathon: busco equipo de 3 para reto de impacto social',
  'La universidad organiza un hackathon de 24 horas. Quiero armar un equipo con diseño, backend y comunicación.',
  'Diseño Gráfico', NULL,
  ARRAY['u7', 'u9'], ARRAY['u7'], NOW() - INTERVAL '45 minutes'
)
ON CONFLICT (id) DO UPDATE SET
  author_id = EXCLUDED.author_id,
  author_name = EXCLUDED.author_name,
  author_career = EXCLUDED.author_career,
  type = EXCLUDED.type,
  title = EXCLUDED.title,
  description = EXCLUDED.description,
  target_career = EXCLUDED.target_career,
  location = EXCLUDED.location,
  applicant_ids = EXCLUDED.applicant_ids,
  accepted_ids = EXCLUDED.accepted_ids;
