-- Online Classes Schema for Smart Classroom
-- Run this after the main dashboard schema

-- User roles for class management
CREATE TABLE IF NOT EXISTS user_roles (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL DEFAULT 'student', -- student, teacher, admin
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);

-- Online classes
CREATE TABLE IF NOT EXISTS classes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    subject_id UUID REFERENCES subjects(id),
    teacher_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    start_date DATE,
    end_date DATE,
    max_students INTEGER DEFAULT 50,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Class enrollments
CREATE TABLE IF NOT EXISTS class_enrollments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    class_id UUID REFERENCES classes(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status VARCHAR(50) DEFAULT 'active', -- active, completed, dropped
    progress_percentage DECIMAL(5,2) DEFAULT 0,
    UNIQUE(class_id, user_id)
);

-- Class materials
CREATE TABLE IF NOT EXISTS class_materials (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    class_id UUID REFERENCES classes(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    material_type VARCHAR(50) NOT NULL, -- video, pdf, article, link
    content_url TEXT, -- For videos and files stored in Supabase Storage
    content_text TEXT, -- For articles/text content
    external_link TEXT, -- For external resources
    order_index INTEGER DEFAULT 0,
    is_published BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Discussion forum topics
CREATE TABLE IF NOT EXISTS forum_topics (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    class_id UUID REFERENCES classes(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    is_pinned BOOLEAN DEFAULT false,
    is_locked BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Discussion forum replies
CREATE TABLE IF NOT EXISTS forum_replies (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    topic_id UUID REFERENCES forum_topics(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    parent_reply_id UUID REFERENCES forum_replies(id) ON DELETE CASCADE, -- For nested replies
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Class assignments
CREATE TABLE IF NOT EXISTS class_assignments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    class_id UUID REFERENCES classes(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    instructions TEXT,
    due_date TIMESTAMP WITH TIME ZONE NOT NULL,
    max_score DECIMAL(5,2) DEFAULT 100,
    assignment_type VARCHAR(50) DEFAULT 'file', -- file, text, link
    allow_late_submission BOOLEAN DEFAULT false,
    is_published BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Assignment submissions
CREATE TABLE IF NOT EXISTS assignment_submissions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    assignment_id UUID REFERENCES class_assignments(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    submission_text TEXT, -- For text submissions
    submission_files JSONB, -- Array of file URLs for file submissions
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    score DECIMAL(5,2),
    feedback TEXT,
    graded_by UUID REFERENCES auth.users(id),
    graded_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(assignment_id, user_id)
);

-- Quizzes
CREATE TABLE IF NOT EXISTS quizzes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    class_id UUID REFERENCES classes(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    time_limit_minutes INTEGER, -- NULL for no time limit
    max_attempts INTEGER DEFAULT 1,
    passing_score DECIMAL(5,2) DEFAULT 60,
    is_published BOOLEAN DEFAULT false,
    due_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Quiz questions
CREATE TABLE IF NOT EXISTS quiz_questions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    quiz_id UUID REFERENCES quizzes(id) ON DELETE CASCADE,
    question_text TEXT NOT NULL,
    question_type VARCHAR(50) NOT NULL DEFAULT 'multiple_choice', -- multiple_choice, true_false, short_answer
    options JSONB, -- For multiple choice options
    correct_answer TEXT NOT NULL, -- JSON string for multiple answers
    points DECIMAL(5,2) DEFAULT 1,
    order_index INTEGER DEFAULT 0,
    explanation TEXT, -- Explanation for correct answer
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Quiz attempts
CREATE TABLE IF NOT EXISTS quiz_attempts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    quiz_id UUID REFERENCES quizzes(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    time_spent_minutes INTEGER,
    score DECIMAL(5,2),
    max_score DECIMAL(5,2),
    is_passed BOOLEAN DEFAULT false,
    attempt_number INTEGER DEFAULT 1
);

-- Quiz attempt answers
CREATE TABLE IF NOT EXISTS quiz_attempt_answers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    attempt_id UUID REFERENCES quiz_attempts(id) ON DELETE CASCADE,
    question_id UUID REFERENCES quiz_questions(id) ON DELETE CASCADE,
    user_answer TEXT,
    is_correct BOOLEAN,
    points_earned DECIMAL(5,2) DEFAULT 0,
    answered_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Material views/progress tracking
CREATE TABLE IF NOT EXISTS material_progress (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    material_id UUID REFERENCES class_materials(id) ON DELETE CASCADE,
    is_completed BOOLEAN DEFAULT false,
    time_spent_minutes INTEGER DEFAULT 0,
    last_accessed TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completion_date TIMESTAMP WITH TIME ZONE,
    UNIQUE(user_id, material_id)
);

-- Enable Row Level Security
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE class_enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE class_materials ENABLE ROW LEVEL SECURITY;
ALTER TABLE forum_topics ENABLE ROW LEVEL SECURITY;
ALTER TABLE forum_replies ENABLE ROW LEVEL SECURITY;
ALTER TABLE class_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignment_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_attempt_answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE material_progress ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- User roles: users can read their own roles, teachers/admins can read all
CREATE POLICY "Users can view their own roles" ON user_roles
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Teachers and admins can view all roles" ON user_roles
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM user_roles ur
            WHERE ur.user_id = auth.uid()
            AND ur.role IN ('teacher', 'admin')
        )
    );

-- Classes: anyone can view active classes, teachers can manage their classes
CREATE POLICY "Anyone can view active classes" ON classes
    FOR SELECT USING (is_active = true);

CREATE POLICY "Teachers can manage their classes" ON classes
    FOR ALL USING (auth.uid() = teacher_id);

-- Class enrollments: enrolled users and teachers can view
CREATE POLICY "Enrolled users and teachers can view enrollments" ON class_enrollments
    FOR SELECT USING (
        auth.uid() = user_id OR
        EXISTS (
            SELECT 1 FROM classes c
            WHERE c.id = class_id AND c.teacher_id = auth.uid()
        )
    );

CREATE POLICY "Users can enroll themselves" ON class_enrollments
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Class materials: enrolled users and teachers can view
CREATE POLICY "Enrolled users and teachers can view materials" ON class_materials
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM class_enrollments ce
            WHERE ce.class_id = class_materials.class_id
            AND ce.user_id = auth.uid()
            AND ce.status = 'active'
        ) OR
        EXISTS (
            SELECT 1 FROM classes c
            WHERE c.id = class_materials.class_id
            AND c.teacher_id = auth.uid()
        )
    );

CREATE POLICY "Teachers can manage materials" ON class_materials
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM classes c
            WHERE c.id = class_materials.class_id
            AND c.teacher_id = auth.uid()
        )
    );

-- Forum topics: enrolled users and teachers can view and post
CREATE POLICY "Enrolled users and teachers can view topics" ON forum_topics
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM class_enrollments ce
            WHERE ce.class_id = forum_topics.class_id
            AND ce.user_id = auth.uid()
            AND ce.status = 'active'
        ) OR
        EXISTS (
            SELECT 1 FROM classes c
            WHERE c.id = forum_topics.class_id
            AND c.teacher_id = auth.uid()
        )
    );

