# Fit Thrive OS

ROLE

Act as a Senior Full-Stack Software Architect, UI/UX Designer, Database Engineer, Fitness Application Product Designer, and QA Engineer.

Your task is to design and develop a production-ready, responsive Fitness, Nutrition, Activity & Workout Tracking Web Application.

The application should allow users to understand exactly:

How many calories they consume each day

How much protein, carbohydrates, fat, and other nutrients they consume

How much water they drink

How active they are

Their steps and cardio activities

Their workout performance

Their estimated daily energy expenditure

Their weight/body-measurement progress

Whether they are progressing toward fat loss, maintenance, muscle gain, or body recomposition goals

The application should be particularly useful for Indian users, with strong support for Indian meals, household serving sizes, restaurant foods, street foods, and packaged foods.

The goal is NOT to create a basic calorie calculator. Build a complete personal fitness and nutrition operating system.

1. PRODUCT OBJECTIVE

The core problem is simple:

People eat food throughout the day but often have no idea:

How many calories they consumed

How much protein they consumed

Whether they exceeded their calorie target

Whether they ate enough protein

How many calories their activities approximately burned

Whether their diet supports their fitness goal

Whether their weight is actually trending in the right direction

The application should solve this through an extremely simple daily logging experience.

A user should be able to enter:

125 g Paneer
2 Chapatis
150 g Cooked Rice

and immediately receive estimated:

Calories

Protein

Carbohydrates

Fat

The application then adds the meal to their daily totals.

2. USER AUTHENTICATION

Implement secure authentication.

Support:

Create account

Login

Logout

Forgot password

Reset password

Email verification if supported

Secure session/token management

Protected routes

Role-based authorization

Roles:

USER

Normal application user.

ADMIN

Controls foods, exercises, workout programs, nutrition information, activity types, and other system data.

Never rely only on frontend role checks.

Authorization must also be enforced server-side.

3. USER ONBOARDING

Immediately after creating an account, users should complete onboarding.

Collect:

Personal Information

Name

Age / Date of Birth

Sex

Height

Current weight

Target weight

Fitness Goal

Allow:

Fat Loss

Maintain Weight

Muscle Gain

Body Recomposition

Improve General Fitness

Improve Strength

Activity Level

Allow options such as:

Sedentary

Lightly Active

Moderately Active

Very Active

Training Information

Ask:

Beginner / Intermediate / Advanced

Days available for training

Home / Gym / Bodyweight

Available equipment

Dietary Preferences

Optional:

Vegetarian

Eggetarian

Non-Vegetarian

Vegan

No preference

The user must be able to modify this information later.

4. PERSONALIZED CALORIE CALCULATION

Calculate estimated:

BMR

Use a recognized formula such as Mifflin-St Jeor.

TDEE

Estimate TDEE using BMR and activity level.

Goal Calories

Calculate an appropriate calorie target based on the user's selected goal.

Examples:

Fat Loss:
Moderate calorie deficit.

Maintenance:
Approximately TDEE.

Muscle Gain:
Moderate calorie surplus.

Body Recomposition:
Near-maintenance or small deficit depending on profile.

Make it clear throughout the application that calorie requirements and activity expenditure are estimates, not exact physiological measurements.

Do NOT encourage extreme calorie deficits.

5. MACRONUTRIENT TARGETS

Generate daily targets for:

Calories

Protein

Carbohydrates

Fat

The application should especially emphasize protein for users interested in muscle retention/gain.

Targets should be configurable rather than permanently hardcoded.

Users should also be allowed to manually adjust targets if desired.

6. MAIN DASHBOARD

Create a modern, clean dashboard showing the user's entire day at a glance.

Example:

GOOD MORNING, USER

Today's Overview

Calories

1,420 / 2,100 kcal

Protein

92 / 125 g

Carbohydrates

150 / 220 g

Fat

48 / 65 g

Water

1.8 / 3.0 L

Steps

8,420 / 10,000

Activity

320 kcal estimated

Workout

Upper Body — Completed

Weight

69.8 kg

Use:

Progress rings

Progress bars

Cards

Charts

Useful status indicators

Do NOT overcrowd the dashboard.

The most important information should be immediately understandable.

7. FOOD DATABASE

Build a structured food database.

Each food should support fields such as:

Food Name

Brand

Category

Serving Size

Serving Unit

Calories

Protein

Carbohydrates

Fat

Fiber

Sugar

Sodium

Data source if available

Verified/unverified status

Nutrition values should preferably be stored using a standardized reference quantity such as per 100 g / 100 ml, with serving conversions calculated dynamically.

8. INDIAN FOOD DATABASE

