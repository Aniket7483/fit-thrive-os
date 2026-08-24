
-- ========== ROLES ==========
CREATE TYPE public.app_role AS ENUM ('user','admin');

CREATE TABLE public.user_roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  role public.app_role NOT NULL DEFAULT 'user',
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, role)
);
GRANT SELECT ON public.user_roles TO authenticated;
GRANT ALL ON public.user_roles TO service_role;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "own roles readable" ON public.user_roles FOR SELECT TO authenticated USING (auth.uid() = user_id);

CREATE OR REPLACE FUNCTION public.has_role(_user_id uuid, _role public.app_role)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = _user_id AND role = _role);
$$;

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER LANGUAGE plpgsql SET search_path = public AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END; $$;

-- ========== PROFILES ==========
CREATE TABLE public.profiles (
  id uuid PRIMARY KEY,
  full_name text,
  date_of_birth date,
  sex text CHECK (sex IN ('male','female','other')),
  height_cm numeric(5,1),
  current_weight_kg numeric(5,1),
  target_weight_kg numeric(5,1),
  goal text CHECK (goal IN ('fat_loss','maintain','muscle_gain','recomposition','general_fitness','strength')),
  activity_level text CHECK (activity_level IN ('sedentary','light','moderate','very_active')),
  experience text CHECK (experience IN ('beginner','intermediate','advanced')),
  training_days int CHECK (training_days BETWEEN 0 AND 7),
  training_location text CHECK (training_location IN ('home','gym','bodyweight')),
  diet_preference text CHECK (diet_preference IN ('vegetarian','eggetarian','non_vegetarian','vegan','none')),
  onboarding_completed boolean NOT NULL DEFAULT false,
  custom_calories int, custom_protein_g int, custom_carbs_g int, custom_fat_g int,
  water_goal_ml int NOT NULL DEFAULT 3000,
  step_goal int NOT NULL DEFAULT 10000,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.profiles TO authenticated;
GRANT ALL ON public.profiles TO service_role;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "own profile" ON public.profiles FOR ALL TO authenticated USING (auth.uid() = id) WITH CHECK (auth.uid() = id);
CREATE TRIGGER trg_profiles_updated BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name) VALUES (NEW.id, NEW.raw_user_meta_data->>'full_name')
    ON CONFLICT (id) DO NOTHING;
  INSERT INTO public.user_roles (user_id, role) VALUES (NEW.id, 'user') ON CONFLICT DO NOTHING;
  RETURN NEW;
END; $$;
CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ========== FOOD DATABASE ==========
CREATE TABLE public.food_categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE public.brands (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE public.foods (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  brand_id uuid REFERENCES public.brands(id) ON DELETE SET NULL,
  category_id uuid REFERENCES public.food_categories(id) ON DELETE SET NULL,
  base_unit text NOT NULL DEFAULT 'g' CHECK (base_unit IN ('g','ml')),
  calories numeric(7,2) NOT NULL,
  protein_g numeric(6,2) NOT NULL DEFAULT 0,
  carbs_g numeric(6,2) NOT NULL DEFAULT 0,
  fat_g numeric(6,2) NOT NULL DEFAULT 0,
  fiber_g numeric(6,2), sugar_g numeric(6,2), sodium_mg numeric(7,2),
  diet_type text NOT NULL DEFAULT 'vegetarian' CHECK (diet_type IN ('vegetarian','eggetarian','non_vegetarian','vegan')),
  barcode text,
  source text,
  verified boolean NOT NULL DEFAULT false,
  is_active boolean NOT NULL DEFAULT true,
  created_by uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_foods_name ON public.foods USING gin (to_tsvector('simple', name));
CREATE INDEX idx_foods_name_trgm ON public.foods (lower(name));
CREATE INDEX idx_foods_active ON public.foods (is_active);

CREATE TABLE public.food_servings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  food_id uuid NOT NULL REFERENCES public.foods(id) ON DELETE CASCADE,
  label text NOT NULL,
  unit text NOT NULL,
  grams numeric(7,2) NOT NULL,
  is_default boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_food_servings_food ON public.food_servings (food_id);

GRANT SELECT ON public.food_categories, public.brands, public.foods, public.food_servings TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON public.food_categories, public.brands, public.foods, public.food_servings TO authenticated;
GRANT ALL ON public.food_categories, public.brands, public.foods, public.food_servings TO service_role;
ALTER TABLE public.food_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.brands ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.foods ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.food_servings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "read categories" ON public.food_categories FOR SELECT USING (true);
CREATE POLICY "admin categories" ON public.food_categories FOR ALL TO authenticated USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE POLICY "read brands" ON public.brands FOR SELECT USING (true);
CREATE POLICY "admin brands" ON public.brands FOR ALL TO authenticated USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));