CREATE POLICY "Enrolled users can create topics" ON forum_topics
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM class_enrollments ce
            WHERE ce.class_id = forum_topics.class_id
            AND ce.user_id = auth.uid()
            AND ce.status = 'active'
        )
    );

-- Forum replies: enrolled users and teachers can view and post
CREATE POLICY "Enrolled users and teachers can view replies" ON forum_replies
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM forum_topics ft
            JOIN class_enrollments ce ON ft.class_id = ce.class_id
            WHERE ft.id = forum_replies.topic_id
            AND ce.user_id = auth.uid()
            AND ce.status = 'active'
        ) OR
        EXISTS (
            SELECT 1 FROM forum_topics ft
            JOIN classes c ON ft.class_id = c.id
            WHERE ft.id = forum_replies.topic_id
            AND c.teacher_id = auth.uid()
        )
    );

CREATE POLICY "Enrolled users can create replies" ON forum_replies
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM forum_topics ft
            JOIN class_enrollments ce ON ft.class_id = ce.class_id
            WHERE ft.id = forum_replies.topic_id
            AND ce.user_id = auth.uid()
            AND ce.status = 'active'
        )
    );

-- Assignments: enrolled users and teachers can view
CREATE POLICY "Enrolled users and teachers can view assignments" ON class_assignments
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM class_enrollments ce
            WHERE ce.class_id = class_assignments.class_id
            AND ce.user_id = auth.uid()
            AND ce.status = 'active'
        ) OR
        EXISTS (
            SELECT 1 FROM classes c
            WHERE c.id = class_assignments.class_id
            AND c.teacher_id = auth.uid()
        )
    );

