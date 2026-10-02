[match_universitario_mvp_readme.md](https://github.com/user-attachments/files/32961473/match_universitario_mvp_readme.md)
# match_universitario# 🎓 Match Universitario

Match Universitario es una aplicación móvil diseñada para conectar estudiantes del mismo campus universitario. Permite encontrar compañeros con habilidades específicas de diferentes carreras para proyectos académicos, formar grupos de estudio y enterarse de eventos de la universidad de forma rápida y sencilla.

## 🚀 Alcance del MVP (Producto Mínimo Viable)

Para mantener el desarrollo ágil y cumplir con las fechas de entrega, el proyecto se enfoca en tres módulos principales, omitiendo intencionalmente sistemas complejos como mensajería en tiempo real.

1. **Perfiles Ligeros:**
   * Registro básico (Nombre, Correo universitario, Carrera, Semestre, Habilidades/Intereses).
   * Enlace de contacto principal (WhatsApp o correo).

2. **Tablero de Oportunidades (Feed):**
   * Feed central donde los estudiantes pueden ver y publicar 3 tipos de avisos:
     * 🛠️ **Busco Equipo:** Para proyectos o trabajos finales.
     * 📚 **Grupo de Estudio:** Para preparar parciales.
     * 📅 **Evento:** Actividades del campus.

3. **Sistema de "Match" Simple:**
   * Botón de **"Me interesa"** en las publicaciones.
   * El creador de la publicación recibe una notificación o lista de interesados.
   * Al **aceptar**, la app simplemente revela el contacto (WhatsApp/Email) para que la comunicación continúe fuera de la aplicación.

---

## 🛠️ Stack Tecnológico (Full-Stack Dart - Cero Costo)

El proyecto utiliza un ecosistema 100% basado en Dart para unificar el desarrollo frontend y backend, utilizando servicios con capa gratuita (Free Tier).

* **Frontend (Aplicación Móvil):**
  * **Framework:** Flutter (Dart)
  * **Gestor de Estado:** Provider 
  * **Diseño:** Material Design 3 (Componentes nativos de Flutter)

* **Backend (API REST):**
  * **Framework:** [Dart Frog](https://dartfrog.vgv.ventures/) (Minimalista, rápido y en Dart)
  * **Despliegue:** Contenedor Docker alojado en [Render](https://render.com/) o [Railway](https://railway.app/) (Capa gratuita).

* **Base de Datos:**
  * **Motor:** PostgreSQL.
  * **Hosting:** [Neon.tech](https://neon.tech/) o base de datos de [Supabase](https://supabase.com/) (Plan gratuito).

---

## 📂 Estructura del Repositorio

El proyecto se dividirá en dos carpetas principales dentro del mismo repositorio (Monorepo) o en repositorios separados para mantener el orden:

```text
/match_universitario
  /app        # Proyecto Flutter (Frontend)
  /api        # Proyecto Dart Frog (Backend)
  /shared     # (Opcional) Modelos de datos en Dart compartidos entre app y api
```

## 🔌 API Endpoints Principales (Propuesta)

La comunicación entre la app y el servidor será mediante peticiones HTTP simples:

* `POST /auth/login` - Autenticación de usuarios.
* `GET /posts` - Obtener el feed de publicaciones (con filtros por carrera).
* `POST /posts` - Crear una nueva publicación.
* `POST /match/apply` - Aplicar ("Me interesa") a una publicación.
* `GET /match/my-matches` - Ver quién ha aplicado a mis publicaciones y los contactos revelados.

---

## 💻 Instrucciones de Desarrollo Local

### Requisitos Previos
* Instalar [Flutter SDK](https://docs.flutter.dev/get-started/install)
* Instalar [Dart Frog CLI](https://dartfrog.vgv.ventures/docs/overview) (`dart pub global activate dart_frog_cli`)
* Base de datos PostgreSQL local o remota.

### Correr el Backend (API)
```bash
cd api
dart_frog dev
```
*El servidor correrá en `http://localhost:8080`*

### Correr el Frontend (App)
```bash
cd app
flutter pub get
flutter run
```
