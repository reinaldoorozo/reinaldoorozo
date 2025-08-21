import streamlit as st
import time
import datetime
from dataclasses import dataclass, field
from typing import List, Dict, Optional
import json

# Configuración de la página
st.set_page_config(
    page_title="FitHome Pro",
    page_icon="💪",
    layout="wide",
    initial_sidebar_state="collapsed"
)

# Estilos CSS personalizados
st.markdown("""
<style>
    .main-header {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        padding: 2rem;
        border-radius: 1rem;
        color: white;
        margin-bottom: 2rem;
    }
    
    .workout-card {
        background: white;
        padding: 1.5rem;
        border-radius: 1rem;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        margin-bottom: 1rem;
        border-left: 4px solid #667eea;
    }
    
    .stats-card {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        padding: 1.5rem;
        border-radius: 1rem;
        color: white;
        text-align: center;
        margin-bottom: 1rem;
    }
    
    .kids-card {
        background: linear-gradient(135deg, #ffeaa7 0%, #fab1a0 100%);
        padding: 1.5rem;
        border-radius: 1rem;
        color: #2d3436;
        margin-bottom: 1rem;
    }
    
    .premium-card {
        background: linear-gradient(135deg, #fdcb6e 0%, #e17055 100%);
        padding: 2rem;
        border-radius: 1rem;
        color: white;
        text-align: center;
        margin-bottom: 2rem;
    }
    
    .stButton > button {
        width: 100%;
        border-radius: 0.5rem;
        border: none;
        padding: 0.5rem 1rem;
        font-weight: 600;
    }
    
    .metric-container {
        background: white;
        padding: 1rem;
        border-radius: 0.5rem;
        box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        text-align: center;
    }
</style>
""", unsafe_allow_html=True)

# Clases de datos
@dataclass
class UserProfile:
    name: str = ""
    email: str = ""
    password: str = ""
    age: str = ""
    gender: str = ""
    goals: List[str] = field(default_factory=list)
    fitness_level: str = ""
    is_premium: bool = False
    weight: str = ""
    height: str = ""
    target_weight: str = ""

@dataclass
class UserStats:
    streak_days: int = 0
    total_workouts: int = 0
    total_calories: int = 0
    total_minutes: int = 0
    today_calories: int = 0
    today_minutes: int = 0
    weekly_progress: List[int] = field(default_factory=lambda: [0] * 7)
    weight_progress: List[float] = field(default_factory=list)
    achievements: List[str] = field(default_factory=list)
    last_workout_date: Optional[str] = None

@dataclass
class Workout:
    id: int
    name: str
    duration: str
    level: str
    calories: str
    image: str
    category: str
    description: str
    exercises: List[Dict]
    rating: float
    completions: int

@dataclass
class KidsActivity:
    id: int
    name: str
    type: str
    duration: str
    age: str
    image: str
    difficulty: str
    materials: List[str]
    steps: List[str]
    benefits: List[str]

@dataclass
class Movie:
    id: int
    title: str
    genre: str
    duration: str
    rating: float
    image: str
    description: str
    year: int
    cast: List[str]

# Inicialización del estado de la sesión
def init_session_state():
    if 'current_screen' not in st.session_state:
        st.session_state.current_screen = 'loading'
    if 'user' not in st.session_state:
        st.session_state.user = None
    if 'user_profile' not in st.session_state:
        st.session_state.user_profile = UserProfile()
    if 'user_stats' not in st.session_state:
        st.session_state.user_stats = UserStats()
    if 'onboarding_step' not in st.session_state:
        st.session_state.onboarding_step = 0
    if 'water_intake' not in st.session_state:
        st.session_state.water_intake = 0
    if 'selected_workout' not in st.session_state:
        st.session_state.selected_workout = None
    if 'workout_in_progress' not in st.session_state:
        st.session_state.workout_in_progress = False
    if 'current_exercise' not in st.session_state:
        st.session_state.current_exercise = 0
    if 'exercise_timer' not in st.session_state:
        st.session_state.exercise_timer = 30