Indian foods should be a major focus.

Include categories for foods such as:

Staple Foods

Chapati

Roti

Bhakri

Rice

Dal

Khichdi

Breakfast

Poha

Upma

Idli

Dosa

Uttapam

Protein Sources

Paneer

Eggs

Chicken

Mutton

Fish

Soy chunks

Dal

Curd

Milk

Street / Restaurant Foods

Samosa

Vada Pav

Pav Bhaji

Misal Pav

Biryani

Mutton Mandi

Chicken Mandi

Shawarma

These values must be treated as estimates when recipes can vary significantly.

9. PACKAGED FOOD DATABASE

Support branded packaged foods.

Structure:

Brand → Product → Package Size → Nutrition

Examples could include biscuits, snacks, beverages, protein products, dairy products, etc.

A user should be able to search a product and select the package or serving they consumed.

Example:

Product
Quantity: 1 packet
Package: 50 g

The application calculates nutrition automatically.

Avoid relying on retail price such as "₹5 packet" as the primary identifier because prices and package sizes change.

Use actual grams/ml/package size whenever possible.

10. FOOD SEARCH

Provide fast search with autocomplete.

Users should be able to search:

Paneer

and receive relevant foods.

Filters:

Vegetarian

Non-Vegetarian

Vegan

Brand

Food category

High protein

Low calorie

Recent foods should appear first for returning users.

Also support:

Favorites

Users can favorite commonly consumed foods.

Recent Foods

Show recently logged foods.

Frequent Foods

Automatically identify foods frequently consumed.

11. FOOD QUANTITY SYSTEM

Support multiple quantity units:

Grams

Kilograms

Milliliters

Liters

Piece

Bowl

Cup

Spoon

Tablespoon

Teaspoon

Packet

Serving

Whenever possible, convert household units to standardized weights internally.

Example:

Paneer:

100 g = 265 kcal

User enters:

125 g

The system automatically calculates nutrition for 125 g.

12. MEAL LOGGING

Users should be able to categorize foods under:

Breakfast

Lunch

Snacks

Dinner

Pre-Workout

Post-Workout

Other

Example:

Lunch

Paneer — 125 g
331 kcal
22 g Protein

Chapati — 2
200 kcal
6 g Protein

Rice — 150 g
195 kcal
4 g Protein

Meal Total

726 kcal

32 g Protein

Then automatically update the daily totals.

13. QUICK ADD

Make food logging extremely fast.

Allow:

+ Add Food

Search → quantity → add.

Also support:

Repeat yesterday's meal

Copy meal

Save meal

Create custom meal

Quick add calories/macros

Example saved meal:

My Office Lunch

2 Chapati
150 g Rice
Dal
Vegetable

The user can add the entire meal with one click.

14. CUSTOM FOODS

Users should be able to create personal foods.

Fields:

Name

Serving size

Calories

Protein

Carbohydrates

Fat

Optional additional nutrition

Custom foods should belong to that user unless submitted for admin verification.

15. BARCODE SUPPORT — FUTURE READY

Design the database so barcode scanning can eventually be supported.

Store optional:

Barcode / GTIN

Brand

Product

Package size

This does not necessarily need to be implemented in the first MVP but the architecture should accommodate it.

16. WATER TRACKING

Create simple hydration tracking.

Example:

2.25 / 3.0 L

Quick actions:

+250 ml
+500 ml
+750 ml
Custom

Users should be able to undo incorrect entries.

Show hydration history.

17. ACTIVITY TRACKING

Support activities such as:

Walking

Running

Cycling

Swimming

Hiking

Stair climbing

Sports

HIIT

Gym training

Other cardio

Users should provide appropriate data depending on activity:

Duration

Distance

Intensity

Pace/speed when relevant

18. CALORIES BURNED

Estimate activity calories based on factors such as:

User body weight

Activity

Duration

Intensity

MET values where appropriate

Example:

Cycling

Distance: 10 km
Duration: 35 minutes
Average speed: 17 km/h

Estimated calories burned:

~250 kcal

Clearly label this as an estimate.

Do not present smartwatch or activity calculations as perfectly accurate.

19. DO NOT OVERSIMPLIFY NET CALORIES

Avoid encouraging users to think:

Food calories - exercise calories = exact physiological net calories.

Instead display separately:

Nutrition

Consumed:
1,900 kcal

Daily target:
2,100 kcal

Activity

Estimated exercise expenditure:
320 kcal

Explain that the user's activity level is already part of estimated daily energy requirements and exercise expenditure estimates contain uncertainty.

This prevents accidental double-counting.

20. STEP TRACKING

Allow users to record steps manually initially.

Example:

8,420 / 10,000

Architecture should eventually support integrations with health platforms if technically possible.

Potential future integrations:

Google Health Connect

Apple Health

Wearables

Do not make external integrations mandatory for the MVP.

21. WORKOUT SYSTEM

Create a complete workout tracking module.

Users should be able to:

Create workouts

Follow predefined workouts

Add exercises

Record sets

Record repetitions

Record weight

Record duration

Add workout notes

Mark workouts complete

Example:

Bench Press

Set 1
50 kg × 10

Set 2
50 kg × 9

Set 3
50 kg × 8

22. EXERCISE DATABASE

Each exercise should contain:

Exercise name

Primary muscle group

Secondary muscles

Equipment

Exercise category

Instructions

Difficulty

Optional media/demo URL

Muscle groups:

Chest

Back

Shoulders

Biceps

Triceps

Forearms

Abs

Quadriceps

Hamstrings

Glutes

Calves

Full Body

23. WORKOUT PLANS

Support programs such as:

Beginner Full Body

Upper / Lower

Push Pull Legs

Strength

Home Workout

Bodyweight

Fat Loss Conditioning

Abs / Core

Plans should support schedules.

Example:

Monday — Upper
Tuesday — Lower
Wednesday — Rest
Thursday — Upper
Friday — Lower

24. PROGRESSIVE OVERLOAD

Track workout progression.

Example:

Bench Press

Week 1 — 50 kg
Week 2 — 52.5 kg
Week 3 — 55 kg
Week 4 — 57.5 kg

Show:

Personal records

Weight progression

Rep progression

Estimated volume

Workout frequency

25. BODY PROGRESS TRACKING

Allow users to log:

Weight

Waist

Chest

Arms

Thighs

Hips

Optional body-fat estimate

Users should be able to log measurements periodically rather than being forced to enter them daily.

26. PROGRESS PHOTOS

Optionally allow:

Front photo

Side photo

Back photo

Store photos securely and privately.

Users must control deletion.

Do not expose progress photos publicly by default.

27. PROGRESS CHARTS

Create useful charts for:

Weight Trend

70.0 kg
69.7 kg
69.5 kg
69.2 kg
68.9 kg

Calories

Daily calorie consumption over time.

Protein

Average protein intake.

Steps

Daily step totals.

Workout Frequency

Workouts per week.

Strength

Exercise performance over time.

Use weekly averages to reduce noise.

28. WEIGHT TREND SYSTEM

Do not overreact to single-day weight changes.

Body weight fluctuates because of:

Water

Sodium

Carbohydrate intake

Food volume

Hydration

Digestion

Calculate a rolling average such as a 7-day trend.

Show:

Today's Weight

70.4 kg

7-Day Average

69.8 kg

This gives users a better understanding of actual progress.

29. SMART DAILY INSIGHTS

Create useful rule-based insights.

Examples:

You have consumed 72% of today's calorie target.

You still need approximately 38 g protein to reach your target.

Your protein intake has been below target for three consecutive days.

Your 7-day average body weight decreased by 0.4 kg.

You've completed four workouts this week.

Avoid medical claims.

Insights should be supportive and informative rather than judgmental.

30. SMART FOOD RECOMMENDATIONS

If the user has:

600 calories remaining

and

45 g protein remaining

the application can suggest foods/meals that approximately fit those remaining targets.

Prioritize foods already available in the database.

Consider:

Dietary preference

Calories remaining

Protein remaining

Recently consumed foods

User favorites

31. SAFETY GUARDRAILS

The application should NEVER encourage:

Starvation

Extreme calorie restriction

Excessive exercise to compensate for food

Purging behaviors

Unsafe weight-loss rates

If calculated calorie targets become unusually low, show a warning and avoid automatically recommending aggressive deficits.

Clearly state that calculations are estimates and that users with medical conditions, eating disorders, pregnancy, or specialized nutritional needs should seek qualified professional advice.

32. ADMIN DASHBOARD

Create a completely separate Admin Panel.

Admin dashboard should show:

Total users

Active users

Food database size

Exercise database size

Workout plans

Recently added foods

Reported/flagged foods

33. ADMIN FOOD MANAGEMENT

Admin should be able to:

Add food

Edit food

Delete/deactivate food

Verify food

Manage brands

Manage categories

Manage serving units

Update nutritional information

Bulk import foods

Use soft deletion where appropriate to preserve historical user logs.

34. ADMIN EXERCISE MANAGEMENT

Admin can:

Add exercise

Edit exercise

Disable exercise

Assign muscle groups

Assign equipment

Add instructions

Manage workout programs

35. DATABASE ARCHITECTURE

