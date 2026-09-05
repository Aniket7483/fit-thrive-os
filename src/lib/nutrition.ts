/**
 * Nutrition & energy methodology.
 *
 * Everything here is an ESTIMATE. Calculations are done at full precision and
 * only rounded for display.
 */

export type Sex = "male" | "female" | "other";
export type Goal =
  | "fat_loss"
  | "maintain"
  | "muscle_gain"
  | "recomposition"
  | "general_fitness"
  | "strength";
export type ActivityLevel = "sedentary" | "light" | "moderate" | "very_active";

export const GOAL_LABELS: Record<Goal, string> = {
  fat_loss: "Fat Loss",
  maintain: "Maintain Weight",
  muscle_gain: "Muscle Gain",
  recomposition: "Body Recomposition",
  general_fitness: "General Fitness",
  strength: "Improve Strength",
};

export const ACTIVITY_LABELS: Record<ActivityLevel, string> = {
  sedentary: "Sedentary — desk job, little movement",
  light: "Lightly Active — light exercise 1-3 days",
  moderate: "Moderately Active — exercise 3-5 days",
  very_active: "Very Active — hard exercise 6-7 days",
};

const ACTIVITY_FACTOR: Record<ActivityLevel, number> = {
  sedentary: 1.2,
  light: 1.375,
  moderate: 1.55,
  very_active: 1.725,
};

/** Mifflin-St Jeor. Returns kcal/day. */
export function calcBMR(input: {
  weightKg: number;
  heightCm: number;
  age: number;
  sex: Sex;
}): number {
  const base = 10 * input.weightKg + 6.25 * input.heightCm - 5 * input.age;
  if (input.sex === "male") return base + 5;
  if (input.sex === "female") return base - 161;
  return base - 78; // midpoint for unspecified
}

export function calcTDEE(bmr: number, level: ActivityLevel): number {
  return bmr * ACTIVITY_FACTOR[level];
}

/** Goal calories. Deficits/surpluses are deliberately moderate. */
export function calcGoalCalories(tdee: number, goal: Goal): number {
  switch (goal) {
    case "fat_loss":
      return tdee * 0.8; // ~20% deficit
    case "recomposition":
      return tdee * 0.92;
    case "muscle_gain":
      return tdee * 1.1;
    case "strength":
      return tdee * 1.05;
    default:
      return tdee;
  }
}

/** Lowest calorie intake we will ever display without a warning. */
export function calorieFloor(sex: Sex): number {
  return sex === "female" ? 1200 : 1500;
}

export type MacroTargets = {
  calories: number;
  protein: number;
  carbs: number;
  fat: number;
};

/**
 * Protein is anchored to bodyweight (higher for muscle goals), fat to a
 * fraction of calories, carbohydrate fills the remainder.
 */
export function calcMacros(
  calories: number,
  weightKg: number,
  goal: Goal,
): MacroTargets {
  const proteinPerKg =
    goal === "muscle_gain" || goal === "recomposition" || goal === "strength"
      ? 1.9
      : goal === "fat_loss"
        ? 1.8
        : 1.4;

  const protein = weightKg * proteinPerKg;
  const fat = (calories * 0.27) / 9;
  const remaining = calories - protein * 4 - fat * 9;
  const carbs = Math.max(remaining / 4, 0);

  return { calories, protein, carbs, fat };
}

export type TargetProfile = {
  date_of_birth: string | null;
  sex: Sex | null;
  height_cm: number | null;
  current_weight_kg: number | null;
  goal: Goal | null;
  activity_level: ActivityLevel | null;
  custom_calories: number | null;
  custom_protein_g: number | null;
  custom_carbs_g: number | null;
  custom_fat_g: number | null;
};

export type DerivedTargets = MacroTargets & {
  bmr: number;
  tdee: number;
  belowFloor: boolean;
  isCustom: boolean;
};

export function ageFromDob(dob: string | null): number {
  if (!dob) return 30;
  const birth = new Date(dob);
  const diff = Date.now() - birth.getTime();
  const years = diff / (365.25 * 24 * 60 * 60 * 1000);
  return Math.max(13, Math.min(100, Math.round(years)));
}

export function deriveTargets(p: TargetProfile): DerivedTargets {
  const weightKg = p.current_weight_kg ?? 70;
  const heightCm = p.height_cm ?? 170;
  const sex: Sex = p.sex ?? "other";
  const goal: Goal = p.goal ?? "maintain";
  const level: ActivityLevel = p.activity_level ?? "sedentary";

  const bmr = calcBMR({ weightKg, heightCm, age: ageFromDob(p.date_of_birth), sex });
  const tdee = calcTDEE(bmr, level);
  const rawGoalCalories = calcGoalCalories(tdee, goal);
  const floor = calorieFloor(sex);
  const safeCalories = Math.max(rawGoalCalories, floor);

  const auto = calcMacros(safeCalories, weightKg, goal);

  const isCustom = p.custom_calories != null;
  const targets: MacroTargets = isCustom
    ? {
        calories: p.custom_calories ?? auto.calories,
        protein: p.custom_protein_g ?? auto.protein,
        carbs: p.custom_carbs_g ?? auto.carbs,
        fat: p.custom_fat_g ?? auto.fat,
      }
    : auto;

  return {
    ...targets,
    bmr,
    tdee,
    belowFloor: rawGoalCalories < floor,
    isCustom,
  };
}

/** Scale per-100g nutrition to an arbitrary gram amount. */
export function scaleNutrition(
  per100: { calories: number; protein_g: number; carbs_g: number; fat_g: number; fiber_g?: number | null },
  grams: number,
) {
  const f = grams / 100;
  return {
    calories: per100.calories * f,
    protein_g: per100.protein_g * f,
    carbs_g: per100.carbs_g * f,
    fat_g: per100.fat_g * f,
    fiber_g: per100.fiber_g == null ? null : per100.fiber_g * f,
  };
}

/** MET-based activity expenditure. Estimate only. */
export function calcActivityCalories(args: {
  met: number;
  durationMin: number;
  weightKg: number;
}): number {
  return (args.met * 3.5 * args.weightKg * args.durationMin) / 200;
}

export function round(n: number, dp = 0): number {
  const f = 10 ** dp;
  return Math.round(n * f) / f;
}

export function fmt(n: number, dp = 0): string {
  return round(n, dp).toLocaleString("en-IN", {
    minimumFractionDigits: dp,
    maximumFractionDigits: dp,
  });
}

/** Rolling average over a date-sorted series. */
export function rollingAverage(values: number[], window: number): number | null {
  if (values.length === 0) return null;
  const slice = values.slice(-window);
  return slice.reduce((a, b) => a + b, 0) / slice.length;
}

export function todayISO(): string {
  const d = new Date();
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
}

export function shiftISO(iso: string, days: number): string {
  const d = new Date(`${iso}T00:00:00`);
  d.setDate(d.getDate() + days);
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
}

export const MEAL_TYPES = [
  { value: "breakfast", label: "Breakfast" },
  { value: "lunch", label: "Lunch" },
  { value: "snacks", label: "Snacks" },
  { value: "dinner", label: "Dinner" },
  { value: "pre_workout", label: "Pre-Workout" },
  { value: "post_workout", label: "Post-Workout" },
  { value: "other", label: "Other" },
] as const;

export type MealType = (typeof MEAL_TYPES)[number]["value"];