# Datos de la aplicación
def get_workouts():
    return [
        Workout(
            id=1,
            name="Cardio HIIT Matutino",
            duration="20 min",
            level="Intermedio",
            calories="180-220",
            image="🔥",
            category="Cardio",
            description="Quema grasa rápidamente con intervalos de alta intensidad",
            exercises=[
                {"name": "Saltos de tijera", "duration": "45s", "rest": "15s"},
                {"name": "Burpees", "duration": "30s", "rest": "30s"},
                {"name": "Mountain climbers", "duration": "45s", "rest": "15s"},
                {"name": "Rodillas al pecho", "duration": "45s", "rest": "15s"}
            ],
            rating=4.8,
            completions=1250
        ),
        Workout(
            id=2,
            name="Fuerza Total Body",
            duration="35 min",
            level="Avanzado",
            calories="250-300",
            image="💪",
            category="Fuerza",
            description="Rutina completa para todo el cuerpo sin equipos",
            exercises=[
                {"name": "Push-ups", "sets": "3x12", "rest": "60s"},
                {"name": "Squats", "sets": "3x15", "rest": "60s"},
                {"name": "Plancha", "duration": "60s", "rest": "30s"},
                {"name": "Lunges", "sets": "3x10", "rest": "45s"}
            ],
            rating=4.9,
            completions=890
        ),
        Workout(
            id=3,
            name="Yoga Flow Relajante",
            duration="25 min",
            level="Principiante",
            calories="80-120",
            image="🧘‍♀️",
            category="Flexibilidad",
            description="Mejora tu flexibilidad y encuentra paz interior",
            exercises=[
                {"name": "Saludo al sol", "duration": "5 min"},
                {"name": "Guerrero I y II", "duration": "8 min"},
                {"name": "Postura del niño", "duration": "3 min"},
                {"name": "Savasana", "duration": "9 min"}
            ],
            rating=4.7,
            completions=2100
        ),
        Workout(
            id=4,
            name="Abs Definidos",
            duration="15 min",
            level="Intermedio",
            calories="100-140",
            image="🎯",
            category="Core",
            description="Fortalece tu core con ejercicios específicos",
            exercises=[
                {"name": "Crunches", "sets": "3x20", "rest": "30s"},
                {"name": "Plancha lateral", "duration": "30s cada lado", "rest": "30s"},
                {"name": "Bicicleta", "sets": "3x15", "rest": "30s"},
                {"name": "Dead bug", "sets": "3x10", "rest": "30s"}
            ],
            rating=4.6,
            completions=1680
        )
    ]

def get_kids_activities():
    return [
        KidsActivity(
            id=1,
            name="Torre de Bloques Gigante",
            type="Construcción",
            duration="30-45 min",
            age="6-12 años",
            image="🏗️",
            difficulty="Fácil",
            materials=["Cajas de cartón", "Cinta adhesiva", "Marcadores", "Tijeras"],
            steps=[
                "Reúne cajas de diferentes tamaños",
                "Decora cada caja con colores y patrones",
                "Apila las cajas de mayor a menor",
                "Prueba diferentes combinaciones",
                "¡Crea la torre más alta!"
            ],
            benefits=["Coordinación", "Creatividad", "Paciencia", "Planificación"]
        ),
        KidsActivity(
            id=2,
            name="Baile de los Animales",
            type="Ejercicio",
            duration="15-20 min",
            age="3-10 años",
            image="💃",
            difficulty="Fácil",
            materials=["Música divertida", "Espacio libre"],
            steps=[
                "Elige un animal (oso, rana, pájaro)",
                "Imita sus movimientos",
                "Añade música de fondo",
                "Cambia de animal cada 2 minutos",
                "¡Inventa nuevos movimientos!"
            ],
            benefits=["Ejercicio cardiovascular", "Coordinación", "Imaginación", "Diversión"]
        ),
        KidsActivity(
            id=3,
            name="Origami Mariposa",
            type="Manualidad",
            duration="20-30 min",
            age="8-14 años",
            image="🦋",
            difficulty="Intermedio",
            materials=["Papel cuadrado colorido", "Marcadores (opcional)"],
            steps=[
                "Dobla el papel por la mitad en diagonal",
                "Abre y dobla por la otra diagonal",
                "Forma un triángulo base",
                "Crea las alas con pliegues",
                "¡Decora tu mariposa!"
            ],
            benefits=["Concentración", "Precisión", "Paciencia", "Habilidades motoras finas"]
        )
    ]

def get_movies():
    return [
        Movie(
            id=1,
            title="El Poder de la Mente",
            genre="Documental Motivacional",
            duration="95 min",
            rating=4.8,
            image="🧠",
            description="Descubre cómo atletas de élite utilizan la mentalidad para superar límites",
            year=2023,
            cast=["Dr. Michael Johnson", "Serena Williams", "LeBron James"]
        ),
        Movie(
            id=2,
            title="Cocina Mediterránea Saludable",
            genre="Educativo Gastronómico",
            duration="120 min",
            rating=4.6,
            image="🍽️",
            description="Aprende secretos de la cocina mediterránea para una vida más saludable",
            year=2023,
            cast=["Chef María González", "Dr. Antonio López"]
        ),
        Movie(
            id=3,
            title="Mindfulness: El Arte de Vivir",
            genre="Bienestar y Meditación",
            duration="80 min",
            rating=4.9,
            image="🧘",
            description="Una guía completa para incorporar mindfulness en tu vida diaria",
            year=2024,
            cast=["Monje Thich Nhat Hanh", "Dr. Jon Kabat-Zinn"]
        )
    ]