Design a normalized relational database.

Potential entities:

users
user_profiles
user_goals
daily_targets

foods
brands
food_categories
food_servings
food_nutrients

meal_logs
meal_log_items
saved_meals
saved_meal_items

water_logs

activities
activity_types

exercises
exercise_muscles
workout_plans
workout_plan_days
workout_plan_exercises

workout_sessions
workout_sets

step_logs

weight_logs
body_measurements

progress_photos

favorites
custom_foods

notifications

admin_users
audit_logs


Use proper:

Primary keys

Foreign keys

Indexes

Constraints

Created timestamps

Updated timestamps

Soft deletion where required

Do not duplicate data unnecessarily.

36. HISTORICAL DATA INTEGRITY

This is extremely important.

Suppose the nutrition value of Paneer changes in the database later.

A meal logged six months ago should NOT unexpectedly change.

Therefore meal log entries should snapshot relevant nutrition values when the food is consumed.

Store values such as:

Quantity consumed

Calories at logging time

Protein at logging time

Carbohydrates at logging time

Fat at logging time

This protects historical accuracy.

37. API ARCHITECTURE

Create clear API modules for:

/auth
/users
/profile
/goals

/foods
/meals
/nutrition

/water

/activities
/steps

/exercises
/workouts

/progress
/measurements

/admin


Use:

Input validation

Authentication middleware

Authorization middleware

Error handling

Pagination

Search

Filtering

Rate limiting where appropriate

38. UI/UX DESIGN

The application should feel like a modern premium fitness product.

Avoid:

Excessive gradients

Giant cards

Excessive rounded containers

Neon colors everywhere

Random animations

Clutter

AI-generated-looking dashboards

Use:

Clean typography

Strong spacing

Subtle shadows

Consistent iconography

Clear hierarchy

Responsive cards

Accessible contrast

Meaningful charts

Smooth but subtle interactions

Design should work beautifully on:

Desktop

Laptop

Tablet

Mobile

Mobile experience is particularly important because users will frequently log food from their phones.

39. MOBILE NAVIGATION

Consider bottom navigation on mobile:

Home | Food | + | Workout | Progress

The central + button can provide:

Add Food

Add Water

Add Weight

Add Activity

Start Workout

This should make everyday logging extremely fast.

40. DASHBOARD NAVIGATION

Desktop sidebar could contain:

Dashboard

Nutrition
Food Diary
Foods
Saved Meals

Activity
Workouts
Exercise Library

Progress
Measurements

Hydration

Insights

Profile
Settings


Admins additionally receive:

Admin Dashboard
Food Management
Brand Management
Exercise Management
Workout Plans
User Management
Reports
Audit Logs


41. SEARCH & PERFORMANCE

Food search must feel instantaneous.

Implement:

Debounced search

Database indexes

Pagination

Cached popular foods where appropriate

Recent foods

Favorites

Optimize queries rather than loading the entire food database into the browser.

42. DATA SECURITY

Implement:

Secure password hashing

Server-side validation

SQL injection protection

XSS protection

CSRF protection where relevant

Secure authentication

Rate limiting

Authorization

Safe file upload handling

Secure photo storage

Environment variables for secrets

Never expose secrets in frontend code.

43. ACCESSIBILITY

Follow good accessibility practices.

Include:

Keyboard navigation

Semantic HTML

Proper labels

Screen reader support

Accessible charts where possible

Sufficient contrast

Visible focus states

44. DATA EXPORT

Allow users to eventually export their own data.

Possible formats:

CSV

PDF summary

Include:

Weight history

Nutrition history

Workout history

Measurements

45. FUTURE FEATURES

Design architecture so these can eventually be added without rebuilding the application:

Barcode Scanner

Scan packaged foods.

AI Meal Recognition

Upload food photo → suggest possible foods → user confirms.

Never automatically assume image-estimated nutrition is exact.

Health Integrations

Apple Health

Health Connect

Wearables

Smart Meal Planner

Generate meals based on:

Calories

Protein

Diet preference

Budget

Indian foods

Grocery Planning

Create grocery lists from meal plans.

Notifications

Examples:

You haven't logged water recently.

Today's protein target is still incomplete.

Lower Body workout scheduled today.

Notifications should be configurable.

46. DEVELOPMENT PHASES

Do NOT attempt everything simultaneously.

PHASE 1 — FOUNDATION

Build:

Project architecture

Authentication

Database

User profile

Onboarding

Goal selection

BMR

TDEE

Daily targets

Test thoroughly.

PHASE 2 — NUTRITION

Build:

Food database

Indian foods

Food search

Quantity conversion

Meal logging

Daily calories

Macros

Custom foods

