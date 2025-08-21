# FitHome Pro - Aplicación de Fitness en Python

Una aplicación completa de fitness convertida de React/TypeScript a Python usando Streamlit.

## Características

- 🏠 **Dashboard Principal**: Estadísticas diarias, hidratación, entrenamientos recomendados
- 💪 **Entrenamientos**: Rutinas de cardio, fuerza, yoga y core con seguimiento en tiempo real
- 🍎 **Nutrición**: Planes alimenticios personalizados con recetas saludables
- 👶 **Zona Infantil**: Actividades DIY, ejercicios y manualidades para niños
- 🎬 **Películas Premium**: Documentales motivacionales y contenido educativo
- 📊 **Progreso**: Seguimiento de estadísticas, racha de días, logros y metas

## Funcionalidades

### Sistema de Usuario
- Registro e inicio de sesión
- Proceso de onboarding personalizado
- Perfiles adaptados por género con temas visuales

### Seguimiento de Actividad
- Contador de entrenamientos completados
- Seguimiento de calorías quemadas
- Sistema de racha de días consecutivos
- Progreso semanal y mensual
- Registro de peso corporal

### Entrenamientos Interactivos
- Rutinas guiadas paso a paso
- Timer integrado para ejercicios
- Sistema de logros y recompensas
- Diferentes niveles de dificultad

### Contenido Premium
- Biblioteca de películas motivacionales
- Documentales educativos sobre fitness
- Contenido exclusivo sin anuncios

## Instalación

1. **Clonar o descargar los archivos**
2. **Instalar dependencias:**
   \`\`\`bash
   pip install -r requirements.txt
   \`\`\`

3. **Ejecutar la aplicación:**
   \`\`\`bash
   python run.py
   \`\`\`
   
   O directamente con Streamlit:
   \`\`\`bash
   streamlit run fitness_app.py
   \`\`\`

4. **Abrir en el navegador:**
   - La aplicación se abrirá automáticamente en `http://localhost:8501`

## Uso

### Primer Uso
1. **Registro**: Crea una cuenta nueva con tu email y contraseña
2. **Onboarding**: Completa el proceso de configuración (género, edad, peso, objetivos)
3. **Dashboard**: Explora las diferentes secciones de la aplicación

### Navegación
- Usa la barra lateral para navegar entre secciones
- El dashboard principal muestra tu progreso diario
- Cada sección tiene funcionalidades específicas

### Entrenamientos
1. Ve a la sección "💪 Entrenamientos"
2. Selecciona una rutina que te interese
3. Haz clic en "▶️ Iniciar" para comenzar
4. Sigue las instrucciones paso a paso
5. Completa el entrenamiento para ganar estadísticas

### Seguimiento de Progreso
- Registra tu hidratación diaria en el dashboard
- Completa entrenamientos para aumentar tu racha
- Revisa tus estadísticas en la sección "📊 Progreso"
- Registra tu peso para hacer seguimiento

## Estructura del Código

### Componentes Principales
- `fitness_app.py`: Aplicación principal con todas las funcionalidades
- `requirements.txt`: Dependencias de Python necesarias
- `run.py`: Script de ejecución simplificado

### Clases de Datos
- `UserProfile`: Información del usuario (nombre, email, objetivos, etc.)
- `UserStats`: Estadísticas de progreso (entrenamientos, calorías, racha)
- `Workout`: Estructura de rutinas de ejercicio
- `KidsActivity`: Actividades para la zona infantil
- `Movie`: Películas del contenido premium

### Funciones Principales
- `init_session_state()`: Inicializa el estado de la sesión
- `complete_workout()`: Procesa la finalización de entrenamientos
- `get_theme_colors()`: Temas visuales por género
- Pantallas: `loading_screen()`, `auth_screen()`, `onboarding_screen()`, `dashboard()`

## Diferencias con la Versión Original

### Adaptaciones para Python/Streamlit
- **Navegación**: Sidebar en lugar de tabs inferiores (más apropiado para web)
- **Interactividad**: Botones de Streamlit en lugar de eventos táctiles
- **Estilos**: CSS personalizado adaptado a las capacidades de Streamlit
- **Estado**: `st.session_state` para mantener datos entre interacciones
- **Gráficos**: Matplotlib para visualizaciones de progreso

### Funcionalidades Mantenidas
- ✅ Sistema completo de autenticación
- ✅ Proceso de onboarding personalizado
- ✅ Seguimiento de entrenamientos y estadísticas
- ✅ Sistema de logros y racha de días
- ✅ Contenido premium con películas
- ✅ Zona infantil con actividades
- ✅ Planes nutricionales
- ✅ Temas visuales por género

### Mejoras Añadidas
- 📊 Gráficos de progreso semanal con Matplotlib
- 🔄 Persistencia de datos durante la sesión
- 🎨 Estilos CSS mejorados para web
- 📱 Diseño responsivo adaptado a navegadores

## Tecnologías Utilizadas

- **Python 3.8+**: Lenguaje principal
- **Streamlit**: Framework para la interfaz web interactiva
- **Matplotlib**: Visualización de gráficos y estadísticas
- **Dataclasses**: Estructuras de datos organizadas
- **CSS**: Estilos personalizados para la interfaz

## Próximas Mejoras

- 💾 Persistencia de datos con base de datos
- 🔔 Sistema de notificaciones
- 📱 Versión móvil optimizada
- 🤝 Funciones sociales y competencias
- 🎵 Integración con música para entrenamientos
- 📈 Análisis avanzado de progreso