# Funciones de utilidad
def get_theme_colors(gender):
    if gender == 'masculino':
        return {
            'primary': '#3B82F6',
            'secondary': '#DBEAFE',
            'accent': '#1D4ED8'
        }
    elif gender == 'femenino':
        return {
            'primary': '#EC4899',
            'secondary': '#FCE7F3',
            'accent': '#BE185D'
        }
    return {
        'primary': '#6366F1',
        'secondary': '#E0E7FF',
        'accent': '#4338CA'
    }

def complete_workout(workout):
    calories = int(workout.calories.split('-')[1]) if '-' in workout.calories else 200
    minutes = int(workout.duration.split()[0])
    
    # Actualizar estadísticas
    st.session_state.user_stats.total_workouts += 1
    st.session_state.user_stats.total_calories += calories
    st.session_state.user_stats.total_minutes += minutes
    st.session_state.user_stats.today_calories += calories
    st.session_state.user_stats.today_minutes += minutes
    
    # Actualizar racha
    today = datetime.date.today()
    if st.session_state.user_stats.last_workout_date:
        last_date = datetime.datetime.fromisoformat(st.session_state.user_stats.last_workout_date).date()
        days_diff = (today - last_date).days
        if days_diff == 1:
            st.session_state.user_stats.streak_days += 1
        elif days_diff > 1:
            st.session_state.user_stats.streak_days = 1
    else:
        st.session_state.user_stats.streak_days = 1
    
    st.session_state.user_stats.last_workout_date = today.isoformat()
    
    # Generar logros
    achievements = st.session_state.user_stats.achievements
    if st.session_state.user_stats.total_workouts == 1 and "🎉 Primer entrenamiento" not in achievements:
        achievements.append("🎉 Primer entrenamiento")
    if st.session_state.user_stats.total_workouts == 10 and "💪 10 entrenamientos" not in achievements:
        achievements.append("💪 10 entrenamientos")
    if st.session_state.user_stats.streak_days == 7 and "🔥 7 días seguidos" not in achievements:
        achievements.append("🔥 7 días seguidos")

# Pantallas de la aplicación
def loading_screen():
    st.markdown("""
    <div style="text-align: center; padding: 4rem 0;">
        <div style="font-size: 4rem; margin-bottom: 2rem;">💪</div>
        <h1 style="color: #667eea; margin-bottom: 1rem;">FitHome Pro</h1>
        <p style="color: #666; margin-bottom: 2rem;">Tu entrenador personal en casa</p>
        <div style="display: flex; justify-content: center; gap: 0.5rem;">
            <div style="width: 12px; height: 12px; background: #667eea; border-radius: 50%; animation: pulse 1.5s infinite;"></div>
            <div style="width: 12px; height: 12px; background: #667eea; border-radius: 50%; animation: pulse 1.5s infinite 0.3s;"></div>
            <div style="width: 12px; height: 12px; background: #667eea; border-radius: 50%; animation: pulse 1.5s infinite 0.6s;"></div>
        </div>
    </div>
    """, unsafe_allow_html=True)
    
    # Simular carga
    time.sleep(2)
    st.session_state.current_screen = 'auth'
    st.rerun()

def auth_screen():
    st.markdown("""
    <div style="text-align: center; margin-bottom: 3rem;">
        <div style="font-size: 3rem; margin-bottom: 1rem;">💪</div>
        <h1 style="color: #667eea;">FitHome Pro</h1>
        <p style="color: #666;">Tu entrenador personal en casa</p>
    </div>
    """, unsafe_allow_html=True)
    
    tab1, tab2 = st.tabs(["Iniciar Sesión", "Registrarse"])
    
    with tab1:
        st.subheader("Bienvenido de vuelta")
        email = st.text_input("Correo electrónico", key="login_email")
        password = st.text_input("Contraseña", type="password", key="login_password")
        
        if st.button("Iniciar Sesión", key="login_btn"):
            if email and password:
                st.session_state.user_profile.email = email
                st.session_state.user_profile.password = password
                st.session_state.user = {"email": email}
                
                if st.session_state.user_profile.gender:
                    st.session_state.current_screen = 'dashboard'
                else:
                    st.session_state.current_screen = 'onboarding'
                st.rerun()
    
    with tab2:
        st.subheader("Únete a la familia fitness")
        name = st.text_input("Nombre completo", key="register_name")
        email = st.text_input("Correo electrónico", key="register_email")
        password = st.text_input("Contraseña", type="password", key="register_password")
        
        if st.button("Registrarse", key="register_btn"):
            if name and email and password:
                st.session_state.user_profile.name = name
                st.session_state.user_profile.email = email
                st.session_state.user_profile.password = password
                st.session_state.current_screen = 'onboarding'
                st.rerun()

