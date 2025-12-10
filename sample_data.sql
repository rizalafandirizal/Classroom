-- Sample Data for Smart Classroom Dashboard Testing

-- Get the current user ID (replace with actual user ID after registration)
-- For testing, you can get the user ID from Supabase Auth users table

-- Sample subjects are already inserted in schema.sql

-- Sample user enrollment (replace 'user-uuid-here' with actual user ID)
-- INSERT INTO user_subjects (user_id, subject_id) VALUES
-- ('user-uuid-here', (SELECT id FROM subjects WHERE name = 'Mathematics')),
-- ('user-uuid-here', (SELECT id FROM subjects WHERE name = 'Physics')),
-- ('user-uuid-here', (SELECT id FROM subjects WHERE name = 'Computer Science'));

-- Sample learning progress (replace 'user-uuid-here' with actual user ID)
-- INSERT INTO learning_progress (user_id, subject_id, week_start, progress_percentage, study_hours) VALUES
-- ('user-uuid-here', (SELECT id FROM subjects WHERE name = 'Mathematics'), CURRENT_DATE - INTERVAL '7 days', 75.5, 12.5),
-- ('user-uuid-here', (SELECT id FROM subjects WHERE name = 'Physics'), CURRENT_DATE - INTERVAL '7 days', 68.2, 10.0),
-- ('user-uuid-here', (SELECT id FROM subjects WHERE name = 'Computer Science'), CURRENT_DATE - INTERVAL '7 days', 82.1, 15.3);

-- Sample quiz scores (replace 'user-uuid-here' with actual user ID)
-- INSERT INTO quiz_scores (user_id, subject_id, quiz_title, score, max_score) VALUES
-- ('user-uuid-here', (SELECT id FROM subjects WHERE name = 'Mathematics'), 'Algebra Quiz 1', 85, 100),
-- ('user-uuid-here', (SELECT id FROM subjects WHERE name = 'Mathematics'), 'Geometry Quiz 1', 92, 100),
-- ('user-uuid-here', (SELECT id FROM subjects WHERE name = 'Physics'), 'Mechanics Quiz 1', 78, 100),
-- ('user-uuid-here', (SELECT id FROM subjects WHERE name = 'Computer Science'), 'Programming Quiz 1', 95, 100);

-- Sample class schedules (replace 'user-uuid-here' with actual user ID)
-- INSERT INTO class_schedules (subject_id, user_id, title, description, scheduled_date, start_time, end_time, location) VALUES
-- ((SELECT id FROM subjects WHERE name = 'Mathematics'), 'user-uuid-here', 'Advanced Calculus', 'Differential equations and integrals', CURRENT_DATE, '09:00', '10:30', 'Room 101'),
-- ((SELECT id FROM subjects WHERE name = 'Physics'), 'user-uuid-here', 'Quantum Physics', 'Introduction to quantum mechanics', CURRENT_DATE, '11:00', '12:30', 'Lab 203'),
-- ((SELECT id FROM subjects WHERE name = 'Computer Science'), 'user-uuid-here', 'Data Structures', 'Trees and graphs', CURRENT_DATE + INTERVAL '1 day', '14:00', '15:30', 'Computer Lab');

-- Sample assignments (replace 'user-uuid-here' with actual user ID)
-- INSERT INTO assignments (subject_id, user_id, title, description, due_date, priority) VALUES
-- ((SELECT id FROM subjects WHERE name = 'Mathematics'), 'user-uuid-here', 'Calculus Problem Set', 'Complete exercises 1-20 from chapter 5', CURRENT_DATE + INTERVAL '3 days', 'high'),
-- ((SELECT id FROM subjects WHERE name = 'Physics'), 'user-uuid-here', 'Lab Report', 'Submit quantum physics lab report', CURRENT_DATE + INTERVAL '5 days', 'medium'),
-- ((SELECT id FROM subjects WHERE name = 'Computer Science'), 'user-uuid-here', 'Algorithm Implementation', 'Implement sorting algorithms in Python', CURRENT_DATE + INTERVAL '7 days', 'medium');