CREATE POLICY "Teachers can manage assignments" ON class_assignments
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM classes c
            WHERE c.id = class_assignments.class_id
            AND c.teacher_id = auth.uid()
        )
    );

-- Assignment submissions: students can submit, teachers can grade
CREATE POLICY "Students can submit assignments" ON assignment_submissions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Students and teachers can view submissions" ON assignment_submissions
    FOR SELECT USING (
        auth.uid() = user_id OR
        EXISTS (
            SELECT 1 FROM class_assignments ca
            JOIN classes c ON ca.class_id = c.id
            WHERE ca.id = assignment_submissions.assignment_id
            AND c.teacher_id = auth.uid()
        )
    );

-- Quizzes: enrolled users and teachers can view
CREATE POLICY "Enrolled users and teachers can view quizzes" ON quizzes
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM class_enrollments ce
            WHERE ce.class_id = quizzes.class_id
            AND ce.user_id = auth.uid()
            AND ce.status = 'active'
        ) OR
        EXISTS (
            SELECT 1 FROM classes c
            WHERE c.id = quizzes.class_id
            AND c.teacher_id = auth.uid()
        )
    );

-- Quiz questions: enrolled users and teachers can view
CREATE POLICY "Enrolled users and teachers can view questions" ON quiz_questions
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM quizzes q
            JOIN class_enrollments ce ON q.class_id = ce.class_id
            WHERE q.id = quiz_questions.quiz_id
            AND ce.user_id = auth.uid()
            AND ce.status = 'active'
        ) OR
        EXISTS (
            SELECT 1 FROM quizzes q
            JOIN classes c ON q.class_id = c.id
            WHERE q.id = quiz_questions.quiz_id
            AND c.teacher_id = auth.uid()
        )
    );

-- Quiz attempts: students can create attempts, teachers can view all
CREATE POLICY "Students can create attempts" ON quiz_attempts
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Students and teachers can view attempts" ON quiz_attempts
    FOR SELECT USING (
        auth.uid() = user_id OR
        EXISTS (
            SELECT 1 FROM quizzes q
            JOIN classes c ON q.class_id = c.id
            WHERE q.id = quiz_attempts.quiz_id
            AND c.teacher_id = auth.uid()
        )
    );

-- Material progress: users can track their own progress
CREATE POLICY "Users can manage their material progress" ON material_progress
    FOR ALL USING (auth.uid() = user_id);

-- Functions for online classes

-- Function to enroll student in class
CREATE OR REPLACE FUNCTION enroll_student(class_uuid UUID, student_uuid UUID)
RETURNS VOID AS $$
DECLARE
    current_count INTEGER;
    max_count INTEGER;