def onboarding_screen():
    questions = [
        {
            "title": "¿Cuál es tu género?",
            "type": "gender",
            "options": ["masculino", "femenino", "otro"]
        },
        {
            "title": "¿Cuál es tu edad?",
            "type": "age",
            "input": True
        },
        {
            "title": "¿Cuánto pesas actualmente?",
            "type": "weight",
            "input": True,
            "unit": "kg"
        },
        {
            "title": "¿Cuál es tu estatura?",
            "type": "height",
            "input": True,
            "unit": "cm"
        },
        {
            "title": "¿Cuál es tu nivel de fitness?",
            "type": "fitness_level",
            "options": ["principiante", "intermedio", "avanzado"]
        },
        {
            "title": "¿Cuáles son tus objetivos principales?",
            "type": "goals",
            "options": ["perder peso", "ganar músculo", "mantenerse en forma", "mejorar resistencia", "rehabilitación", "competir"],
            "multiple": True
        }
    ]
    
    current_question = questions[st.session_state.onboarding_step]
    
    st.markdown(f"""
    <div style="text-align: center; margin-bottom: 2rem;">
        <h2>Configuración</h2>
        <p>Paso {st.session_state.onboarding_step + 1} de {len(questions)}</p>
        <div style="background: #e5e7eb; height: 8px; border-radius: 4px; margin: 1rem 0;">
            <div style="background: #667eea; height: 8px; border-radius: 4px; width: {((st.session_state.onboarding_step + 1) / len(questions)) * 100}%;"></div>
        </div>
    </div>
    """, unsafe_allow_html=True)
    
    st.subheader(current_question["title"])
    
    if current_question.get("input"):
        value = st.number_input(
            f"Tu {current_question['type']}",
            min_value=0,
            key=f"onboarding_{current_question['type']}"
        )
        if value > 0:
            setattr(st.session_state.user_profile, current_question["type"], str(value))
    
    elif current_question.get("multiple"):
        selected_options = st.multiselect(
            "Selecciona tus objetivos:",
            current_question["options"],
            default=st.session_state.user_profile.goals
        )
        st.session_state.user_profile.goals = selected_options
    
    else:
        selected = st.radio(
            "Selecciona una opción:",
            current_question["options"],
            key=f"onboarding_{current_question['type']}"
        )
        setattr(st.session_state.user_profile, current_question["type"], selected)
    
    col1, col2 = st.columns([1, 1])
    
    with col1:
        if st.session_state.onboarding_step > 0:
            if st.button("Anterior"):
                st.session_state.onboarding_step -= 1
                st.rerun()
    
    with col2:
        # Verificar si la pregunta actual está respondida
        current_value = getattr(st.session_state.user_profile, current_question["type"])
        is_answered = (
            (current_question.get("multiple") and len(current_value) > 0) or
            (not current_question.get("multiple") and current_value)
        )
        
        if is_answered:
            if st.session_state.onboarding_step < len(questions) - 1:
                if st.button("Siguiente"):
                    st.session_state.onboarding_step += 1
                    st.rerun()
            else:
                if st.button("Empezar mi Viaje"):
                    st.session_state.user = st.session_state.user_profile.__dict__
                    st.session_state.current_screen = 'dashboard'
                    st.rerun()

def dashboard():
    # Sidebar para navegación
    with st.sidebar:
        st.markdown(f"""
        <div style="text-align: center; padding: 1rem; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 1rem; color: white; margin-bottom: 1rem;">
            <h3>¡Hola {st.session_state.user_profile.name or 'Usuario'}! 👋</h3>
            <p>Racha: {st.session_state.user_stats.streak_days} días 🔥</p>
        </div>
        """, unsafe_allow_html=True)
        
        page = st.selectbox(
            "Navegación",
            ["🏠 Inicio", "💪 Entrenamientos", "🍎 Nutrición", "👶 Zona Infantil", "🎬 Películas", "📊 Progreso"]
        )
    
    # Contenido principal basado en la página seleccionada
    if page == "🏠 Inicio":
        home_tab()
    elif page == "💪 Entrenamientos":
        workouts_tab()
    elif page == "🍎 Nutrición":
        nutrition_tab()
    elif page == "👶 Zona Infantil":
        kids_tab()
    elif page == "🎬 Películas":
        movies_tab()
    elif page == "📊 Progreso":
        stats_tab()