CREATE POLICY "read foods" ON public.foods FOR SELECT USING (is_active AND (created_by IS NULL OR verified OR created_by = auth.uid()));
CREATE POLICY "create own foods" ON public.foods FOR INSERT TO authenticated WITH CHECK (created_by = auth.uid());
CREATE POLICY "update own foods" ON public.foods FOR UPDATE TO authenticated USING (created_by = auth.uid()) WITH CHECK (created_by = auth.uid());
CREATE POLICY "delete own foods" ON public.foods FOR DELETE TO authenticated USING (created_by = auth.uid());
CREATE POLICY "admin foods" ON public.foods FOR ALL TO authenticated USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));

CREATE POLICY "read servings" ON public.food_servings FOR SELECT USING (true);
CREATE POLICY "own food servings" ON public.food_servings FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.foods f WHERE f.id = food_id AND f.created_by = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.foods f WHERE f.id = food_id AND f.created_by = auth.uid()));
CREATE POLICY "admin servings" ON public.food_servings FOR ALL TO authenticated USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));

-- ========== MEAL LOGS (with nutrition snapshot) ==========
CREATE TABLE public.meal_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  log_date date NOT NULL DEFAULT (now() AT TIME ZONE 'utc')::date,
  meal_type text NOT NULL CHECK (meal_type IN ('breakfast','lunch','snacks','dinner','pre_workout','post_workout','other')),
  food_id uuid REFERENCES public.foods(id) ON DELETE SET NULL,
  food_name text NOT NULL,
  quantity numeric(8,2) NOT NULL CHECK (quantity > 0),
  unit text NOT NULL,
  grams numeric(8,2) NOT NULL,
  calories numeric(8,2) NOT NULL,
  protein_g numeric(7,2) NOT NULL DEFAULT 0,
  carbs_g numeric(7,2) NOT NULL DEFAULT 0,
  fat_g numeric(7,2) NOT NULL DEFAULT 0,
  fiber_g numeric(7,2),
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_meal_logs_user_date ON public.meal_logs (user_id, log_date);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.meal_logs TO authenticated;
GRANT ALL ON public.meal_logs TO service_role;
ALTER TABLE public.meal_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "own meal logs" ON public.meal_logs FOR ALL TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE TABLE public.saved_meals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  name text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE public.saved_meal_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  saved_meal_id uuid NOT NULL REFERENCES public.saved_meals(id) ON DELETE CASCADE,
  food_id uuid REFERENCES public.foods(id) ON DELETE SET NULL,
  food_name text NOT NULL,
  quantity numeric(8,2) NOT NULL,
  unit text NOT NULL,
  grams numeric(8,2) NOT NULL
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.saved_meals, public.saved_meal_items TO authenticated;
GRANT ALL ON public.saved_meals, public.saved_meal_items TO service_role;
ALTER TABLE public.saved_meals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_meal_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "own saved meals" ON public.saved_meals FOR ALL TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "own saved meal items" ON public.saved_meal_items FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.saved_meals m WHERE m.id = saved_meal_id AND m.user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.saved_meals m WHERE m.id = saved_meal_id AND m.user_id = auth.uid()));

CREATE TABLE public.favorites (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  food_id uuid NOT NULL REFERENCES public.foods(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, food_id)
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.favorites TO authenticated;
GRANT ALL ON public.favorites TO service_role;
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;
CREATE POLICY "own favorites" ON public.favorites FOR ALL TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- ========== WATER / STEPS ==========
CREATE TABLE public.water_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  log_date date NOT NULL DEFAULT (now() AT TIME ZONE 'utc')::date,
  amount_ml int NOT NULL CHECK (amount_ml > 0),
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_water_user_date ON public.water_logs (user_id, log_date);
CREATE TABLE public.step_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  log_date date NOT NULL,
  steps int NOT NULL CHECK (steps >= 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, log_date)
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.water_logs, public.step_logs TO authenticated;
GRANT ALL ON public.water_logs, public.step_logs TO service_role;
ALTER TABLE public.water_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.step_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "own water" ON public.water_logs FOR ALL TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "own steps" ON public.step_logs FOR ALL TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- ========== ACTIVITY ==========
CREATE TABLE public.activity_types (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  met_low numeric(4,2) NOT NULL,
  met_moderate numeric(4,2) NOT NULL,
  met_high numeric(4,2) NOT NULL,
  tracks_distance boolean NOT NULL DEFAULT false,
  is_active boolean NOT NULL DEFAULT true
);
GRANT SELECT ON public.activity_types TO anon, authenticated;
GRANT ALL ON public.activity_types TO service_role;
ALTER TABLE public.activity_types ENABLE ROW LEVEL SECURITY;
CREATE POLICY "read activity types" ON public.activity_types FOR SELECT USING (true);
CREATE POLICY "admin activity types" ON public.activity_types FOR ALL TO authenticated USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));