BEGIN
    -- Check if class exists and is active
    IF NOT EXISTS (SELECT 1 FROM classes WHERE id = class_uuid AND is_active = true) THEN
        RAISE EXCEPTION 'Class not found or inactive';
    END IF;

    -- Check current enrollment count
    SELECT COUNT(*) INTO current_count FROM class_enrollments WHERE class_id = class_uuid AND status = 'active';
    SELECT max_students INTO max_count FROM classes WHERE id = class_uuid;

    IF current_count >= max_count THEN
        RAISE EXCEPTION 'Class is full';
    END IF;

    -- Check if already enrolled
    IF EXISTS (SELECT 1 FROM class_enrollments WHERE class_id = class_uuid AND user_id = student_uuid) THEN
        RAISE EXCEPTION 'Already enrolled in this class';
    END IF;

    -- Enroll student
    INSERT INTO class_enrollments (class_id, user_id) VALUES (class_uuid, student_uuid);
END;
$$ LANGUAGE plpgsql;

-- Function to calculate quiz score
CREATE OR REPLACE FUNCTION calculate_quiz_score(attempt_uuid UUID)
RETURNS DECIMAL(5,2) AS $$
DECLARE
    total_points DECIMAL(5,2) := 0;
    earned_points DECIMAL(5,2) := 0;
BEGIN
    SELECT
        COALESCE(SUM(qq.points), 0),
        COALESCE(SUM(qaa.points_earned), 0)
    INTO total_points, earned_points
    FROM quiz_attempt_answers qaa
    JOIN quiz_questions qq ON qaa.question_id = qq.id
    WHERE qaa.attempt_id = attempt_uuid;

    IF total_points = 0 THEN
        RETURN 0;
    END IF;

    RETURN (earned_points / total_points) * 100;
END;
$$ LANGUAGE plpgsql;

-- Function to get class progress for student
CREATE OR REPLACE FUNCTION get_class_progress(class_uuid UUID, student_uuid UUID)
RETURNS DECIMAL(5,2) AS $$
DECLARE
    total_materials INTEGER;
    completed_materials INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_materials FROM class_materials WHERE class_id = class_uuid AND is_published = true;
    SELECT COUNT(*) INTO completed_materials
    FROM material_progress mp
    JOIN class_materials cm ON mp.material_id = cm.id
    WHERE cm.class_id = class_uuid AND mp.user_id = student_uuid AND mp.is_completed = true;

    IF total_materials = 0 THEN
        RETURN 0;
    END IF;

    RETURN (completed_materials::DECIMAL / total_materials) * 100;
END;
$$ LANGUAGE plpgsql;

-- Create storage bucket for class materials
INSERT INTO storage.buckets (id, name, public)
VALUES ('class-materials', 'class-materials', true)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for class materials
CREATE POLICY "Enrolled users can view class materials" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'class-materials' AND
        EXISTS (
            SELECT 1 FROM class_materials cm
            JOIN class_enrollments ce ON cm.class_id = ce.class_id
            WHERE ce.user_id = auth.uid()
            AND ce.status = 'active'
            AND (storage.foldername(name))[1] = cm.class_id::text
        )
    );

CREATE POLICY "Teachers can upload class materials" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'class-materials' AND
        EXISTS (
            SELECT 1 FROM classes c
            WHERE c.teacher_id = auth.uid()
            AND (storage.foldername(name))[1] = c.id::text
        )
    );

-- Sample data for testing
-- Note: Replace with actual user IDs after registration

-- Create a teacher role
-- INSERT INTO user_roles (user_id, role) VALUES ('teacher-user-uuid', 'teacher');

-- Create sample classes
-- INSERT INTO classes (title, description, subject_id, teacher_id, start_date, end_date) VALUES
-- ('Advanced Mathematics', 'Deep dive into calculus and algebra', (SELECT id FROM subjects WHERE name = 'Mathematics'), 'teacher-user-uuid', CURRENT_DATE, CURRENT_DATE + INTERVAL '30 days'),
-- ('Computer Science Fundamentals', 'Introduction to programming and algorithms', (SELECT id FROM subjects WHERE name = 'Computer Science'), 'teacher-user-uuid', CURRENT_DATE, CURRENT_DATE + INTERVAL '45 days');

-- Enroll students
-- SELECT enroll_student((SELECT id FROM classes WHERE title = 'Advanced Mathematics'), 'student-user-uuid');