def home_tab():
    st.title("Dashboard Principal")
    
    # Header con estadísticas
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        st.markdown(f"""
        <div class="metric-container">
            <h3>{st.session_state.user_stats.streak_days}</h3>
            <p>Racha (días)</p>
        </div>
        """, unsafe_allow_html=True)
    
    with col2:
        st.markdown(f"""
        <div class="metric-container">
            <h3>{st.session_state.user_stats.today_calories}</h3>
            <p>Kcal hoy</p>
        </div>
        """, unsafe_allow_html=True)
    
    with col3:
        st.markdown(f"""
        <div class="metric-container">
            <h3>{st.session_state.user_stats.today_minutes}</h3>
            <p>Min hoy</p>
        </div>
        """, unsafe_allow_html=True)
    
    with col4:
        st.markdown(f"""
        <div class="metric-container">
            <h3>{st.session_state.user_stats.total_workouts}</h3>
            <p>Entrenamientos</p>
        </div>
        """, unsafe_allow_html=True)
    
    # Hidratación diaria
    st.subheader("💧 Hidratación Diaria")
    col1, col2 = st.columns([3, 1])
    
    with col1:
        water_progress = st.session_state.water_intake / 8
        st.progress(water_progress)
        st.write(f"{st.session_state.water_intake}/8 vasos")
    
    with col2:
        if st.button("+ Vaso"):
            if st.session_state.water_intake < 8:
                st.session_state.water_intake += 1
                st.rerun()
        if st.button("- Vaso"):
            if st.session_state.water_intake > 0:
                st.session_state.water_intake -= 1
                st.rerun()
    
    # Entrenamientos recomendados
    st.subheader("🔥 Entrenamientos Recomendados")
    workouts = get_workouts()[:2]
    
    for workout in workouts:
        with st.container():
            st.markdown(f"""
            <div class="workout-card">
                <div style="display: flex; justify-content: space-between; align-items: center;">
                    <div>
                        <h4>{workout.image} {workout.name}</h4>
                        <p>{workout.duration} • {workout.level} • {workout.calories} kcal</p>
                        <p style="color: #666; font-size: 0.9rem;">{workout.description}</p>
                        <p style="color: #999; font-size: 0.8rem;">⭐ {workout.rating} • {workout.completions:,} completados</p>
                    </div>
                </div>
            </div>
            """, unsafe_allow_html=True)
            
            if st.button(f"▶️ Iniciar {workout.name}", key=f"start_{workout.id}"):
                st.session_state.selected_workout = workout
                st.rerun()
    
    # Logros recientes
    if st.session_state.user_stats.achievements:
        st.subheader("🏆 Logros Recientes")
        for achievement in st.session_state.user_stats.achievements[-3:]:
            st.success(achievement)
    
    # Estado inicial sin entrenamientos
    if st.session_state.user_stats.total_workouts == 0:
        st.markdown("""
        <div style="text-align: center; padding: 2rem; background: white; border-radius: 1rem; margin: 2rem 0;">
            <div style="font-size: 3rem; margin-bottom: 1rem;">🏃‍♀️</div>
            <h3>¡Comienza tu Viaje Fitness!</h3>
            <p>Completa tu primer entrenamiento para empezar a ver tus estadísticas</p>
        </div>
        """, unsafe_allow_html=True)

def workouts_tab():
    st.title("💪 Mis Entrenamientos")
    
    # Filtros
    col1, col2, col3, col4 = st.columns(4)
    with col1:
        filter_all = st.button("Todos", key="filter_all")
    with col2:
        filter_cardio = st.button("Cardio", key="filter_cardio")
    with col3:
        filter_strength = st.button("Fuerza", key="filter_strength")
    with col4:
        filter_flexibility = st.button("Flexibilidad", key="filter_flexibility")
    
    workouts = get_workouts()
    
    for workout in workouts:
        with st.container():
            st.markdown(f"""
            <div class="workout-card">
                <div style="display: flex; justify-content: space-between; align-items: start;">
                    <div style="flex: 1;">
                        <h4>{workout.image} {workout.name}</h4>
                        <p><strong>{workout.category}</strong> • {workout.level}</p>
                        <p style="color: #666; margin: 0.5rem 0;">{workout.description}</p>
                        <div style="display: flex; gap: 1rem; font-size: 0.9rem; color: #999;">
                            <span>⏱️ {workout.duration}</span>
                            <span>⚡ {workout.calories} kcal</span>
                            <span>⭐ {workout.rating}</span>
                        </div>
                    </div>
                </div>
            </div>
            """, unsafe_allow_html=True)
            
            col1, col2 = st.columns([3, 1])
            with col2:
                if st.button(f"▶️ Iniciar", key=f"workout_{workout.id}"):
                    st.session_state.selected_workout = workout
                    st.rerun()