CREATE TABLE public.activity_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  log_date date NOT NULL,
  activity_type_id uuid REFERENCES public.activity_types(id) ON DELETE SET NULL,
  activity_name text NOT NULL,
  duration_min numeric(6,1) NOT NULL CHECK (duration_min > 0),
  distance_km numeric(6,2),
  intensity text NOT NULL DEFAULT 'moderate' CHECK (intensity IN ('low','moderate','high')),
  calories_burned numeric(7,1) NOT NULL,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_activity_user_date ON public.activity_logs (user_id, log_date);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.activity_logs TO authenticated;
GRANT ALL ON public.activity_logs TO service_role;
ALTER TABLE public.activity_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "own activity" ON public.activity_logs FOR ALL TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- ========== EXERCISES / WORKOUTS ==========
CREATE TABLE public.exercises (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  primary_muscle text NOT NULL,
  secondary_muscles text[],
  equipment text,
  category text,
  difficulty text CHECK (difficulty IN ('beginner','intermediate','advanced')),
  instructions text,
  media_url text,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.exercises TO anon, authenticated;
GRANT ALL ON public.exercises TO service_role;
ALTER TABLE public.exercises ENABLE ROW LEVEL SECURITY;
CREATE POLICY "read exercises" ON public.exercises FOR SELECT USING (is_active);
CREATE POLICY "admin exercises" ON public.exercises FOR ALL TO authenticated USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));

CREATE TABLE public.workout_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  log_date date NOT NULL,
  name text NOT NULL,
  notes text,
  completed boolean NOT NULL DEFAULT false,
  duration_min int,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_sessions_user_date ON public.workout_sessions (user_id, log_date);
CREATE TABLE public.workout_sets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id uuid NOT NULL REFERENCES public.workout_sessions(id) ON DELETE CASCADE,
  exercise_id uuid REFERENCES public.exercises(id) ON DELETE SET NULL,
  exercise_name text NOT NULL,
  set_number int NOT NULL,
  weight_kg numeric(6,2),
  reps int,
  duration_sec int,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_sets_session ON public.workout_sets (session_id);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.workout_sessions, public.workout_sets TO authenticated;
GRANT ALL ON public.workout_sessions, public.workout_sets TO service_role;
ALTER TABLE public.workout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workout_sets ENABLE ROW LEVEL SECURITY;
CREATE POLICY "own sessions" ON public.workout_sessions FOR ALL TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "own sets" ON public.workout_sets FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.workout_sessions s WHERE s.id = session_id AND s.user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.workout_sessions s WHERE s.id = session_id AND s.user_id = auth.uid()));

-- ========== BODY PROGRESS ==========
CREATE TABLE public.weight_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  log_date date NOT NULL,
  weight_kg numeric(5,2) NOT NULL CHECK (weight_kg > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, log_date)
);
CREATE TABLE public.body_measurements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  log_date date NOT NULL,
  waist_cm numeric(5,1), chest_cm numeric(5,1), arms_cm numeric(5,1),
  thighs_cm numeric(5,1), hips_cm numeric(5,1), body_fat_pct numeric(4,1),
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, log_date)
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.weight_logs, public.body_measurements TO authenticated;
GRANT ALL ON public.weight_logs, public.body_measurements TO service_role;
ALTER TABLE public.weight_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.body_measurements ENABLE ROW LEVEL SECURITY;
CREATE POLICY "own weight" ON public.weight_logs FOR ALL TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "own measurements" ON public.body_measurements FOR ALL TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- ========== SEED: CATEGORIES ==========
INSERT INTO public.food_categories (name) VALUES
 ('Staples'),('Breakfast'),('Protein'),('Dairy'),('Dals & Legumes'),('Vegetables'),
 ('Street & Restaurant'),('Snacks'),('Beverages'),('Fruits'),('Packaged');