Recent foods

Favorites

PHASE 3 — DASHBOARD & HYDRATION

Build:

Dashboard

Calorie progress

Protein progress

Macro progress

Water tracking

Daily overview

PHASE 4 — WORKOUTS

Build:

Exercise database

Workout builder

Workout programs

Sets

Reps

Weight

Workout history

PHASE 5 — ACTIVITY

Build:

Walking

Cycling

Running

Steps

Duration

Distance

Intensity

Estimated calorie expenditure

PHASE 6 — PROGRESS

Build:

Weight logging

Measurements

Weight trends

Charts

Strength progression

Workout consistency

PHASE 7 — ADMIN

Build:

Admin dashboard

Food management

Brand management

Exercise management

Workout plans

User management

Audit logs

PHASE 8 — SMART FEATURES

Build:

Daily insights

Remaining macro recommendations

Food suggestions

Progress summaries

Meal recommendations

PHASE 9 — ADVANCED FEATURES

Potentially add:

Barcode scanning

Health integrations

Notifications

Meal photo recognition

Meal planning

Grocery planning

Data export

47. TESTING REQUIREMENTS

Do not simply generate features and assume they work.

For every module:

Implement the feature.

Test frontend behavior.

Test backend endpoints.

Test database operations.

Test authentication.

Test authorization.

Test validation.

Test mobile responsiveness.

Test empty states.

Test loading states.

Test error states.

Fix discovered problems before continuing.

Add automated tests where practical.

48. IMPORTANT CALCULATION TESTS

Nutrition calculations need special testing.

Test scenarios such as:

100 g Paneer
125 g Paneer
250 g Paneer

1 Chapati
2 Chapatis
4 Chapatis

100 ml Milk
250 ml Milk
500 ml Milk


Verify calculations remain accurate when quantities change.

Test rounding carefully.

Do calculations using full precision internally and round primarily for display.

49. USER EXPERIENCE PRINCIPLE

The most important workflow in the entire application is:

Open App → Add Food → Select Quantity → Save

This should take only a few seconds.

The second most important workflow is:

Open App → See exactly where I stand today.

A user should immediately understand:

I've eaten 1,450 of my 2,100 calories.

I've consumed 82 of my 125 g protein.

I've drunk 1.8 of 3 L water.

I've completed 8,400 steps.

I've completed today's workout.

No complicated navigation should be required.

50. FINAL PRODUCT VISION

The final application should combine:

Nutrition Tracking

Indian Food Database

Calorie & Macro Tracking

Hydration

Activity Tracking

Steps

Workout Logging

Exercise Programs

Body Progress

Strength Progress

Personalized Goals

Smart Recommendations

into one unified application.

Think of the product as:

A personal dashboard for understanding what you eat, how you train, how active you are, and whether you're actually progressing toward your fitness goal.

The application should help users make better decisions without encouraging obsessive calorie compensation or unsafe dieting.

DEVELOPMENT INSTRUCTION

Before writing large amounts of code:

Analyze all requirements.

Define the technology architecture.

Define frontend architecture.

Define backend architecture.

Design the complete database schema.

Define authentication and authorization strategy.

Define API structure.

Define nutrition calculation methodology.

Define activity-calorie methodology.

Define application routes/pages.

Define reusable UI components.

Identify security concerns.

Identify edge cases.

Create the development roadmap.

Create the project folder structure.

Then begin implementation phase by phase.

Do not generate placeholder buttons or fake functionality just to make the UI look complete.

Every implemented feature should actually work.

Do not rewrite working modules unnecessarily when progressing to later phases.

Maintain consistent architecture throughout the project.

After completing each phase:

Audit the code

Check for duplicated logic

Check TypeScript/build errors if applicable

Check database integrity

Check responsive behavior

Check authentication/authorization

Check calculation accuracy

Fix issues

Then continue

The objective is a maintainable, scalable, secure, production-quality application, not merely a visually impressive prototype.

This project was built with [Lovable](https://lovable.dev).

## Build with Lovable

Continue developing this project in the [Lovable editor](https://lovable.dev/projects/7184238d-208b-45f3-9d8f-6d3ab073c5e8).

- **Ship faster**: describe what you want to build and Lovable handles the code.
- **Stay in sync**: every change made in Lovable is committed straight to this repository.
- **Full ownership**: this code is yours. Push to `main` on GitHub and your changes sync back into Lovable, ready for your next prompt.

## Development

Prefer working locally? You need Node.js and npm — [install with nvm](https://github.com/nvm-sh/nvm#installing-and-updating).

```sh
git clone <this-repository-url>
cd <repository-name>
npm i
npm run dev
```