def nutrition_tab():
    st.title("🍎 Nutrición")
    
    # Plan nutricional actual
    st.markdown("""
    <div style="background: linear-gradient(135deg, #10b981 0%, #059669 100%); padding: 2rem; border-radius: 1rem; color: white; margin-bottom: 2rem;">
        <h3>Plan Pérdida de Peso</h3>
        <p>1500-1700 kcal/día</p>
        <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 1rem; margin-top: 1rem;">
            <div style="background: rgba(255,255,255,0.2); padding: 1rem; border-radius: 0.5rem; text-align: center;">
                <div style="font-weight: bold;">40%</div>
                <div style="font-size: 0.9rem;">Carbohidratos</div>
            </div>
            <div style="background: rgba(255,255,255,0.2); padding: 1rem; border-radius: 0.5rem; text-align: center;">
                <div style="font-weight: bold;">30%</div>
                <div style="font-size: 0.9rem;">Proteínas</div>
            </div>
            <div style="background: rgba(255,255,255,0.2); padding: 1rem; border-radius: 0.5rem; text-align: center;">
                <div style="font-weight: bold;">30%</div>
                <div style="font-size: 0.9rem;">Grasas</div>
            </div>
        </div>
    </div>
    """, unsafe_allow_html=True)
    
    # Comidas del día
    meals = [
        {
            "name": "Desayuno",
            "time": "07:00 - 09:00",
            "calories": "350 kcal",
            "items": [
                "Avena con frutas y nueces (250 kcal)",
                "Yogurt griego bajo en grasa (100 kcal)"
            ]
        },
        {
            "name": "Almuerzo",
            "time": "12:00 - 14:00",
            "calories": "450 kcal",
            "items": [
                "Ensalada de pollo a la plancha (300 kcal)",
                "Arroz integral (100 kcal)",
                "Vegetales al vapor (50 kcal)"
            ]
        },
        {
            "name": "Cena",
            "time": "19:00 - 21:00",
            "calories": "400 kcal",
            "items": [
                "Salmón a la plancha (250 kcal)",
                "Verduras salteadas (100 kcal)",
                "Quinoa (50 kcal)"
            ]
        }
    ]
    
    for meal in meals:
        with st.expander(f"🍽️ {meal['name']} - {meal['calories']}"):
            st.write(f"**Horario:** {meal['time']}")
            st.write("**Alimentos:**")
            for item in meal['items']:
                st.write(f"• {item}")
            if st.button(f"Ver receta de {meal['name']}", key=f"recipe_{meal['name']}"):
                st.info(f"Receta detallada para {meal['name']} - ¡Próximamente!")
    
    # Tips nutricionales
    st.subheader("💡 Tips del Día")
    tips = [
        "Bebe al menos 8 vasos de agua al día",
        "Evita azúcares refinados",
        "Come cada 3-4 horas"
    ]
    
    for tip in tips:
        st.info(f"• {tip}")

def kids_tab():
    st.title("👶 Zona Infantil")
    
    # Filtros
    col1, col2, col3, col4 = st.columns(4)
    with col1:
        st.button("Todos", key="kids_all")
    with col2:
        st.button("DIY", key="kids_diy")
    with col3:
        st.button("Ejercicio", key="kids_exercise")
    with col4:
        st.button("Manualidades", key="kids_crafts")
    
    activities = get_kids_activities()
    
    for activity in activities:
        with st.container():
            st.markdown(f"""
            <div class="kids-card">
                <div style="display: flex; justify-content: space-between; align-items: start; margin-bottom: 1rem;">
                    <div style="flex: 1;">
                        <h4>{activity.image} {activity.name}</h4>
                        <p><strong>{activity.type}</strong> • {activity.age}</p>
                        <p style="margin: 0.5rem 0;">{activity.duration}</p>
                        <span style="background: rgba(255,255,255,0.3); padding: 0.25rem 0.5rem; border-radius: 1rem; font-size: 0.8rem;">
                            {activity.difficulty}
                        </span>
                    </div>
                </div>
            </div>
            """, unsafe_allow_html=True)
            
            with st.expander(f"Ver detalles de {activity.name}"):
                st.write("**Materiales necesarios:**")
                for material in activity.materials:
                    st.write(f"• {material}")
                
                st.write("**Pasos a seguir:**")
                for i, step in enumerate(activity.steps, 1):
                    st.write(f"{i}. {step}")
                
                st.write("**Beneficios:**")
                for benefit in activity.benefits:
                    st.success(benefit)