-- ========== SEED: FOODS (per 100 g / 100 ml) ==========
INSERT INTO public.foods (name, category_id, base_unit, calories, protein_g, carbs_g, fat_g, fiber_g, diet_type, verified, source) VALUES
 ('Chapati (Whole Wheat)', (SELECT id FROM public.food_categories WHERE name='Staples'), 'g', 297, 11.0, 58.0, 3.7, 8.0, 'vegetarian', true, 'IFCT estimate'),
 ('Tandoori Roti', (SELECT id FROM public.food_categories WHERE name='Staples'), 'g', 290, 9.5, 57.0, 3.0, 7.0, 'vegetarian', true, 'estimate'),
 ('Bhakri (Jowar)', (SELECT id FROM public.food_categories WHERE name='Staples'), 'g', 285, 8.0, 60.0, 2.5, 7.5, 'vegan', true, 'estimate'),
 ('Cooked White Rice', (SELECT id FROM public.food_categories WHERE name='Staples'), 'g', 130, 2.7, 28.0, 0.3, 0.4, 'vegan', true, 'USDA'),
 ('Cooked Brown Rice', (SELECT id FROM public.food_categories WHERE name='Staples'), 'g', 123, 2.7, 25.6, 1.0, 1.6, 'vegan', true, 'USDA'),
 ('Plain Paratha', (SELECT id FROM public.food_categories WHERE name='Staples'), 'g', 330, 7.5, 45.0, 13.0, 4.0, 'vegetarian', true, 'estimate'),
 ('Khichdi', (SELECT id FROM public.food_categories WHERE name='Staples'), 'g', 120, 4.5, 20.0, 2.5, 1.8, 'vegetarian', true, 'estimate'),
 ('Poha', (SELECT id FROM public.food_categories WHERE name='Breakfast'), 'g', 132, 2.6, 24.0, 3.2, 1.2, 'vegan', true, 'estimate'),
 ('Upma', (SELECT id FROM public.food_categories WHERE name='Breakfast'), 'g', 145, 3.5, 22.0, 4.8, 1.5, 'vegetarian', true, 'estimate'),
 ('Idli', (SELECT id FROM public.food_categories WHERE name='Breakfast'), 'g', 140, 4.5, 28.0, 0.6, 1.0, 'vegan', true, 'estimate'),
 ('Plain Dosa', (SELECT id FROM public.food_categories WHERE name='Breakfast'), 'g', 168, 4.0, 28.0, 4.5, 1.2, 'vegan', true, 'estimate'),
 ('Masala Dosa', (SELECT id FROM public.food_categories WHERE name='Breakfast'), 'g', 190, 4.2, 27.0, 7.0, 1.8, 'vegetarian', true, 'estimate'),
 ('Uttapam', (SELECT id FROM public.food_categories WHERE name='Breakfast'), 'g', 160, 4.5, 26.0, 4.0, 1.5, 'vegetarian', true, 'estimate'),
 ('Moong Dal Chilla', (SELECT id FROM public.food_categories WHERE name='Breakfast'), 'g', 158, 8.0, 18.0, 5.5, 3.0, 'vegetarian', true, 'estimate'),
 ('Paneer', (SELECT id FROM public.food_categories WHERE name='Protein'), 'g', 265, 18.0, 3.6, 20.0, 0, 'vegetarian', true, 'estimate'),
 ('Low Fat Paneer', (SELECT id FROM public.food_categories WHERE name='Protein'), 'g', 180, 22.0, 3.5, 9.0, 0, 'vegetarian', true, 'estimate'),
 ('Paneer Bhurji', (SELECT id FROM public.food_categories WHERE name='Protein'), 'g', 230, 14.5, 6.0, 17.0, 1.0, 'vegetarian', true, 'estimate'),
 ('Whole Egg (Boiled)', (SELECT id FROM public.food_categories WHERE name='Protein'), 'g', 155, 13.0, 1.1, 11.0, 0, 'eggetarian', true, 'USDA'),
 ('Egg White (Boiled)', (SELECT id FROM public.food_categories WHERE name='Protein'), 'g', 52, 11.0, 0.7, 0.2, 0, 'eggetarian', true, 'USDA'),
 ('Chicken Breast (Cooked)', (SELECT id FROM public.food_categories WHERE name='Protein'), 'g', 165, 31.0, 0, 3.6, 0, 'non_vegetarian', true, 'USDA'),
 ('Chicken Curry', (SELECT id FROM public.food_categories WHERE name='Protein'), 'g', 180, 15.0, 4.5, 11.0, 1.0, 'non_vegetarian', true, 'estimate'),
 ('Mutton Curry', (SELECT id FROM public.food_categories WHERE name='Protein'), 'g', 240, 17.0, 4.0, 17.0, 1.0, 'non_vegetarian', true, 'estimate'),
 ('Fish (Rohu, Cooked)', (SELECT id FROM public.food_categories WHERE name='Protein'), 'g', 140, 19.0, 0, 6.5, 0, 'non_vegetarian', true, 'estimate'),
 ('Soya Chunks (Dry)', (SELECT id FROM public.food_categories WHERE name='Protein'), 'g', 345, 52.0, 33.0, 0.5, 13.0, 'vegan', true, 'estimate'),
 ('Whey Protein Powder', (SELECT id FROM public.food_categories WHERE name='Protein'), 'g', 400, 78.0, 8.0, 6.0, 0, 'vegetarian', true, 'estimate'),
 ('Toor Dal (Cooked)', (SELECT id FROM public.food_categories WHERE name='Dals & Legumes'), 'g', 116, 7.0, 18.0, 1.5, 4.5, 'vegan', true, 'estimate'),
 ('Moong Dal (Cooked)', (SELECT id FROM public.food_categories WHERE name='Dals & Legumes'), 'g', 105, 7.0, 16.0, 0.8, 4.0, 'vegan', true, 'estimate'),
 ('Rajma (Cooked)', (SELECT id FROM public.food_categories WHERE name='Dals & Legumes'), 'g', 127, 8.7, 22.8, 0.5, 6.4, 'vegan', true, 'USDA'),
 ('Chole (Chickpea Curry)', (SELECT id FROM public.food_categories WHERE name='Dals & Legumes'), 'g', 150, 6.5, 20.0, 5.0, 6.0, 'vegan', true, 'estimate'),
 ('Curd (Dahi, Full Fat)', (SELECT id FROM public.food_categories WHERE name='Dairy'), 'g', 98, 3.5, 4.7, 7.0, 0, 'vegetarian', true, 'estimate'),
 ('Greek Yogurt (Plain)', (SELECT id FROM public.food_categories WHERE name='Dairy'), 'g', 59, 10.0, 3.6, 0.4, 0, 'vegetarian', true, 'USDA'),
 ('Toned Milk', (SELECT id FROM public.food_categories WHERE name='Dairy'), 'ml', 58, 3.1, 4.7, 3.0, 0, 'vegetarian', true, 'estimate'),
 ('Full Cream Milk', (SELECT id FROM public.food_categories WHERE name='Dairy'), 'ml', 67, 3.2, 4.8, 4.0, 0, 'vegetarian', true, 'estimate'),
 ('Ghee', (SELECT id FROM public.food_categories WHERE name='Dairy'), 'g', 900, 0, 0, 100, 0, 'vegetarian', true, 'estimate'),
 ('Mixed Vegetable Sabzi', (SELECT id FROM public.food_categories WHERE name='Vegetables'), 'g', 95, 2.5, 9.0, 5.5, 3.0, 'vegan', true, 'estimate'),
 ('Aloo Sabzi', (SELECT id FROM public.food_categories WHERE name='Vegetables'), 'g', 120, 2.0, 17.0, 5.0, 2.0, 'vegan', true, 'estimate'),
 ('Palak Paneer', (SELECT id FROM public.food_categories WHERE name='Vegetables'), 'g', 180, 8.5, 6.0, 14.0, 2.5, 'vegetarian', true, 'estimate'),
 ('Samosa', (SELECT id FROM public.food_categories WHERE name='Street & Restaurant'), 'g', 300, 5.0, 32.0, 17.0, 2.5, 'vegetarian', true, 'estimate'),
 ('Vada Pav', (SELECT id FROM public.food_categories WHERE name='Street & Restaurant'), 'g', 290, 6.5, 40.0, 11.5, 3.0, 'vegetarian', true, 'estimate'),
 ('Pav Bhaji', (SELECT id FROM public.food_categories WHERE name='Street & Restaurant'), 'g', 180, 4.0, 22.0, 8.5, 3.0, 'vegetarian', true, 'estimate'),
 ('Misal Pav', (SELECT id FROM public.food_categories WHERE name='Street & Restaurant'), 'g', 170, 6.0, 21.0, 7.0, 4.5, 'vegetarian', true, 'estimate'),
 ('Chicken Biryani', (SELECT id FROM public.food_categories WHERE name='Street & Restaurant'), 'g', 190, 9.0, 22.0, 7.5, 1.2, 'non_vegetarian', true, 'estimate'),
 ('Veg Biryani', (SELECT id FROM public.food_categories WHERE name='Street & Restaurant'), 'g', 165, 4.0, 25.0, 5.5, 2.0, 'vegetarian', true, 'estimate'),
 ('Mutton Mandi', (SELECT id FROM public.food_categories WHERE name='Street & Restaurant'), 'g', 210, 12.0, 20.0, 9.5, 1.0, 'non_vegetarian', true, 'estimate'),
 ('Chicken Mandi', (SELECT id FROM public.food_categories WHERE name='Street & Restaurant'), 'g', 185, 13.0, 20.0, 6.5, 1.0, 'non_vegetarian', true, 'estimate'),
 ('Chicken Shawarma', (SELECT id FROM public.food_categories WHERE name='Street & Restaurant'), 'g', 215, 13.5, 20.0, 9.0, 1.5, 'non_vegetarian', true, 'estimate'),
 ('Paneer Tikka', (SELECT id FROM public.food_categories WHERE name='Street & Restaurant'), 'g', 225, 17.0, 6.0, 15.0, 1.0, 'vegetarian', true, 'estimate'),
 ('Roasted Chana', (SELECT id FROM public.food_categories WHERE name='Snacks'), 'g', 380, 22.0, 55.0, 5.5, 18.0, 'vegan', true, 'estimate'),
 ('Peanuts (Roasted)', (SELECT id FROM public.food_categories WHERE name='Snacks'), 'g', 585, 26.0, 16.0, 49.0, 8.5, 'vegan', true, 'USDA'),
 ('Almonds', (SELECT id FROM public.food_categories WHERE name='Snacks'), 'g', 579, 21.0, 22.0, 50.0, 12.5, 'vegan', true, 'USDA'),
 ('Banana', (SELECT id FROM public.food_categories WHERE name='Fruits'), 'g', 89, 1.1, 22.8, 0.3, 2.6, 'vegan', true, 'USDA'),
 ('Apple', (SELECT id FROM public.food_categories WHERE name='Fruits'), 'g', 52, 0.3, 13.8, 0.2, 2.4, 'vegan', true, 'USDA'),
 ('Masala Chai (with sugar)', (SELECT id FROM public.food_categories WHERE name='Beverages'), 'ml', 62, 1.6, 8.5, 2.3, 0, 'vegetarian', true, 'estimate'),
 ('Black Coffee (no sugar)', (SELECT id FROM public.food_categories WHERE name='Beverages'), 'ml', 2, 0.2, 0, 0, 0, 'vegan', true, 'USDA');

