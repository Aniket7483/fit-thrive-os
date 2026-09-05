export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.5"
  }
  public: {
    Tables: {
      activity_logs: {
        Row: {
          activity_name: string
          activity_type_id: string | null
          calories_burned: number
          created_at: string
          distance_km: number | null
          duration_min: number
          id: string
          intensity: string
          log_date: string
          notes: string | null
          user_id: string
        }
        Insert: {
          activity_name: string
          activity_type_id?: string | null
          calories_burned: number
          created_at?: string
          distance_km?: number | null
          duration_min: number
          id?: string
          intensity?: string
          log_date: string
          notes?: string | null
          user_id: string
        }
        Update: {
          activity_name?: string
          activity_type_id?: string | null
          calories_burned?: number
          created_at?: string
          distance_km?: number | null
          duration_min?: number
          id?: string
          intensity?: string
          log_date?: string
          notes?: string | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "activity_logs_activity_type_id_fkey"
            columns: ["activity_type_id"]
            isOneToOne: false
            referencedRelation: "activity_types"
            referencedColumns: ["id"]
          },
        ]
      }
      activity_types: {
        Row: {
          id: string
          is_active: boolean
          met_high: number
          met_low: number
          met_moderate: number
          name: string
          tracks_distance: boolean
        }
        Insert: {
          id?: string
          is_active?: boolean
          met_high: number
          met_low: number
          met_moderate: number
          name: string
          tracks_distance?: boolean
        }
        Update: {
          id?: string
          is_active?: boolean
          met_high?: number
          met_low?: number
          met_moderate?: number
          name?: string
          tracks_distance?: boolean
        }
        Relationships: []
      }
      body_measurements: {
        Row: {
          arms_cm: number | null
          body_fat_pct: number | null
          chest_cm: number | null
          created_at: string
          hips_cm: number | null
          id: string
          log_date: string
          thighs_cm: number | null
          user_id: string
          waist_cm: number | null
        }
        Insert: {
          arms_cm?: number | null
          body_fat_pct?: number | null
          chest_cm?: number | null
          created_at?: string
          hips_cm?: number | null
          id?: string
          log_date: string
          thighs_cm?: number | null
          user_id: string
          waist_cm?: number | null
        }
        Update: {
          arms_cm?: number | null
          body_fat_pct?: number | null
          chest_cm?: number | null
          created_at?: string
          hips_cm?: number | null
          id?: string
          log_date?: string
          thighs_cm?: number | null
          user_id?: string
          waist_cm?: number | null
        }
        Relationships: []
      }
      brands: {
        Row: {
          created_at: string
          id: string
          name: string
        }
        Insert: {
          created_at?: string
          id?: string
          name: string
        }
        Update: {
          created_at?: string
          id?: string
          name?: string
        }
        Relationships: []
      }
      exercises: {
        Row: {
          category: string | null
          created_at: string
          difficulty: string | null
          equipment: string | null
          id: string
          instructions: string | null
          is_active: boolean
          media_url: string | null
          name: string
          primary_muscle: string
          secondary_muscles: string[] | null
        }
        Insert: {
          category?: string | null
          created_at?: string
          difficulty?: string | null
          equipment?: string | null
          id?: string
          instructions?: string | null
          is_active?: boolean
          media_url?: string | null
          name: string
          primary_muscle: string
          secondary_muscles?: string[] | null
        }
        Update: {
          category?: string | null
          created_at?: string
          difficulty?: string | null
          equipment?: string | null
          id?: string
          instructions?: string | null
          is_active?: boolean
          media_url?: string | null
          name?: string
          primary_muscle?: string
          secondary_muscles?: string[] | null
        }
        Relationships: []
      }
      favorites: {
        Row: {
          created_at: string
          food_id: string
          id: string
          user_id: string
        }
        Insert: {
          created_at?: string
          food_id: string
          id?: string
          user_id: string
        }
        Update: {
          created_at?: string
          food_id?: string
          id?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "favorites_food_id_fkey"
            columns: ["food_id"]
            isOneToOne: false
            referencedRelation: "foods"
            referencedColumns: ["id"]
          },
        ]
      }
      food_categories: {
        Row: {
          created_at: string
          id: string
          name: string
        }
        Insert: {
          created_at?: string
          id?: string
          name: string
        }
        Update: {
          created_at?: string
          id?: string
          name?: string
        }
        Relationships: []
      }
      food_servings: {
        Row: {
          created_at: string
          food_id: string
          grams: number
          id: string
          is_default: boolean
          label: string
          unit: string
        }
        Insert: {
          created_at?: string
          food_id: string
          grams: number
          id?: string
          is_default?: boolean
          label: string
          unit: string
        }
        Update: {
          created_at?: string
          food_id?: string
          grams?: number
          id?: string
          is_default?: boolean
          label?: string
          unit?: string
        }
        Relationships: [
          {
            foreignKeyName: "food_servings_food_id_fkey"
            columns: ["food_id"]
            isOneToOne: false
            referencedRelation: "foods"
            referencedColumns: ["id"]
          },
        ]
      }
      foods: {
        Row: {
          barcode: string | null
          base_unit: string
          brand_id: string | null
          calories: number
          carbs_g: number
          category_id: string | null
          created_at: string
          created_by: string | null
          diet_type: string
          fat_g: number
          fiber_g: number | null
          id: string
          is_active: boolean
          name: string
          protein_g: number
          sodium_mg: number | null
          source: string | null
          sugar_g: number | null
          updated_at: string
          verified: boolean
        }
        Insert: {
          barcode?: string | null
          base_unit?: string
          brand_id?: string | null
          calories: number
          carbs_g?: number
          category_id?: string | null
          created_at?: string
          created_by?: string | null
          diet_type?: string
          fat_g?: number
          fiber_g?: number | null
          id?: string
          is_active?: boolean
          name: string
          protein_g?: number
          sodium_mg?: number | null
          source?: string | null
          sugar_g?: number | null
          updated_at?: string
          verified?: boolean
        }
        Update: {
          barcode?: string | null
          base_unit?: string
          brand_id?: string | null
          calories?: number
          carbs_g?: number
          category_id?: string | null
          created_at?: string
          created_by?: string | null
          diet_type?: string
          fat_g?: number
          fiber_g?: number | null
          id?: string
          is_active?: boolean
          name?: string
          protein_g?: number
          sodium_mg?: number | null
          source?: string | null
          sugar_g?: number | null
          updated_at?: string
          verified?: boolean
        }
        Relationships: [
          {
            foreignKeyName: "foods_brand_id_fkey"
            columns: ["brand_id"]
            isOneToOne: false
            referencedRelation: "brands"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "foods_category_id_fkey"
            columns: ["category_id"]
            isOneToOne: false
            referencedRelation: "food_categories"
            referencedColumns: ["id"]
          },
        ]
      }
      meal_logs: {
        Row: {
          calories: number
          carbs_g: number
          created_at: string
          fat_g: number
          fiber_g: number | null
          food_id: string | null
          food_name: string
          grams: number
          id: string
          log_date: string
          meal_type: string
          protein_g: number
          quantity: number
          unit: string
          user_id: string
        }
        Insert: {
          calories: number
          carbs_g?: number
          created_at?: string
          fat_g?: number
          fiber_g?: number | null
          food_id?: string | null
          food_name: string
          grams: number
          id?: string
          log_date?: string
          meal_type: string
          protein_g?: number
          quantity: number
          unit: string
          user_id: string
        }
        Update: {
          calories?: number
          carbs_g?: number
          created_at?: string
          fat_g?: number
          fiber_g?: number | null
          food_id?: string | null
          food_name?: string
          grams?: number
          id?: string
          log_date?: string
          meal_type?: string
          protein_g?: number
          quantity?: number
          unit?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "meal_logs_food_id_fkey"
            columns: ["food_id"]
            isOneToOne: false
            referencedRelation: "foods"
            referencedColumns: ["id"]
          },
        ]
      }
      profiles: {
        Row: {
          activity_level: string | null
          created_at: string
          current_weight_kg: number | null
          custom_calories: number | null
          custom_carbs_g: number | null
          custom_fat_g: number | null
          custom_protein_g: number | null
          date_of_birth: string | null
          diet_preference: string | null
          experience: string | null
          full_name: string | null
          goal: string | null
          height_cm: number | null
          id: string
          onboarding_completed: boolean
          sex: string | null
          step_goal: number
          target_weight_kg: number | null
          training_days: number | null
          training_location: string | null
          updated_at: string
          water_goal_ml: number
        }
        Insert: {
          activity_level?: string | null
          created_at?: string
          current_weight_kg?: number | null
          custom_calories?: number | null
          custom_carbs_g?: number | null
          custom_fat_g?: number | null
          custom_protein_g?: number | null
          date_of_birth?: string | null
          diet_preference?: string | null
          experience?: string | null
          full_name?: string | null
          goal?: string | null
          height_cm?: number | null
          id: string
          onboarding_completed?: boolean
          sex?: string | null
          step_goal?: number
          target_weight_kg?: number | null
          training_days?: number | null
          training_location?: string | null
          updated_at?: string
          water_goal_ml?: number
        }
        Update: {
          activity_level?: string | null
          created_at?: string
          current_weight_kg?: number | null
          custom_calories?: number | null
          custom_carbs_g?: number | null
          custom_fat_g?: number | null
          custom_protein_g?: number | null
          date_of_birth?: string | null
          diet_preference?: string | null
          experience?: string | null
          full_name?: string | null
          goal?: string | null
          height_cm?: number | null
          id?: string
          onboarding_completed?: boolean
          sex?: string | null
          step_goal?: number
          target_weight_kg?: number | null
          training_days?: number | null
          training_location?: string | null
          updated_at?: string
          water_goal_ml?: number
        }
        Relationships: []
      }
      saved_meal_items: {
        Row: {
          food_id: string | null
          food_name: string
          grams: number
          id: string
          quantity: number
          saved_meal_id: string
          unit: string
        }
        Insert: {
          food_id?: string | null
          food_name: string
          grams: number
          id?: string
          quantity: number
          saved_meal_id: string
          unit: string
        }
        Update: {
          food_id?: string | null
          food_name?: string
          grams?: number
          id?: string
          quantity?: number
          saved_meal_id?: string
          unit?: string
        }
        Relationships: [
          {
            foreignKeyName: "saved_meal_items_food_id_fkey"
            columns: ["food_id"]
            isOneToOne: false
            referencedRelation: "foods"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "saved_meal_items_saved_meal_id_fkey"
            columns: ["saved_meal_id"]
            isOneToOne: false
            referencedRelation: "saved_meals"
            referencedColumns: ["id"]
          },
        ]
      }
      saved_meals: {
        Row: {
          created_at: string
          id: string
          name: string
          user_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          name: string
          user_id: string
        }
        Update: {
          created_at?: string
          id?: string
          name?: string
          user_id?: string
        }
        Relationships: []
      }
      step_logs: {
        Row: {
          created_at: string
          id: string
          log_date: string
          steps: number
          user_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          log_date: string
          steps: number
          user_id: string
        }
        Update: {
          created_at?: string
          id?: string
          log_date?: string
          steps?: number
          user_id?: string
        }
        Relationships: []
      }
      user_roles: {
        Row: {
          created_at: string
          id: string
          role: Database["public"]["Enums"]["app_role"]
          user_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          role?: Database["public"]["Enums"]["app_role"]
          user_id: string
        }
        Update: {
          created_at?: string
          id?: string
          role?: Database["public"]["Enums"]["app_role"]
          user_id?: string
        }
        Relationships: []
      }
      water_logs: {
        Row: {
          amount_ml: number
          created_at: string
          id: string
          log_date: string
          user_id: string
        }
        Insert: {
          amount_ml: number
          created_at?: string
          id?: string
          log_date?: string
          user_id: string
        }
        Update: {
          amount_ml?: number
          created_at?: string
          id?: string
          log_date?: string
          user_id?: string
        }
        Relationships: []
      }
      weight_logs: {
        Row: {
          created_at: string
          id: string
          log_date: string
          user_id: string
          weight_kg: number
        }
        Insert: {
          created_at?: string
          id?: string
          log_date: string
          user_id: string
          weight_kg: number
        }
        Update: {
          created_at?: string
          id?: string
          log_date?: string
          user_id?: string
          weight_kg?: number
        }
        Relationships: []
      }
      workout_sessions: {
        Row: {
          completed: boolean
          created_at: string
          duration_min: number | null
          id: string
          log_date: string
          name: string
          notes: string | null
          user_id: string
        }
        Insert: {
          completed?: boolean
          created_at?: string
          duration_min?: number | null
          id?: string
          log_date: string
          name: string
          notes?: string | null
          user_id: string
        }
        Update: {
          completed?: boolean
          created_at?: string
          duration_min?: number | null
          id?: string
          log_date?: string
          name?: string
          notes?: string | null
          user_id?: string
        }
        Relationships: []
      }
      workout_sets: {
        Row: {
          created_at: string
          duration_sec: number | null
          exercise_id: string | null
          exercise_name: string
          id: string
          reps: number | null
          session_id: string
          set_number: number
          weight_kg: number | null
        }
        Insert: {
          created_at?: string
          duration_sec?: number | null
          exercise_id?: string | null
          exercise_name: string
          id?: string
          reps?: number | null
          session_id: string
          set_number: number
          weight_kg?: number | null
        }
        Update: {
          created_at?: string
          duration_sec?: number | null
          exercise_id?: string | null
          exercise_name?: string
          id?: string
          reps?: number | null
          session_id?: string
          set_number?: number
          weight_kg?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "workout_sets_exercise_id_fkey"
            columns: ["exercise_id"]
            isOneToOne: false
            referencedRelation: "exercises"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "workout_sets_session_id_fkey"
            columns: ["session_id"]
            isOneToOne: false
            referencedRelation: "workout_sessions"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      has_role: {
        Args: {
          _role: Database["public"]["Enums"]["app_role"]
          _user_id: string
        }
        Returns: boolean
      }
    }
    Enums: {
      app_role: "user" | "admin"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends (DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never) = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends (PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never) = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {
      app_role: ["user", "admin"],
    },
  },
} as const