def movies_tab():
    st.title("🎬 Películas Premium")
    
    if not st.session_state.user_profile.is_premium:
        st.markdown("""
        <div class="premium-card">
            <div style="font-size: 3rem; margin-bottom: 1rem;">👑</div>
            <h3>Contenido Premium</h3>
            <p>Accede a nuestra biblioteca completa de películas motivacionales y documentales educativos</p>
            <div style="margin: 1rem 0;">
                <p>✨ Más de 50 documentales</p>
                <p>🎬 Contenido exclusivo</p>
                <p>📱 Sin anuncios</p>
            </div>
        </div>
        """, unsafe_allow_html=True)
        
        if st.button("🔓 Obtener Premium - $9.99/mes", key="get_premium"):
            st.session_state.user_profile.is_premium = True
            st.success("¡Bienvenido a Premium! 🎉")
            st.rerun()
    else:
        movies = get_movies()
        
        for movie in movies:
            with st.container():
                st.markdown(f"""
                <div class="workout-card">
                    <div style="display: flex; justify-content: space-between; align-items: start;">
                        <div style="flex: 1;">
                            <h4>{movie.image} {movie.title}</h4>
                            <p><strong>{movie.genre}</strong> • {movie.year}</p>
                            <p style="color: #666; margin: 0.5rem 0;">{movie.description}</p>
                            <div style="display: flex; gap: 1rem; font-size: 0.9rem; color: #999;">
                                <span>⏱️ {movie.duration}</span>
                                <span>⭐ {movie.rating}</span>
                            </div>
                            <p style="font-size: 0.8rem; color: #999; margin-top: 0.5rem;">
                                Con: {', '.join(movie.cast)}
                            </p>
                        </div>
                    </div>
                </div>
                """, unsafe_allow_html=True)
                
                col1, col2, col3 = st.columns([2, 1, 1])
                with col1:
                    if st.button(f"▶️ Reproducir", key=f"play_{movie.id}"):
                        st.success(f"Reproduciendo: {movie.title}")
                with col2:
                    if st.button("📥", key=f"download_{movie.id}"):
                        st.info("Descarga iniciada")
                with col3:
                    if st.button("📤", key=f"share_{movie.id}"):
                        st.info("Enlace copiado")

def stats_tab():
    st.title("📊 Progreso")
    
    if st.session_state.user_stats.total_workouts == 0:
        st.markdown("""
        <div style="text-align: center; padding: 3rem; background: white; border-radius: 1rem;">
            <div style="font-size: 4rem; margin-bottom: 1rem;">📊</div>
            <h3>Sin datos aún</h3>
            <p>Completa algunos entrenamientos para ver tus estadísticas y gráficas de progreso</p>
        </div>
        """, unsafe_allow_html=True)
        
        if st.button("💪 Empezar Entrenando"):
            st.session_state.current_screen = 'workouts'
            st.rerun()
    else:
        # Estadísticas generales
        col1, col2 = st.columns(2)
        
        with col1:
            st.markdown(f"""
            <div class="stats-card">
                <h2>{st.session_state.user_stats.total_workouts}</h2>
                <p>Entrenamientos</p>
                <small>Total completados</small>
            </div>
            """, unsafe_allow_html=True)
        
        with col2:
            st.markdown(f"""
            <div style="background: linear-gradient(135deg, #10b981 0%, #059669 100%); padding: 1.5rem; border-radius: 1rem; color: white; text-align: center;">
                <h2>{st.session_state.user_stats.total_calories:,}</h2>
                <p>Calorías</p>
                <small>Quemadas</small>
            </div>
            """, unsafe_allow_html=True)
        
        # Progreso semanal
        st.subheader("📈 Actividad Semanal")
        days = ['L', 'M', 'X', 'J', 'V', 'S', 'D']
        weekly_data = st.session_state.user_stats.weekly_progress
        
        import matplotlib.pyplot as plt
        fig, ax = plt.subplots(figsize=(10, 4))
        ax.bar(days, weekly_data, color='#667eea')
        ax.set_ylabel('Minutos de actividad')
        ax.set_title('Actividad por día de la semana')
        st.pyplot(fig)
        
        # Metas del mes
        st.subheader("🎯 Metas del Mes")
        
        # Meta de entrenamientos
        workout_progress = min(100, (st.session_state.user_stats.total_workouts / 20) * 100)
        st.write(f"Entrenamientos ({st.session_state.user_stats.total_workouts}/20)")
        st.progress(workout_progress / 100)
        st.write(f"{workout_progress:.0f}% completado")
        
        # Botón para registrar peso
        if st.button("⚖️ Registrar Peso Actual"):
            weight = st.number_input("Peso actual (kg):", min_value=0.0, step=0.1)
            if weight > 0:
                if weight not in st.session_state.user_stats.weight_progress:
                    st.session_state.user_stats.weight_progress.append(weight)
                    st.success(f"Peso registrado: {weight} kg")
                    st.rerun()

