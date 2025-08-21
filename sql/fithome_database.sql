-- ============================================
-- BASE DE DATOS FITHOME PRO
-- Sistema completo de fitness, nutrición y entretenimiento
-- ============================================

CREATE DATABASE fithome_pro;
USE fithome_pro;

-- ============================================
-- TABLAS DE USUARIOS Y AUTENTICACIÓN
-- ============================================

-- Tabla principal de usuarios
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    email_verified BOOLEAN DEFAULT FALSE,
    last_login TIMESTAMP NULL
);

-- Perfiles de usuario
CREATE TABLE user_profiles (
    profile_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    age INT,
    gender ENUM('masculino', 'femenino', 'otro'),
    height DECIMAL(5,2), -- en cm
    current_weight DECIMAL(5,2), -- en kg
    target_weight DECIMAL(5,2), -- en kg
    fitness_level ENUM('principiante', 'intermedio', 'avanzado'),
    is_premium BOOLEAN DEFAULT FALSE,
    premium_expires_at TIMESTAMP NULL,
    timezone VARCHAR(50) DEFAULT 'America/Bogota',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Objetivos de usuario (relación many-to-many)
CREATE TABLE goals (
    goal_id INT PRIMARY KEY AUTO_INCREMENT,
    goal_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_goals (
    user_goal_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    goal_id INT NOT NULL,
    priority INT DEFAULT 1, -- 1=alta, 2=media, 3=baja
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (goal_id) REFERENCES goals(goal_id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_goal (user_id, goal_id)
);

-- ============================================
-- ENTRENAMIENTOS Y EJERCICIOS
-- ============================================

-- Categorías de entrenamientos
CREATE TABLE workout_categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    icon_emoji VARCHAR(10),
    color_theme VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Entrenamientos
CREATE TABLE workouts (
    workout_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    category_id INT NOT NULL,
    duration_minutes INT NOT NULL,
    difficulty_level ENUM('principiante', 'intermedio', 'avanzado'),
    calories_min INT,
    calories_max INT,
    rating DECIMAL(3,2) DEFAULT 0.00,
    total_completions INT DEFAULT 0,
    is_premium BOOLEAN DEFAULT FALSE,
    image_emoji VARCHAR(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES workout_categories(category_id)
);

-- Ejercicios individuales
CREATE TABLE exercises (
    exercise_id INT PRIMARY KEY AUTO_INCREMENT,
    exercise_name VARCHAR(100) NOT NULL,
    description TEXT,
    muscle_groups JSON, -- ["chest", "shoulders", "triceps"]
    equipment_needed JSON, -- ["dumbbells", "mat"]
    difficulty_level ENUM('principiante', 'intermedio', 'avanzado'),
    instructions TEXT,
    safety_tips TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Relación workout-exercises con orden y configuración
CREATE TABLE workout_exercises (
    workout_exercise_id INT PRIMARY KEY AUTO_INCREMENT,
    workout_id INT NOT NULL,
    exercise_id INT NOT NULL,
    exercise_order INT NOT NULL,
    duration_seconds INT, -- para ejercicios de tiempo
    sets_count INT, -- para ejercicios de repeticiones
    reps_count INT, -- repeticiones por set
    rest_seconds INT,
    notes TEXT,
    FOREIGN KEY (workout_id) REFERENCES workouts(workout_id) ON DELETE CASCADE,
    FOREIGN KEY (exercise_id) REFERENCES exercises(exercise_id),
    UNIQUE KEY unique_workout_order (workout_id, exercise_order)
);

-- Historial de entrenamientos completados
CREATE TABLE workout_sessions (
    session_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    workout_id INT NOT NULL,
    started_at TIMESTAMP NOT NULL,
    completed_at TIMESTAMP,
    calories_burned INT,
    duration_minutes INT,
    difficulty_rating INT CHECK (difficulty_rating BETWEEN 1 AND 5),
    enjoyment_rating INT CHECK (enjoyment_rating BETWEEN 1 AND 5),
    notes TEXT,
    is_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (workout_id) REFERENCES workouts(workout_id)
);

-- Detalles de ejercicios en sesiones
CREATE TABLE session_exercise_details (
    detail_id INT PRIMARY KEY AUTO_INCREMENT,
    session_id INT NOT NULL,
    exercise_id INT NOT NULL,
    sets_completed INT,
    reps_completed INT,
    duration_seconds INT,
    weight_used DECIMAL(5,2), -- en kg
    difficulty_felt INT CHECK (difficulty_felt BETWEEN 1 AND 5),
    skipped BOOLEAN DEFAULT FALSE,
    notes TEXT,
    FOREIGN KEY (session_id) REFERENCES workout_sessions(session_id) ON DELETE CASCADE,
    FOREIGN KEY (exercise_id) REFERENCES exercises(exercise_id)
);

-- ============================================
-- NUTRICIÓN Y PLANES ALIMENTARIOS
-- ============================================

-- Planes nutricionales
CREATE TABLE nutrition_plans (
    plan_id INT PRIMARY KEY AUTO_INCREMENT,
    plan_name VARCHAR(100) NOT NULL,
    description TEXT,
    target_goal ENUM('perder_peso', 'ganar_musculo', 'mantener', 'definir'),
    daily_calories_min INT,
    daily_calories_max INT,
    carb_percentage INT,
    protein_percentage INT,
    fat_percentage INT,
    is_premium BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tipos de comidas
CREATE TABLE meal_types (
    meal_type_id INT PRIMARY KEY AUTO_INCREMENT,
    type_name VARCHAR(50) NOT NULL UNIQUE, -- desayuno, almuerzo, cena, snack
    recommended_time_start TIME,
    recommended_time_end TIME,
    typical_calories_percentage INT -- % del total diario
);

-- Comidas específicas
CREATE TABLE meals (
    meal_id INT PRIMARY KEY AUTO_INCREMENT,
    meal_name VARCHAR(150) NOT NULL,
    meal_type_id INT NOT NULL,
    plan_id INT NOT NULL,
    calories INT NOT NULL,
    preparation_time_minutes INT,
    difficulty_level ENUM('facil', 'intermedio', 'avanzado'),
    serves_people INT DEFAULT 1,
    instructions TEXT,
    nutritional_info JSON, -- {"protein": 25, "carbs": 45, "fat": 12, "fiber": 8}
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (meal_type_id) REFERENCES meal_types(meal_type_id),
    FOREIGN KEY (plan_id) REFERENCES nutrition_plans(plan_id) ON DELETE CASCADE
);

-- Ingredientes
CREATE TABLE ingredients (
    ingredient_id INT PRIMARY KEY AUTO_INCREMENT,
    ingredient_name VARCHAR(100) NOT NULL UNIQUE,
    category VARCHAR(50), -- proteina, vegetal, carbohidrato, grasa, etc.
    calories_per_100g INT,
    nutritional_info JSON, -- info nutricional por 100g
    is_allergen BOOLEAN DEFAULT FALSE,
    allergen_types JSON, -- ["gluten", "lactose", "nuts"]
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Relación meals-ingredients
CREATE TABLE meal_ingredients (
    meal_ingredient_id INT PRIMARY KEY AUTO_INCREMENT,
    meal_id INT NOT NULL,
    ingredient_id INT NOT NULL,
    quantity DECIMAL(8,2) NOT NULL, -- cantidad en gramos
    is_optional BOOLEAN DEFAULT FALSE,
    substitutes JSON, -- IDs de ingredientes sustitutos
    FOREIGN KEY (meal_id) REFERENCES meals(meal_id) ON DELETE CASCADE,
    FOREIGN KEY (ingredient_id) REFERENCES ingredients(ingredient_id)
);

-- Historial nutricional del usuario
CREATE TABLE user_nutrition_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    meal_id INT,
    date DATE NOT NULL,
    meal_type_id INT NOT NULL,
    calories_consumed INT,
    custom_meal_name VARCHAR(150), -- para comidas personalizadas
    custom_calories INT, -- para comidas personalizadas
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (meal_id) REFERENCES meals(meal_id),
    FOREIGN KEY (meal_type_id) REFERENCES meal_types(meal_type_id)
);

-- ============================================
-- ZONA INFANTIL - ACTIVIDADES
-- ============================================

-- Categorías de actividades para niños
CREATE TABLE kids_activity_categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) NOT NULL UNIQUE, -- construccion, ejercicio, manualidad, educativo
    description TEXT,
    icon_emoji VARCHAR(10),
    recommended_age_min INT,
    recommended_age_max INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Actividades para niños
CREATE TABLE kids_activities (
    activity_id INT PRIMARY KEY AUTO_INCREMENT,
    activity_name VARCHAR(150) NOT NULL,
    category_id INT NOT NULL,
    description TEXT,
    age_min INT NOT NULL,
    age_max INT NOT NULL,
    duration_minutes INT,
    difficulty_level ENUM('facil', 'intermedio', 'avanzado'),
    image_emoji VARCHAR(10),
    safety_level ENUM('bajo', 'medio', 'alto') DEFAULT 'bajo',
    adult_supervision BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES kids_activity_categories(category_id)
);

-- Materiales necesarios para actividades
CREATE TABLE activity_materials (
    material_id INT PRIMARY KEY AUTO_INCREMENT,
    material_name VARCHAR(100) NOT NULL,
    is_common BOOLEAN DEFAULT TRUE, -- si es un material común en casa
    estimated_cost DECIMAL(8,2),
    where_to_buy TEXT,
    safety_considerations TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Relación activities-materials
CREATE TABLE activity_material_requirements (
    requirement_id INT PRIMARY KEY AUTO_INCREMENT,
    activity_id INT NOT NULL,
    material_id INT NOT NULL,
    quantity VARCHAR(50), -- "2 unidades", "1 metro", "suficiente"
    is_essential BOOLEAN DEFAULT TRUE,
    alternatives TEXT,
    FOREIGN KEY (activity_id) REFERENCES kids_activities(activity_id) ON DELETE CASCADE,
    FOREIGN KEY (material_id) REFERENCES activity_materials(material_id)
);

-- Pasos de las actividades
CREATE TABLE activity_steps (
    step_id INT PRIMARY KEY AUTO_INCREMENT,
    activity_id INT NOT NULL,
    step_order INT NOT NULL,
    step_title VARCHAR(200),
    step_description TEXT NOT NULL,
    estimated_time_minutes INT,
    difficulty_note TEXT,
    safety_warning TEXT,
    image_url VARCHAR(500),
    FOREIGN KEY (activity_id) REFERENCES kids_activities(activity_id) ON DELETE CASCADE,
    UNIQUE KEY unique_activity_step (activity_id, step_order)
);

-- Beneficios educativos de las actividades
CREATE TABLE activity_benefits (
    benefit_id INT PRIMARY KEY AUTO_INCREMENT,
    benefit_name VARCHAR(100) NOT NULL UNIQUE, -- coordinacion, creatividad, paciencia
    category ENUM('motriz', 'cognitivo', 'social', 'emocional', 'artistico'),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Relación activities-benefits
CREATE TABLE activity_benefit_mapping (
    mapping_id INT PRIMARY KEY AUTO_INCREMENT,
    activity_id INT NOT NULL,
    benefit_id INT NOT NULL,
    impact_level ENUM('bajo', 'medio', 'alto') DEFAULT 'medio',
    FOREIGN KEY (activity_id) REFERENCES kids_activities(activity_id) ON DELETE CASCADE,
    FOREIGN KEY (benefit_id) REFERENCES activity_benefits(benefit_id),
    UNIQUE KEY unique_activity_benefit (activity_id, benefit_id)
);

-- Historial de actividades completadas por niños
CREATE TABLE kids_activity_sessions (
    session_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL, -- padre/tutor
    activity_id INT NOT NULL,
    child_name VARCHAR(100),
    child_age INT,
    completed_at TIMESTAMP,
    duration_minutes INT,
    difficulty_rating INT CHECK (difficulty_rating BETWEEN 1 AND 5),
    enjoyment_rating INT CHECK (enjoyment_rating BETWEEN 1 AND 5),
    notes TEXT,
    photos JSON, -- URLs de fotos del resultado
    would_repeat BOOLEAN,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (activity_id) REFERENCES kids_activities(activity_id),
    INDEX idx_user_date (user_id, completed_at)
);

-- ============================================
-- ENTRETENIMIENTO - PELÍCULAS Y CONTENIDO
-- ============================================

-- Géneros de películas
CREATE TABLE movie_genres (
    genre_id INT PRIMARY KEY AUTO_INCREMENT,
    genre_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    target_audience ENUM('general', 'adultos', 'familias', 'profesionales'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Películas y contenido premium
CREATE TABLE movies (
    movie_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    genre_id INT NOT NULL,
    description TEXT,
    release_year YEAR,
    duration_minutes INT NOT NULL,
    rating DECIMAL(3,2) DEFAULT 0.00,
    content_rating ENUM('G', 'PG', 'PG-13', 'R') DEFAULT 'G',
    language VARCHAR(10) DEFAULT 'es',
    subtitle_languages JSON, -- ["es", "en", "pt"]
    image_emoji VARCHAR(10),
    video_url VARCHAR(500),
    trailer_url VARCHAR(500),
    is_premium BOOLEAN DEFAULT TRUE,
    view_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (genre_id) REFERENCES movie_genres(genre_id)
);

-- Reparto y equipo de películas
CREATE TABLE movie_cast (
    cast_id INT PRIMARY KEY AUTO_INCREMENT,
    movie_id INT NOT NULL,
    person_name VARCHAR(150) NOT NULL,
    role_type ENUM('actor', 'director', 'productor', 'narrator', 'expert') NOT NULL,
    character_name VARCHAR(100), -- para actores
    order_priority INT DEFAULT 999,
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id) ON DELETE CASCADE
);

-- Historial de visualización
CREATE TABLE movie_watch_history (
    watch_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    movie_id INT NOT NULL,
    watch_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    watch_duration_minutes INT, -- tiempo real visualizado
    completed BOOLEAN DEFAULT FALSE,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    review TEXT,
    bookmarked BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id),
    INDEX idx_user_date (user_id, watch_date)
);

-- ============================================
-- ESTADÍSTICAS Y PROGRESO
-- ============================================

-- Estadísticas diarias del usuario
CREATE TABLE daily_stats (
    stat_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    stat_date DATE NOT NULL,
    workouts_completed INT DEFAULT 0,
    total_exercise_minutes INT DEFAULT 0,
    calories_burned INT DEFAULT 0,
    calories_consumed INT DEFAULT 0,
    water_glasses INT DEFAULT 0,
    steps_count INT DEFAULT 0,
    sleep_hours DECIMAL(3,1), -- horas de sueño
    mood_rating INT CHECK (mood_rating BETWEEN 1 AND 5),
    energy_level INT CHECK (energy_level BETWEEN 1 AND 5),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_date (user_id, stat_date)
);

-- Mediciones corporales del usuario
CREATE TABLE body_measurements (
    measurement_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    measurement_date DATE NOT NULL,
    weight_kg DECIMAL(5,2),
    body_fat_percentage DECIMAL(4,2),
    muscle_mass_kg DECIMAL(5,2),
    waist_cm DECIMAL(5,2),
    chest_cm DECIMAL(5,2),
    arm_cm DECIMAL(5,2),
    thigh_cm DECIMAL(5,2),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_date (user_id, measurement_date)
);

-- Logros y badges del usuario
CREATE TABLE achievements (
    achievement_id INT PRIMARY KEY AUTO_INCREMENT,
    achievement_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    badge_emoji VARCHAR(10),
    category ENUM('workouts', 'nutrition', 'consistency', 'milestones', 'social'),
    requirement_type ENUM('count', 'streak', 'goal', 'time_based'),
    requirement_value INT, -- valor necesario para desbloquear
    requirement_unit VARCHAR(20), -- 'workouts', 'days', 'calories', etc.
    points_value INT DEFAULT 10,
    is_hidden BOOLEAN DEFAULT FALSE, -- logros secretos
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Logros desbloqueados por usuarios
CREATE TABLE user_achievements (
    user_achievement_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    achievement_id INT NOT NULL,
    unlocked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    progress_value INT DEFAULT 0, -- progreso actual hacia el logro
    is_completed BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (achievement_id) REFERENCES achievements(achievement_id),
    UNIQUE KEY unique_user_achievement (user_id, achievement_id)
);

-- Metas personalizadas del usuario
CREATE TABLE user_goals_custom (
    custom_goal_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    goal_title VARCHAR(150) NOT NULL,
    description TEXT,
    target_value DECIMAL(10,2) NOT NULL,
    current_value DECIMAL(10,2) DEFAULT 0,
    unit VARCHAR(20), -- kg, workouts, minutes, etc.
    target_date DATE,
    category ENUM('weight', 'fitness', 'nutrition', 'habit'),
    priority ENUM('alta', 'media', 'baja') DEFAULT 'media',
    is_active BOOLEAN DEFAULT TRUE,
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- ============================================
-- SUSCRIPCIONES Y PAGOS
-- ============================================

-- Planes de suscripción
CREATE TABLE subscription_plans (
    plan_id INT PRIMARY KEY AUTO_INCREMENT,
    plan_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    price_monthly DECIMAL(8,2) NOT NULL,
    price_yearly DECIMAL(8,2),
    features JSON, -- lista de características incluidas
    max_users INT DEFAULT 1, -- para planes familiares
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Suscripciones de usuarios
CREATE TABLE user_subscriptions (
    subscription_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    plan_id INT NOT NULL,
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    auto_renew BOOLEAN DEFAULT TRUE,
    payment_method ENUM('credit_card', 'paypal', 'bank_transfer', 'gift'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (plan_id) REFERENCES subscription_plans(plan_id)
);

-- Historial de pagos
CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    subscription_id INT NOT NULL,
    amount DECIMAL(8,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method VARCHAR(50),
    transaction_id VARCHAR(255),
    status ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'pending',
    gateway_response JSON, -- respuesta del gateway de pago
    FOREIGN KEY (subscription_id) REFERENCES user_subscriptions(subscription_id)
);

-- ============================================
-- CONFIGURACIONES Y PREFERENCIAS
-- ============================================

-- Configuraciones de la aplicación por usuario
CREATE TABLE user_settings (
    setting_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    setting_key VARCHAR(100) NOT NULL,
    setting_value TEXT,
    setting_type ENUM('string', 'integer', 'boolean', 'json') DEFAULT 'string',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_setting (user_id, setting_key)
);

-- Notificaciones y recordatorios
CREATE TABLE user_notifications (
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT,
    type ENUM('workout_reminder', 'meal_reminder', 'achievement', 'system', 'promotional'),
    scheduled_at TIMESTAMP,
    sent_at TIMESTAMP NULL,
    read_at TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE,
    action_url VARCHAR(500), -- deep link dentro de la app
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_scheduled (user_id, scheduled_at)
);

-- ============================================
-- DATOS INICIALES BÁSICOS
-- ============================================

-- Insertar categorías básicas de entrenamientos
INSERT INTO workout_categories (category_name, description, icon_emoji, color_theme) VALUES
('Cardio', 'Ejercicios cardiovasculares para quemar calorías', '🔥', 'red'),
('Fuerza', 'Entrenamiento de fuerza y resistencia muscular', '💪', 'blue'),
('Flexibilidad', 'Yoga, stretching y movilidad', '🧘‍♀️', 'green'),
('Core', 'Fortalecimiento del core y abdominales', '🎯', 'orange'),
('HIIT', 'Entrenamiento de intervalos de alta intensidad', '⚡', 'purple'),
('Rehabilitación', 'Ejercicios para recuperación y terapia', '🏥', 'gray');

-- Insertar objetivos básicos
INSERT INTO goals (goal_name, description) VALUES
('perder peso', 'Reducir peso corporal y grasa'),
('ganar músculo', 'Aumentar masa muscular'),
('mantenerse en forma', 'Mantener condición física actual'),
('mejorar resistencia', 'Aumentar resistencia cardiovascular'),
('rehabilitación', 'Recuperación de lesiones'),
('competir', 'Preparación para competencias deportivas');

-- Insertar tipos de comidas
INSERT INTO meal_types (type_name, recommended_time_start, recommended_time_end, typical_calories_percentage) VALUES
('desayuno', '06:00:00', '10:00:00', 25),
('snack_morning', '10:00:00', '12:00:00', 10),
('almuerzo', '12:00:00', '15:00:00', 35),
('snack_afternoon', '15:00:00', '18:00:00', 10),
('cena', '18:00:00', '22:00:00', 20);

-- Insertar géneros de películas
INSERT INTO movie_genres (genre_name, description, target_audience) VALUES
('Documental Fitness', 'Documentales sobre fitness y salud', 'general'),
('Educativo Gastronómico', 'Contenido educativo sobre cocina y nutrición', 'general'),
('Bienestar y Meditación', 'Contenido sobre mindfulness y bienestar mental', 'general'),
('Motivacional', 'Contenido inspiracional y motivacional', 'general'),
('Infantil Educativo', 'Contenido educativo para niños', 'familias');

-- Insertar planes de suscripción básicos
INSERT INTO subscription_plans (plan_name, description, price_monthly, price_yearly, features) VALUES
('Básico', 'Plan básico con funciones esenciales', 0.00, 0.00, '["entrenamientos_basicos", "seguimiento_basico"]'),
('Premium', 'Plan premium con contenido completo', 9.99, 99.99, '["entrenamientos_premium", "peliculas", "nutricion_avanzada", "zona_infantil", "estadisticas_avanzadas"]'),
('Familiar', 'Plan para toda la familia', 14.99, 149.99, '["premium_features", "multiples_perfiles", "contenido_infantil_completo", "hasta_6_usuarios"]');

-- Insertar logros básicos
INSERT INTO achievements (achievement_name, description, badge_emoji, category, requirement_type, requirement_value, requirement_unit, points_value) VALUES
('🎉 Primer entrenamiento', 'Completa tu primer entrenamiento', '🎉', 'workouts', 'count', 1, 'workouts', 50),
('💪 10 entrenamientos', 'Completa 10 entrenamientos', '💪', 'workouts', 'count', 10, 'workouts', 100),
('🔥 7 días seguidos', 'Entrena 7 días consecutivos', '🔥', 'consistency', 'streak', 7, 'days', 200),
('⚡ 1000 calorías', 'Quema 1000 calorías en total', '⚡', 'workouts', 'count', 1000, 'calories', 150),
('🏆 Mes completo', 'Entrena todos los días del mes', '🏆', 'consistency', 'streak', 30, 'days', 500),
('🌟 Nivel experto', 'Completa 100 entrenamientos', '🌟', 'milestones', 'count', 100, 'workouts', 1000);

-- ============================================
-- ÍNDICES ADICIONALES PARA OPTIMIZACIÓN
-- ============================================

-- Índices para mejorar rendimiento de consultas frecuentes
CREATE INDEX idx_workout_sessions_user_date ON workout_sessions(user_id, started_at);
CREATE INDEX idx_daily_stats_user_date ON daily_stats(user_id, stat_date);
CREATE INDEX idx_user_achievements_progress ON user_achievements(user_id, is_completed);
CREATE INDEX idx_workouts_category_difficulty ON workouts(category_id, difficulty_level);
CREATE INDEX idx_movies_genre_premium ON movies(genre_id, is_premium);
CREATE INDEX idx_kids_activities_age ON kids_activities(age_min, age_max);

-- ============================================
-- VISTAS ÚTILES PARA LA APLICACIÓN
-- ============================================

-- Vista de estadísticas completas del usuario
CREATE VIEW user_complete_stats AS
SELECT 
    u.user_id,
    u.name,
    u.email,
    up.age,
    up.gender,
    up.current_weight,
    up.target_weight,
    up.fitness_level,
    up.is_premium,
    COALESCE(workout_stats.total_workouts, 0) as total_workouts,
    COALESCE(workout_stats.total_calories, 0) as total_calories,
    COALESCE(workout_stats.total_minutes, 0) as total_minutes,
    COALESCE(daily_today.workouts_completed, 0) as today_workouts,
    COALESCE(daily_today.calories_burned, 0) as today_calories,
    COALESCE(daily_today.total_exercise_minutes, 0) as today_minutes,
    COALESCE(achievements_count.total_achievements, 0) as total_achievements,
    COALESCE(streak_calc.current_streak, 0) as current_streak
FROM users u
LEFT JOIN user_profiles up ON u.user_id = up.user_id
LEFT JOIN (
    SELECT 
        user_id,
        COUNT(*) as total_workouts,
        SUM(calories_burned) as total_calories,
        SUM(duration_minutes) as total_minutes
    FROM workout_sessions 
    WHERE is_completed = TRUE
    GROUP BY user_id
) workout_stats ON u.user_id = workout_stats.user_id
LEFT JOIN daily_stats daily_today ON u.user_id = daily_today.user_id AND daily_today.stat_date = CURDATE()
LEFT JOIN (
    SELECT user_id, COUNT(*) as total_achievements
    FROM user_achievements
    WHERE is_completed = TRUE
    GROUP BY user_id
) achievements_count ON u.user_id = achievements_count.user_id
LEFT JOIN (
    SELECT 
        user_id,
        COALESCE(
            (SELECT COUNT(*) 
             FROM daily_stats ds2 
             WHERE ds2.user_id = ds1.user_id 
             AND ds2.stat_date <= CURDATE() 
             AND ds2.workouts_completed > 0
             AND NOT EXISTS (
                 SELECT 1 FROM daily_stats ds3
                 WHERE ds3.user_id = ds2.user_id
                 AND ds3.stat_date BETWEEN DATE_SUB(ds2.stat_date, INTERVAL 1 DAY) AND DATE_SUB(CURDATE(), INTERVAL 1 DAY)
                 AND ds3.workouts_completed = 0
             )
            ), 0
        ) as current_streak
    FROM daily_stats ds1
    GROUP BY user_id
) streak_calc ON u.user_id = streak_calc.user_id;

-- Vista de entrenamientos con información completa
CREATE VIEW workouts_complete AS
SELECT 
    w.workout_id,
    w.name,
    w.description,
    w.duration_minutes,
    w.difficulty_level,
    w.calories_min,
    w.calories_max,
    w.rating,
    w.total_completions,
    w.is_premium,
    w.image_emoji,
    wc.category_name,
    wc.icon_emoji as category_icon,
    wc.color_theme,
    COUNT(we.exercise_id) as total_exercises
FROM workouts w
JOIN workout_categories wc ON w.category_id = wc.category_id
LEFT JOIN workout_exercises we ON w.workout_id = we.workout_id
GROUP BY w.workout_id;

-- Vista de actividades infantiles completas
CREATE VIEW kids_activities_complete AS
SELECT 
    ka.activity_id,
    ka.activity_name,
    ka.description,
    ka.age_min,
    ka.age_max,
    ka.duration_minutes,
    ka.difficulty_level,
    ka.image_emoji,
    ka.adult_supervision,
    kac.category_name,
    kac.icon_emoji as category_icon,
    COUNT(DISTINCT amr.material_id) as materials_needed,
    COUNT(DISTINCT as2.step_id) as total_steps,
    GROUP_CONCAT(DISTINCT ab.benefit_name) as benefits_list
FROM kids_activities ka
JOIN kids_activity_categories kac ON ka.category_id = kac.category_id
LEFT JOIN activity_material_requirements amr ON ka.activity_id = amr.activity_id
LEFT JOIN activity_steps as2 ON ka.activity_id = as2.activity_id
LEFT JOIN activity_benefit_mapping abm ON ka.activity_id = abm.activity_id
LEFT JOIN activity_benefits ab ON abm.benefit_id = ab.benefit_id
GROUP BY ka.activity_id;

-- Vista de progreso semanal del usuario
CREATE VIEW user_weekly_progress AS
SELECT 
    ds.user_id,
    YEAR(ds.stat_date) as year,
    WEEK(ds.stat_date) as week,
    DAYOFWEEK(ds.stat_date) as day_of_week,
    SUM(ds.total_exercise_minutes) as minutes_exercised,
    SUM(ds.workouts_completed) as workouts_done,
    SUM(ds.calories_burned) as calories_burned,
    AVG(ds.mood_rating) as avg_mood,
    AVG(ds.energy_level) as avg_energy
FROM daily_stats ds
GROUP BY ds.user_id, YEAR(ds.stat_date), WEEK(ds.stat_date), DAYOFWEEK(ds.stat_date);

-- ============================================
-- PROCEDIMIENTOS ALMACENADOS ÚTILES
-- ============================================

DELIMITER //

-- Procedimiento para actualizar estadísticas diarias
CREATE PROCEDURE UpdateDailyStats(
    IN p_user_id INT,
    IN p_date DATE,
    IN p_workouts_completed INT DEFAULT 0,
    IN p_exercise_minutes INT DEFAULT 0,
    IN p_calories_burned INT DEFAULT 0,
    IN p_calories_consumed INT DEFAULT 0,
    IN p_water_glasses INT DEFAULT 0
)
BEGIN
    INSERT INTO daily_stats (
        user_id, stat_date, workouts_completed, total_exercise_minutes, 
        calories_burned, calories_consumed, water_glasses
    ) VALUES (
        p_user_id, p_date, p_workouts_completed, p_exercise_minutes,
        p_calories_burned, p_calories_consumed, p_water_glasses
    )
    ON DUPLICATE KEY UPDATE
        workouts_completed = workouts_completed + p_workouts_completed,
        total_exercise_minutes = total_exercise_minutes + p_exercise_minutes,
        calories_burned = calories_burned + p_calories_burned,
        calories_consumed = GREATEST(calories_consumed, p_calories_consumed),
        water_glasses = GREATEST(water_glasses, p_water_glasses),
        updated_at = CURRENT_TIMESTAMP;
END //

-- Procedimiento para completar un entrenamiento
CREATE PROCEDURE CompleteWorkout(
    IN p_user_id INT,
    IN p_workout_id INT,
    IN p_duration_minutes INT,
    IN p_calories_burned INT,
    IN p_difficulty_rating INT DEFAULT NULL,
    IN p_enjoyment_rating INT DEFAULT NULL
)
BEGIN
    DECLARE session_id INT;
    
    -- Insertar sesión de entrenamiento
    INSERT INTO workout_sessions (
        user_id, workout_id, started_at, completed_at, 
        calories_burned, duration_minutes, difficulty_rating, 
        enjoyment_rating, is_completed
    ) VALUES (
        p_user_id, p_workout_id, NOW(), NOW(),
        p_calories_burned, p_duration_minutes, p_difficulty_rating,
        p_enjoyment_rating, TRUE
    );
    
    SET session_id = LAST_INSERT_ID();
    
    -- Actualizar estadísticas diarias
    CALL UpdateDailyStats(
        p_user_id, CURDATE(), 1, p_duration_minutes, p_calories_burned, 0, 0
    );
    
    -- Actualizar contador de completaciones del entrenamiento
    UPDATE workouts 
    SET total_completions = total_completions + 1
    WHERE workout_id = p_workout_id;
    
    -- Verificar y desbloquear logros
    CALL CheckAndUnlockAchievements(p_user_id);
    
    SELECT session_id as session_id;
END //

-- Procedimiento para verificar y desbloquear logros
CREATE PROCEDURE CheckAndUnlockAchievements(IN p_user_id INT)
BEGIN
    -- Logro: Primer entrenamiento
    INSERT IGNORE INTO user_achievements (user_id, achievement_id, is_completed, progress_value)
    SELECT p_user_id, 1, TRUE, 1
    FROM workout_sessions ws
    WHERE ws.user_id = p_user_id AND ws.is_completed = TRUE
    LIMIT 1;
    
    -- Logro: 10 entrenamientos
    INSERT INTO user_achievements (user_id, achievement_id, progress_value, is_completed)
    SELECT p_user_id, 2, COUNT(*), (COUNT(*) >= 10)
    FROM workout_sessions ws
    WHERE ws.user_id = p_user_id AND ws.is_completed = TRUE
    ON DUPLICATE KEY UPDATE
        progress_value = VALUES(progress_value),
        is_completed = VALUES(is_completed),
        unlocked_at = CASE WHEN VALUES(is_completed) = TRUE AND is_completed = FALSE 
                          THEN CURRENT_TIMESTAMP ELSE unlocked_at END;
    
    -- Logro: 1000 calorías
    INSERT INTO user_achievements (user_id, achievement_id, progress_value, is_completed)
    SELECT p_user_id, 4, SUM(calories_burned), (SUM(calories_burned) >= 1000)
    FROM workout_sessions ws
    WHERE ws.user_id = p_user_id AND ws.is_completed = TRUE
    ON DUPLICATE KEY UPDATE
        progress_value = VALUES(progress_value),
        is_completed = VALUES(is_completed),
        unlocked_at = CASE WHEN VALUES(is_completed) = TRUE AND is_completed = FALSE 
                          THEN CURRENT_TIMESTAMP ELSE unlocked_at END;
END //

-- Procedimiento para calcular racha actual
CREATE PROCEDURE CalculateCurrentStreak(
    IN p_user_id INT,
    OUT p_current_streak INT
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE streak_count INT DEFAULT 0;
    DECLARE check_date DATE DEFAULT CURDATE();
    DECLARE has_workout INT;
    
    -- Cursor para verificar días hacia atrás
    streak_loop: LOOP
        SELECT COUNT(*) INTO has_workout
        FROM daily_stats
        WHERE user_id = p_user_id 
        AND stat_date = check_date
        AND workouts_completed > 0;
        
        IF has_workout = 0 THEN
            LEAVE streak_loop;
        END IF;
        
        SET streak_count = streak_count + 1;
        SET check_date = DATE_SUB(check_date, INTERVAL 1 DAY);
        
        -- Límite de seguridad para evitar loops infinitos
        IF streak_count > 365 THEN
            LEAVE streak_loop;
        END IF;
    END LOOP;
    
    SET p_current_streak = streak_count;
END //

-- Función para obtener recomendaciones de entrenamientos
CREATE PROCEDURE GetWorkoutRecommendations(
    IN p_user_id INT,
    IN p_limit INT DEFAULT 5
)
BEGIN
    DECLARE user_level ENUM('principiante', 'intermedio', 'avanzado');
    DECLARE user_goals_list TEXT DEFAULT '';
    
    -- Obtener nivel del usuario
    SELECT fitness_level INTO user_level
    FROM user_profiles
    WHERE user_id = p_user_id;
    
    -- Obtener objetivos del usuario
    SELECT GROUP_CONCAT(g.goal_name) INTO user_goals_list
    FROM user_goals ug
    JOIN goals g ON ug.goal_id = g.goal_id
    WHERE ug.user_id = p_user_id;
    
    -- Seleccionar entrenamientos recomendados
    SELECT 
        w.*,
        wc.category_name,
        wc.color_theme,
        CASE 
            WHEN w.difficulty_level = user_level THEN 3
            WHEN w.difficulty_level = 'principiante' AND user_level != 'principiante' THEN 1
            WHEN w.difficulty_level = 'avanzado' AND user_level = 'principiante' THEN 0
            ELSE 2
        END as relevance_score
    FROM workouts w
    JOIN workout_categories wc ON w.category_id = wc.category_id
    WHERE w.difficulty_level <= user_level
    ORDER BY relevance_score DESC, w.rating DESC, w.total_completions DESC
    LIMIT p_limit;
END //

DELIMITER ;

-- ============================================
-- TRIGGERS PARA AUTOMATIZACIÓN
-- ============================================

DELIMITER //

-- Trigger para actualizar rating de entrenamientos
CREATE TRIGGER update_workout_rating
    AFTER INSERT ON workout_sessions
    FOR EACH ROW
BEGIN
    IF NEW.is_completed = TRUE AND NEW.difficulty_rating IS NOT NULL THEN
        UPDATE workouts 
        SET rating = (
            SELECT AVG(difficulty_rating)
            FROM workout_sessions
            WHERE workout_id = NEW.workout_id 
            AND is_completed = TRUE 
            AND difficulty_rating IS NOT NULL
        )
        WHERE workout_id = NEW.workout_id;
    END IF;
END //

-- Trigger para actualizar progreso de peso
CREATE TRIGGER track_weight_progress
    AFTER INSERT ON body_measurements
    FOR EACH ROW
BEGIN
    IF NEW.weight_kg IS NOT NULL THEN
        UPDATE user_profiles 
        SET current_weight = NEW.weight_kg,
            updated_at = CURRENT_TIMESTAMP
        WHERE user_id = NEW.user_id;
    END IF;
END //

-- Trigger para crear estadísticas diarias automáticamente
CREATE TRIGGER create_daily_stats
    AFTER INSERT ON users
    FOR EACH ROW
BEGIN
    INSERT INTO daily_stats (user_id, stat_date)
    VALUES (NEW.user_id, CURDATE())
    ON DUPLICATE KEY UPDATE user_id = user_id;
END //

DELIMITER ;

-- ============================================
-- DATOS DE EJEMPLO PARA DESARROLLO
-- ============================================

-- Insertar ejercicios básicos
INSERT INTO exercises (exercise_name, description, muscle_groups, difficulty_level, instructions) VALUES
('Push-ups', 'Flexiones de brazos básicas', '["chest", "shoulders", "triceps"]', 'principiante', 'Mantén el cuerpo recto, baja hasta que el pecho casi toque el suelo'),
('Squats', 'Sentadillas básicas', '["quadriceps", "glutes", "hamstrings"]', 'principiante', 'Mantén la espalda recta, baja como si te fueras a sentar'),
('Plancha', 'Plancha isométrica', '["core", "shoulders"]', 'principiante', 'Mantén el cuerpo recto como una tabla'),
('Burpees', 'Ejercicio completo de cuerpo', '["full_body"]', 'intermedio', 'Combina una sentadilla, plancha y salto'),
('Mountain Climbers', 'Escaladores', '["core", "cardio"]', 'intermedio', 'Alterna las rodillas al pecho desde posición de plancha'),
('Lunges', 'Zancadas', '["quadriceps", "glutes"]', 'intermedio', 'Da un paso grande hacia adelante y baja la rodilla trasera'),
('Jumping Jacks', 'Saltos de tijera', '["cardio", "full_body"]', 'principiante', 'Salta abriendo y cerrando piernas y brazos simultáneamente');

-- Insertar entrenamientos de ejemplo
INSERT INTO workouts (name, description, category_id, duration_minutes, difficulty_level, calories_min, calories_max, image_emoji, is_premium) VALUES
('Cardio HIIT Matutino', 'Quema grasa rápidamente con intervalos de alta intensidad', 1, 20, 'intermedio', 180, 220, '🔥', FALSE),
('Fuerza Total Body', 'Rutina completa para todo el cuerpo sin equipos', 2, 35, 'avanzado', 250, 300, '💪', FALSE),
('Yoga Flow Relajante', 'Mejora tu flexibilidad y encuentra paz interior', 3, 25, 'principiante', 80, 120, '🧘‍♀️', TRUE),
('Abs Definidos', 'Fortalece tu core con ejercicios específicos', 4, 15, 'intermedio', 100, 140, '🎯', FALSE),
('HIIT Explosivo', 'Entrenamiento intensivo para quemar calorías', 5, 30, 'avanzado', 300, 400, '⚡', TRUE);

-- Insertar relaciones workout-exercises
INSERT INTO workout_exercises (workout_id, exercise_id, exercise_order, duration_seconds, rest_seconds) VALUES
-- Cardio HIIT Matutino
(1, 7, 1, 45, 15), -- Jumping Jacks
(1, 4, 2, 30, 30), -- Burpees
(1, 5, 3, 45, 15), -- Mountain Climbers
(1, 2, 4, 45, 15), -- Squats

-- Fuerza Total Body
(2, 1, 1, NULL, 60), -- Push-ups (3x12)
(2, 2, 2, NULL, 60), -- Squats (3x15)
(2, 3, 3, 60, 30),   -- Plancha
(2, 6, 4, NULL, 45), -- Lunges (3x10)

-- Abs Definidos
(4, 3, 1, 30, 30),   -- Plancha
(4, 5, 2, 45, 30);   -- Mountain Climbers

-- Insertar ingredientes básicos
INSERT INTO ingredients (ingredient_name, category, calories_per_100g, nutritional_info) VALUES
('Pollo (pechuga)', 'proteina', 165, '{"protein": 31, "fat": 3.6, "carbs": 0, "fiber": 0}'),
('Arroz integral', 'carbohidrato', 123, '{"protein": 2.6, "fat": 0.9, "carbs": 25, "fiber": 1.8}'),
('Brócoli', 'vegetal', 34, '{"protein": 2.8, "fat": 0.4, "carbs": 7, "fiber": 2.6}'),
('Salmón', 'proteina', 208, '{"protein": 25, "fat": 12, "carbs": 0, "fiber": 0}'),
('Quinoa', 'carbohidrato', 120, '{"protein": 4.4, "fat": 1.9, "carbs": 22, "fiber": 2.8}'),
('Espinaca', 'vegetal', 23, '{"protein": 2.9, "fat": 0.4, "carbs": 3.6, "fiber": 2.2}'),
('Avena', 'carbohidrato', 68, '{"protein": 2.4, "fat": 1.4, "carbs": 12, "fiber": 1.7}'),
('Yogurt griego', 'proteina', 97, '{"protein": 10, "fat": 5, "carbs": 4, "fiber": 0}');

-- Insertar plan nutricional básico
INSERT INTO nutrition_plans (plan_name, description, target_goal, daily_calories_min, daily_calories_max, carb_percentage, protein_percentage, fat_percentage) VALUES
('Plan Pérdida de Peso', 'Plan balanceado para pérdida de peso sostenible', 'perder_peso', 1500, 1700, 40, 30, 30);

-- Insertar comidas para el plan
INSERT INTO meals (meal_name, meal_type_id, plan_id, calories, preparation_time_minutes, difficulty_level, instructions, nutritional_info) VALUES
('Avena con frutas y nueces', 1, 1, 250, 10, 'facil', 'Cocina la avena, añade frutas y nueces', '{"protein": 8, "carbs": 45, "fat": 6}'),
('Yogurt griego bajo en grasa', 1, 1, 100, 2, 'facil', 'Servir el yogurt con un toque de miel', '{"protein": 15, "carbs": 8, "fat": 2}'),
('Ensalada de pollo a la plancha', 2, 1, 300, 25, 'intermedio', 'Cocina el pollo y mezcla con vegetales frescos', '{"protein": 35, "carbs": 15, "fat": 8}'),
('Salmón a la plancha con vegetales', 5, 1, 250, 20, 'intermedio', 'Cocina el salmón y saltea los vegetales', '{"protein": 30, "carbs": 10, "fat": 12}');

-- Insertar categorías de actividades infantiles
INSERT INTO kids_activity_categories (category_name, description, icon_emoji, recommended_age_min, recommended_age_max) VALUES
('Construcción', 'Actividades de construcción y arquitectura', '🏗️', 6, 12),
('Ejercicio', 'Actividades físicas y deportivas', '💃', 3, 10),
('Manualidad', 'Trabajos manuales y artesanías', '🦋', 8, 14),
('Educativo', 'Actividades educativas y STEM', '🧪', 6, 15),
('Arte', 'Actividades artísticas y creativas', '🎨', 4, 12);

-- Insertar actividades para niños
INSERT INTO kids_activities (activity_name, category_id, description, age_min, age_max, duration_minutes, difficulty_level, image_emoji, adult_supervision) VALUES
('Torre de Bloques Gigante', 1, 'Construcción creativa con cajas de cartón', 6, 12, 40, 'facil', '🏗️', FALSE),
('Baile de los Animales', 2, 'Ejercicio divertido imitando animales', 3, 10, 18, 'facil', '💃', FALSE),
('Origami Mariposa', 3, 'Crear mariposas de papel mediante plegado', 8, 14, 25, 'intermedio', '🦋', FALSE),
('Volcán Químico', 4, 'Experimento científico seguro', 8, 12, 30, 'intermedio', '🌋', TRUE),
('Pintura con Dedos', 5, 'Arte libre con pintura no tóxica', 4, 8, 45, 'facil', '🎨', TRUE);

-- Insertar materiales para actividades
INSERT INTO activity_materials (material_name, is_common, estimated_cost, where_to_buy) VALUES
('Cajas de cartón', TRUE, 0.00, 'Reciclaje doméstico'),
('Cinta adhesiva', TRUE, 2.50, 'Papelería'),
('Marcadores', TRUE, 5.00, 'Papelería'),
('Tijeras', TRUE, 3.00, 'Papelería'),
('Papel cuadrado colorido', TRUE, 1.50, 'Papelería'),
('Pintura no tóxica', FALSE, 8.00, 'Tienda de arte'),
('Bicarbonato de sodio', TRUE, 1.00, 'Supermercado'),
('Vinagre blanco', TRUE, 1.50, 'Supermercado');

-- Insertar películas de ejemplo
INSERT INTO movies (title, genre_id, description, release_year, duration_minutes, rating, image_emoji, is_premium) VALUES
('El Poder de la Mente', 4, 'Descubre cómo atletas de élite utilizan la mentalidad para superar límites', 2023, 95, 4.8, '🧠', TRUE),
('Cocina Mediterránea Saludable', 2, 'Aprende secretos de la cocina mediterránea para una vida más saludable', 2023, 120, 4.6, '🍽️', TRUE),
('Mindfulness: El Arte de Vivir', 3, 'Una guía completa para incorporar mindfulness en tu vida diaria', 2024, 80, 4.9, '🧘', TRUE);

-- Insertar reparto de películas
INSERT INTO movie_cast (movie_id, person_name, role_type, order_priority) VALUES
(1, 'Dr. Michael Johnson', 'expert', 1),
(1, 'Serena Williams', 'actor', 2),
(1, 'LeBron James', 'actor', 3),
(2, 'Chef María González', 'expert', 1),
(2, 'Dr. Antonio López', 'expert', 2),
(3, 'Monje Thich Nhat Hanh', 'expert', 1),
(3, 'Dr. Jon Kabat-Zinn', 'expert', 2);

-- ============================================
-- COMENTARIOS FINALES Y NOTAS DE OPTIMIZACIÓN
-- ============================================

/*
NOTAS IMPORTANTES PARA LA IMPLEMENTACIÓN:

1. SEGURIDAD:
   - Todas las contraseñas deben hashearse antes de almacenar
   - Implementar rate limiting en endpoints de autenticación
   - Validar y sanitizar todas las entradas de usuario
   - Usar prepared statements para prevenir SQL injection

2. PERFORMANCE:
   - Los índices están optimizados para las consultas más frecuentes
   - Considerar particionado de tablas históricas por fechas
   - Implementar caché para consultas frecuentes (Redis)
   - Usar read replicas para consultas de solo lectura

3. ESCALABILIDAD:
   - La estructura permite sharding por user_id
   - Las tablas de contenido (workouts, movies) pueden separarse
   - Considerar CDN para contenido multimedia
   - Implementar queue system para procesamiento asíncrono

4. BACKUP Y MANTENIMIENTO:
   - Backup diario de datos transaccionales
   - Backup semanal completo
   - Retención de logs por 90 días
   - Limpieza automática de sesiones expiradas

5. MONITOREO:
   - Métricas de performance de queries
   - Alertas por uso de espacio en disco
   - Monitoreo de conexiones activas
   - Logs de errores y excepciones

6. GDPR Y PRIVACIDAD:
   - Campo para consentimiento de datos
   - Procedimiento para eliminación de datos personales
   - Encriptación de datos sensibles
   - Logs de acceso a datos personales
*/