-- ========== SEED: SERVINGS ==========
INSERT INTO public.food_servings (food_id, label, unit, grams, is_default)
SELECT id, '100 g', 'g', 100, false FROM public.foods WHERE base_unit='g';
INSERT INTO public.food_servings (food_id, label, unit, grams, is_default)
SELECT id, '100 ml', 'ml', 100, false FROM public.foods WHERE base_unit='ml';

INSERT INTO public.food_servings (food_id, label, unit, grams, is_default) VALUES
 ((SELECT id FROM public.foods WHERE name='Chapati (Whole Wheat)'), '1 medium chapati', 'piece', 35, true),
 ((SELECT id FROM public.foods WHERE name='Tandoori Roti'), '1 roti', 'piece', 55, true),
 ((SELECT id FROM public.foods WHERE name='Bhakri (Jowar)'), '1 bhakri', 'piece', 60, true),
 ((SELECT id FROM public.foods WHERE name='Cooked White Rice'), '1 katori (150 g)', 'bowl', 150, true),
 ((SELECT id FROM public.foods WHERE name='Cooked Brown Rice'), '1 katori (150 g)', 'bowl', 150, true),
 ((SELECT id FROM public.foods WHERE name='Plain Paratha'), '1 paratha', 'piece', 60, true),
 ((SELECT id FROM public.foods WHERE name='Khichdi'), '1 bowl (200 g)', 'bowl', 200, true),
 ((SELECT id FROM public.foods WHERE name='Poha'), '1 plate (150 g)', 'bowl', 150, true),
 ((SELECT id FROM public.foods WHERE name='Upma'), '1 bowl (150 g)', 'bowl', 150, true),
 ((SELECT id FROM public.foods WHERE name='Idli'), '1 idli', 'piece', 40, true),
 ((SELECT id FROM public.foods WHERE name='Plain Dosa'), '1 dosa', 'piece', 85, true),
 ((SELECT id FROM public.foods WHERE name='Masala Dosa'), '1 dosa', 'piece', 150, true),
 ((SELECT id FROM public.foods WHERE name='Uttapam'), '1 uttapam', 'piece', 110, true),
 ((SELECT id FROM public.foods WHERE name='Moong Dal Chilla'), '1 chilla', 'piece', 90, true),
 ((SELECT id FROM public.foods WHERE name='Paneer'), '1 cube (~20 g)', 'piece', 20, false),
 ((SELECT id FROM public.foods WHERE name='Whole Egg (Boiled)'), '1 large egg', 'piece', 50, true),
 ((SELECT id FROM public.foods WHERE name='Egg White (Boiled)'), '1 egg white', 'piece', 33, true),
 ((SELECT id FROM public.foods WHERE name='Whey Protein Powder'), '1 scoop (30 g)', 'serving', 30, true),
 ((SELECT id FROM public.foods WHERE name='Toor Dal (Cooked)'), '1 katori (150 g)', 'bowl', 150, true),
 ((SELECT id FROM public.foods WHERE name='Moong Dal (Cooked)'), '1 katori (150 g)', 'bowl', 150, true),
 ((SELECT id FROM public.foods WHERE name='Rajma (Cooked)'), '1 katori (150 g)', 'bowl', 150, true),
 ((SELECT id FROM public.foods WHERE name='Chole (Chickpea Curry)'), '1 katori (150 g)', 'bowl', 150, true),
 ((SELECT id FROM public.foods WHERE name='Curd (Dahi, Full Fat)'), '1 katori (150 g)', 'bowl', 150, true),
 ((SELECT id FROM public.foods WHERE name='Greek Yogurt (Plain)'), '1 bowl (150 g)', 'bowl', 150, true),
 ((SELECT id FROM public.foods WHERE name='Toned Milk'), '1 glass (250 ml)', 'ml', 250, true),
 ((SELECT id FROM public.foods WHERE name='Full Cream Milk'), '1 glass (250 ml)', 'ml', 250, true),
 ((SELECT id FROM public.foods WHERE name='Ghee'), '1 teaspoon (5 g)', 'teaspoon', 5, true),
 ((SELECT id FROM public.foods WHERE name='Mixed Vegetable Sabzi'), '1 katori (150 g)', 'bowl', 150, true),
 ((SELECT id FROM public.foods WHERE name='Aloo Sabzi'), '1 katori (150 g)', 'bowl', 150, true),
 ((SELECT id FROM public.foods WHERE name='Palak Paneer'), '1 katori (150 g)', 'bowl', 150, true),
 ((SELECT id FROM public.foods WHERE name='Samosa'), '1 samosa', 'piece', 65, true),
 ((SELECT id FROM public.foods WHERE name='Vada Pav'), '1 vada pav', 'piece', 130, true),
 ((SELECT id FROM public.foods WHERE name='Pav Bhaji'), '1 plate (300 g)', 'serving', 300, true),
 ((SELECT id FROM public.foods WHERE name='Misal Pav'), '1 plate (300 g)', 'serving', 300, true),
 ((SELECT id FROM public.foods WHERE name='Chicken Biryani'), '1 plate (350 g)', 'serving', 350, true),
 ((SELECT id FROM public.foods WHERE name='Veg Biryani'), '1 plate (350 g)', 'serving', 350, true),
 ((SELECT id FROM public.foods WHERE name='Mutton Mandi'), '1 plate (400 g)', 'serving', 400, true),
 ((SELECT id FROM public.foods WHERE name='Chicken Mandi'), '1 plate (400 g)', 'serving', 400, true),
 ((SELECT id FROM public.foods WHERE name='Chicken Shawarma'), '1 roll (250 g)', 'serving', 250, true),
 ((SELECT id FROM public.foods WHERE name='Paneer Tikka'), '1 plate (150 g)', 'serving', 150, true),
 ((SELECT id FROM public.foods WHERE name='Banana'), '1 medium banana', 'piece', 118, true),
 ((SELECT id FROM public.foods WHERE name='Apple'), '1 medium apple', 'piece', 180, true),
 ((SELECT id FROM public.foods WHERE name='Masala Chai (with sugar)'), '1 cup (150 ml)', 'cup', 150, true),
 ((SELECT id FROM public.foods WHERE name='Black Coffee (no sugar)'), '1 cup (200 ml)', 'cup', 200, true);