# Pantalla de entrenamiento en progreso
def workout_screen():
    workout = st.session_state.selected_workout
    
    if not st.session_state.workout_in_progress:
        # Vista previa del entrenamiento
        st.markdown(f"""
        <div style="text-align: center; padding: 2rem; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border-radius: 1rem; margin-bottom: 2rem;">
            <div style="font-size: 4rem; margin-bottom: 1rem;">{workout.image}</div>
            <h2>{workout.name}</h2>
            <p>{workout.description}</p>
        </div>
        """, unsafe_allow_html=True)
        
        # Información del entrenamiento
        col1, col2, col3, col4 = st.columns(4)
        with col1:
            st.metric("Duración", workout.duration)
        with col2:
            st.metric("Calorías", workout.calories)
        with col3:
            st.metric("Nivel", workout.level)
        with col4:
            st.metric("Rating", f"⭐ {workout.rating}")
        
        # Lista de ejercicios
        st.subheader(f"Ejercicios ({len(workout.exercises)})")
        for i, exercise in enumerate(workout.exercises, 1):
            with st.container():
                st.markdown(f"""
                <div style="background: #f8f9fa; padding: 1rem; border-radius: 0.5rem; margin-bottom: 0.5rem; display: flex; align-items: center;">
                    <div style="background: #6c757d; color: white; width: 2rem; height: 2rem; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin-right: 1rem; font-weight: bold;">
                        {i}
                    </div>
                    <div>
                        <strong>{exercise['name']}</strong><br>
                        <small>{exercise.get('duration', exercise.get('sets', ''))}</small>
                        {f" • Descanso: {exercise['rest']}" if 'rest' in exercise else ""}
                    </div>
                </div>
                """, unsafe_allow_html=True)
        
        # Botones de acción
        col1, col2 = st.columns([1, 1])
        with col1:
            if st.button("⬅️ Volver"):
                st.session_state.selected_workout = None
                st.rerun()
        
        with col2:
            if st.button("▶️ Comenzar Entrenamiento"):
                st.session_state.workout_in_progress = True
                st.session_state.current_exercise = 0
                st.session_state.exercise_timer = 30
                st.rerun()
    
    else:
        # Entrenamiento en progreso
        current_ex = workout.exercises[st.session_state.current_exercise]
        
        st.markdown(f"""
        <div style="text-align: center; background: #000; color: white; padding: 2rem; border-radius: 1rem;">
            <h3>Ejercicio {st.session_state.current_exercise + 1}/{len(workout.exercises)}</h3>
            <h2>{current_ex['name']}</h2>
            <div style="font-size: 4rem; margin: 2rem 0;">{st.session_state.exercise_timer}</div>
            <div style="font-size: 2rem; margin-bottom: 2rem;">💪</div>
            <p>{current_ex.get('duration', current_ex.get('sets', ''))}</p>
        </div>
        """, unsafe_allow_html=True)
        
        col1, col2, col3 = st.columns([1, 1, 1])
        
        with col1:
            if st.button("⏸️ Pausar"):
                st.session_state.workout_in_progress = False
                st.rerun()
        
        with col2:
            if st.button("+10s"):
                st.session_state.exercise_timer += 10
                st.rerun()
        
        with col3:
            if st.session_state.current_exercise < len(workout.exercises) - 1:
                if st.button("⏭️ Siguiente"):
                    st.session_state.current_exercise += 1
                    st.session_state.exercise_timer = 30
                    st.rerun()
            else:
                if st.button("✅ Finalizar"):
                    complete_workout(workout)
                    st.session_state.workout_in_progress = False
                    st.session_state.selected_workout = None
                    st.session_state.current_exercise = 0
                    st.success(f"¡Felicitaciones! Has completado '{workout.name}'. +{workout.calories.split('-')[1] if '-' in workout.calories else '200'} kcal quemadas.")
                    time.sleep(2)
                    st.rerun()

# Función principal
def main():
    init_session_state()
    
    # Verificar si hay un entrenamiento seleccionado
    if st.session_state.selected_workout:
        workout_screen()
        return
    
    # Navegación principal
    if st.session_state.current_screen == 'loading':
        loading_screen()
    elif st.session_state.current_screen == 'auth':
        auth_screen()
    elif st.session_state.current_screen == 'onboarding':
        onboarding_screen()
    elif st.session_state.current_screen == 'dashboard':
        dashboard()

if __name__ == "__main__":
    main()