-- Sample learning history (replace 'user-uuid-here' with actual user ID)
-- INSERT INTO learning_history (user_id, subject_id, activity_type, activity_title, duration_minutes, metadata) VALUES
-- ('user-uuid-here', (SELECT id FROM subjects WHERE name = 'Mathematics'), 'study', 'Chapter 5: Differential Calculus', 45, '{"pages_read": 15, "difficulty": "medium"}'),
-- ('user-uuid-here', (SELECT id FROM subjects WHERE name = 'Physics'), 'quiz', 'Mechanics Quiz 1', 30, '{"score": 78, "max_score": 100}'),
-- ('user-uuid-here', (SELECT id FROM subjects WHERE name = 'Computer Science'), 'assignment', 'Data Structures Homework', 60, '{"completed": true}');

-- Note: To use this sample data:
-- 1. Register a user in the app
-- 2. Get the user ID from Supabase Auth dashboard
-- 3. Replace 'user-uuid-here' with the actual user ID
-- 4. Run these INSERT statements in Supabase SQL editor
-- 5. The dashboard will then display the sample data

-- Alternative: Create a function to auto-populate sample data for new users
CREATE OR REPLACE FUNCTION populate_sample_data_for_user(user_uuid UUID)
RETURNS VOID AS $$
DECLARE
    math_id UUID;
    physics_id UUID;
    cs_id UUID;
BEGIN
    -- Get subject IDs
    SELECT id INTO math_id FROM subjects WHERE name = 'Mathematics';
    SELECT id INTO physics_id FROM subjects WHERE name = 'Physics';
    SELECT id INTO cs_id FROM subjects WHERE name = 'Computer Science';

    -- Enroll user in subjects
    INSERT INTO user_subjects (user_id, subject_id) VALUES
    (user_uuid, math_id),
    (user_uuid, physics_id),
    (user_uuid, cs_id);

    -- Add learning progress
    INSERT INTO learning_progress (user_id, subject_id, week_start, progress_percentage, study_hours) VALUES
    (user_uuid, math_id, CURRENT_DATE - INTERVAL '7 days', 75.5, 12.5),
    (user_uuid, physics_id, CURRENT_DATE - INTERVAL '7 days', 68.2, 10.0),
    (user_uuid, cs_id, CURRENT_DATE - INTERVAL '7 days', 82.1, 15.3);

    -- Add quiz scores
    INSERT INTO quiz_scores (user_id, subject_id, quiz_title, score, max_score) VALUES
    (user_uuid, math_id, 'Algebra Quiz 1', 85, 100),
    (user_uuid, math_id, 'Geometry Quiz 1', 92, 100),
    (user_uuid, physics_id, 'Mechanics Quiz 1', 78, 100),
    (user_uuid, cs_id, 'Programming Quiz 1', 95, 100);

    -- Add class schedules
    INSERT INTO class_schedules (subject_id, user_id, title, description, scheduled_date, start_time, end_time, location) VALUES
    (math_id, user_uuid, 'Advanced Calculus', 'Differential equations and integrals', CURRENT_DATE, '09:00', '10:30', 'Room 101'),
    (physics_id, user_uuid, 'Quantum Physics', 'Introduction to quantum mechanics', CURRENT_DATE, '11:00', '12:30', 'Lab 203'),
    (cs_id, user_uuid, 'Data Structures', 'Trees and graphs', CURRENT_DATE + INTERVAL '1 day', '14:00', '15:30', 'Computer Lab');

    -- Add assignments
    INSERT INTO assignments (subject_id, user_id, title, description, due_date, priority) VALUES
    (math_id, user_uuid, 'Calculus Problem Set', 'Complete exercises 1-20 from chapter 5', CURRENT_DATE + INTERVAL '3 days', 'high'),
    (physics_id, user_uuid, 'Lab Report', 'Submit quantum physics lab report', CURRENT_DATE + INTERVAL '5 days', 'medium'),
    (cs_id, user_uuid, 'Algorithm Implementation', 'Implement sorting algorithms in Python', CURRENT_DATE + INTERVAL '7 days', 'medium');

    -- Add learning history
    INSERT INTO learning_history (user_id, subject_id, activity_type, activity_title, duration_minutes, metadata) VALUES
    (user_uuid, math_id, 'study', 'Chapter 5: Differential Calculus', 45, '{"pages_read": 15, "difficulty": "medium"}'),
    (user_uuid, physics_id, 'quiz', 'Mechanics Quiz 1', 30, '{"score": 78, "max_score": 100}'),
    (user_uuid, cs_id, 'assignment', 'Data Structures Homework', 60, '{"completed": true}');

END;
$$ LANGUAGE plpgsql;

-- To populate sample data for a user, run:
-- SELECT populate_sample_data_for_user('your-user-uuid-here');