-- ========== SEED: ACTIVITY TYPES ==========
INSERT INTO public.activity_types (name, met_low, met_moderate, met_high, tracks_distance) VALUES
 ('Walking', 2.8, 3.5, 5.0, true),
 ('Running', 7.0, 9.8, 12.5, true),
 ('Cycling', 4.0, 7.5, 12.0, true),
 ('Swimming', 5.0, 7.0, 10.0, true),
 ('Hiking', 5.0, 6.0, 7.5, true),
 ('Stair Climbing', 4.0, 8.0, 11.0, false),
 ('Sports', 5.0, 7.0, 10.0, false),
 ('HIIT', 6.0, 8.5, 11.0, false),
 ('Gym Training', 3.5, 5.0, 6.5, false),
 ('Yoga', 2.5, 3.0, 4.0, false),
 ('Other Cardio', 4.0, 6.0, 8.0, false);

-- ========== SEED: EXERCISES ==========
INSERT INTO public.exercises (name, primary_muscle, secondary_muscles, equipment, category, difficulty, instructions) VALUES
 ('Barbell Bench Press','Chest',ARRAY['Triceps','Shoulders'],'Barbell','Strength','intermediate','Lower the bar to mid-chest with control, then press up without flaring the elbows fully.'),
 ('Incline Dumbbell Press','Chest',ARRAY['Shoulders','Triceps'],'Dumbbell','Strength','intermediate','Set the bench to 30 degrees and press dumbbells overhead.'),
 ('Push Up','Chest',ARRAY['Triceps','Abs'],'Bodyweight','Strength','beginner','Keep a straight line from head to heels and lower until the chest is near the floor.'),
 ('Barbell Row','Back',ARRAY['Biceps','Forearms'],'Barbell','Strength','intermediate','Hinge at the hips and row the bar to the lower ribs.'),
 ('Lat Pulldown','Back',ARRAY['Biceps'],'Cable','Strength','beginner','Pull the bar to the upper chest, driving the elbows down.'),
 ('Pull Up','Back',ARRAY['Biceps','Forearms'],'Bodyweight','Strength','advanced','Pull until the chin passes the bar, then lower under control.'),
 ('Overhead Press','Shoulders',ARRAY['Triceps'],'Barbell','Strength','intermediate','Press the bar overhead while keeping the ribs down.'),
 ('Lateral Raise','Shoulders',NULL,'Dumbbell','Strength','beginner','Raise the dumbbells to shoulder height with a slight elbow bend.'),
 ('Barbell Curl','Biceps',ARRAY['Forearms'],'Barbell','Strength','beginner','Curl the bar without swinging the torso.'),
 ('Triceps Pushdown','Triceps',NULL,'Cable','Strength','beginner','Extend the elbows fully, keeping the upper arms still.'),
 ('Back Squat','Quadriceps',ARRAY['Glutes','Hamstrings'],'Barbell','Strength','intermediate','Squat to at least parallel with the knees tracking over the toes.'),
 ('Goblet Squat','Quadriceps',ARRAY['Glutes'],'Dumbbell','Strength','beginner','Hold a dumbbell at the chest and squat down between the knees.'),
 ('Romanian Deadlift','Hamstrings',ARRAY['Glutes','Back'],'Barbell','Strength','intermediate','Hinge at the hips with a soft knee bend, feeling a hamstring stretch.'),
 ('Hip Thrust','Glutes',ARRAY['Hamstrings'],'Barbell','Strength','intermediate','Drive through the heels and squeeze the glutes at the top.'),
 ('Walking Lunge','Quadriceps',ARRAY['Glutes','Hamstrings'],'Dumbbell','Strength','beginner','Step forward and lower the back knee toward the floor.'),
 ('Standing Calf Raise','Calves',NULL,'Machine','Strength','beginner','Rise onto the toes and pause at the top.'),
 ('Plank','Abs',ARRAY['Full Body'],'Bodyweight','Core','beginner','Hold a straight body line on the forearms.'),
 ('Hanging Leg Raise','Abs',ARRAY['Forearms'],'Bodyweight','Core','advanced','Raise the legs without swinging.'),
 ('Cable Crunch','Abs',NULL,'Cable','Core','beginner','Crunch the ribs toward the pelvis.'),
 ('Farmer Carry','Forearms',ARRAY['Full Body'],'Dumbbell','Conditioning','beginner','Walk with heavy dumbbells and a tall posture.'),
 ('Deadlift','Back',ARRAY['Hamstrings','Glutes','Forearms'],'Barbell','Strength','advanced','Brace, push the floor away, and lock out with the hips and knees together.'),
 ('Burpee','Full Body',ARRAY['Chest','Quadriceps'],'Bodyweight','Conditioning','intermediate','Drop to a push up, jump the feet in, and jump up.');
