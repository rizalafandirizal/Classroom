-- Supabase Schema for Smart Classroom Dashboard

-- Enable Row Level Security
ALTER DEFAULT PRIVILEGES REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;

-- Subjects table
CREATE TABLE IF NOT EXISTS subjects (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User subjects (enrollment)
CREATE TABLE IF NOT EXISTS user_subjects (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    subject_id UUID REFERENCES subjects(id) ON DELETE CASCADE,
    enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, subject_id)
);

-- Learning progress
CREATE TABLE IF NOT EXISTS learning_progress (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    subject_id UUID REFERENCES subjects(id) ON DELETE CASCADE,
    week_start DATE NOT NULL,
    progress_percentage DECIMAL(5,2) DEFAULT 0,
    study_hours DECIMAL(5,2) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, subject_id, week_start)
);

-- Quiz scores
CREATE TABLE IF NOT EXISTS quiz_scores (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    subject_id UUID REFERENCES subjects(id) ON DELETE CASCADE,
    quiz_title VARCHAR(255) NOT NULL,
    score DECIMAL(5,2) NOT NULL,
    max_score DECIMAL(5,2) NOT NULL,
    completed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Class schedules
CREATE TABLE IF NOT EXISTS class_schedules (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    subject_id UUID REFERENCES subjects(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    scheduled_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    location VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Assignments
CREATE TABLE IF NOT EXISTS assignments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    subject_id UUID REFERENCES subjects(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    due_date TIMESTAMP WITH TIME ZONE NOT NULL,
    status VARCHAR(50) DEFAULT 'pending', -- pending, in_progress, completed
    priority VARCHAR(20) DEFAULT 'medium', -- low, medium, high
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Learning history
CREATE TABLE IF NOT EXISTS learning_history (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    subject_id UUID REFERENCES subjects(id) ON DELETE CASCADE,
    activity_type VARCHAR(100) NOT NULL, -- study, quiz, assignment, etc.
    activity_title VARCHAR(255) NOT NULL,
    duration_minutes INTEGER DEFAULT 0,
    completed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    metadata JSONB -- Additional data like quiz score, pages read, etc.
);

-- AI Recommendations
CREATE TABLE IF NOT EXISTS ai_recommendations (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    recommendation_type VARCHAR(100) NOT NULL, -- subject, quiz, study_plan
    title VARCHAR(255) NOT NULL,
    description TEXT,
    subject_id UUID REFERENCES subjects(id),
    priority_score DECIMAL(3,2) DEFAULT 0, -- 0-1 score
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE
);

-- Enable Row Level Security
ALTER TABLE subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE learning_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE class_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE learning_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_recommendations ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Subjects: readable by all authenticated users
CREATE POLICY "Subjects are viewable by authenticated users" ON subjects
    FOR SELECT USING (auth.role() = 'authenticated');

-- User subjects: users can only see their own enrollments
CREATE POLICY "Users can view their own subject enrollments" ON user_subjects
    FOR SELECT USING (auth.uid() = user_id);

-- Learning progress: users can only see their own progress
CREATE POLICY "Users can view their own learning progress" ON learning_progress
    FOR SELECT USING (auth.uid() = user_id);

-- Quiz scores: users can only see their own scores
CREATE POLICY "Users can view their own quiz scores" ON quiz_scores
    FOR SELECT USING (auth.uid() = user_id);

-- Class schedules: users can only see their own schedules
CREATE POLICY "Users can view their own class schedules" ON class_schedules
    FOR SELECT USING (auth.uid() = user_id);

-- Assignments: users can only see their own assignments
CREATE POLICY "Users can view their own assignments" ON assignments
    FOR SELECT USING (auth.uid() = user_id);

-- Learning history: users can only see their own history
CREATE POLICY "Users can view their own learning history" ON learning_history
    FOR SELECT USING (auth.uid() = user_id);

-- AI Recommendations: users can only see their own recommendations
CREATE POLICY "Users can view their own AI recommendations" ON ai_recommendations
    FOR SELECT USING (auth.uid() = user_id);

-- Insert sample data
INSERT INTO subjects (name, description) VALUES
('Mathematics', 'Advanced mathematics concepts'),
('Physics', 'Classical and modern physics'),
('Chemistry', 'Organic and inorganic chemistry'),
('Biology', 'Life sciences and anatomy'),
('Computer Science', 'Programming and algorithms');

-- Function to generate AI recommendations based on user activity
CREATE OR REPLACE FUNCTION generate_ai_recommendations(user_uuid UUID)
RETURNS VOID AS $$
DECLARE
    avg_score DECIMAL;
    weak_subjects UUID[];
    recent_activities RECORD;
BEGIN
    -- Calculate average quiz scores per subject
    SELECT AVG(score/max_score) INTO avg_score
    FROM quiz_scores
    WHERE user_id = user_uuid;

    -- Find subjects with below average performance
    SELECT array_agg(DISTINCT subject_id)
    INTO weak_subjects
    FROM quiz_scores
    WHERE user_id = user_uuid
    GROUP BY subject_id
    HAVING AVG(score/max_score) < avg_score;

    -- Generate recommendations for weak subjects
    IF weak_subjects IS NOT NULL THEN
        INSERT INTO ai_recommendations (user_id, recommendation_type, title, description, subject_id, priority_score)
        SELECT
            user_uuid,
            'subject_review',
            'Review ' || s.name,
            'Based on your quiz performance, we recommend reviewing ' || s.name || ' concepts.',
            s.id,
            0.8
        FROM subjects s
        WHERE s.id = ANY(weak_subjects)
        ON CONFLICT DO NOTHING;
    END IF;

    -- Recommend based on learning gaps (subjects not studied recently)
    INSERT INTO ai_recommendations (user_id, recommendation_type, title, description, subject_id, priority_score)
    SELECT
        user_uuid,
        'catch_up',
        'Catch up on ' || s.name,
        'You haven''t studied ' || s.name || ' recently. Consider reviewing the material.',
        us.subject_id,
        0.6
    FROM user_subjects us
    JOIN subjects s ON us.subject_id = s.id
    WHERE us.user_id = user_uuid
    AND NOT EXISTS (
        SELECT 1 FROM learning_history lh
        WHERE lh.user_id = user_uuid
        AND lh.subject_id = us.subject_id
        AND lh.completed_at > NOW() - INTERVAL '7 days'
    )
    ON CONFLICT DO NOTHING;

END;
$$ LANGUAGE plpgsql;