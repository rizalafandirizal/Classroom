# Smart Classroom - Online Classes Feature

## Overview

The Online Classes feature provides a comprehensive learning management system with the following components:

- **Class Management**: Browse and enroll in available classes
- **Materials**: Access videos, PDFs, articles, and external links
- **Discussion Forum**: Interactive forum for class discussions
- **Assignments**: Submit and grade class assignments
- **Online Quizzes**: Take timed quizzes and exams
- **Participant Management**: View class participants and enrollment

## Database Schema

### Core Tables

#### `classes`
- Class information, teacher, schedule, enrollment limits
- Fields: title, description, subject_id, teacher_id, start_date, end_date, max_students, is_active

#### `class_enrollments`
- Student enrollment records
- Fields: class_id, user_id, enrolled_at, status, progress_percentage

#### `class_materials`
- Learning materials (videos, PDFs, articles, links)
- Fields: class_id, title, description, material_type, content_url, content_text, external_link, order_index, is_published

#### `forum_topics` & `forum_replies`
- Discussion forum with topics and threaded replies
- Fields: class_id, user_id, title, content, is_pinned, is_locked, parent_reply_id

#### `class_assignments`
- Assignment definitions with due dates and instructions
- Fields: class_id, title, description, due_date, max_score, assignment_type, allow_late_submission

#### `assignment_submissions`
- Student submissions with grading
- Fields: assignment_id, user_id, submission_text, submission_files, score, feedback

#### `quizzes` & `quiz_questions`
- Quiz definitions and questions
- Fields: class_id, title, time_limit, max_attempts, passing_score, question_text, question_type, options, correct_answer

#### `quiz_attempts` & `quiz_attempt_answers`
- Quiz taking and scoring system
- Fields: quiz_id, user_id, started_at, completed_at, score, attempt_answers

#### `material_progress`
- Track student progress through materials
- Fields: user_id, material_id, is_completed, time_spent, completion_date

## Setup Instructions

### 1. Database Setup
Execute the `online_classes_schema.sql` file in your Supabase SQL editor to create all necessary tables and policies.

### 2. Sample Data (Optional)
Use the sample data functions in `sample_data.sql` to populate test data:

```sql
-- Create a teacher user first, then:
SELECT populate_online_classes_sample_data('teacher-user-uuid', 'student-user-uuid');
```

### 3. Dependencies
The following dependencies are already added to `pubspec.yaml`:
- `supabase_flutter: ^2.0.0`
- `url_launcher: ^6.2.6`

## Feature Implementation

### Class Management (`classes_screen.dart`)
- **Enrolled Classes Tab**: Shows classes the student is enrolled in
- **Available Classes Tab**: Shows classes available for enrollment
- **Enrollment System**: One-click enrollment with capacity checks
- **Class Details**: Tap any class to view detailed information

### Class Detail Screen (`class_detail_screen.dart`)
- **Tabbed Interface**: 5 main sections accessible via tabs
- **Role-based Access**: Different features for teachers vs students
- **Real-time Updates**: Data refreshes when navigating between tabs

### Materials Section (`materials_screen.dart`)
- **Multiple Content Types**:
  - Videos (opens in external player/browser)
  - PDFs (opens in browser/PDF viewer)
  - Articles (displayed inline)
  - External Links (opens in browser)
- **Progress Tracking**: Students can mark materials as completed
- **Teacher Controls**: Teachers can add/edit materials (UI ready, backend integration pending)

### Discussion Forum (`forum_screen.dart`)
- **Topic Creation**: Students and teachers can create discussion topics
- **Threaded Replies**: Nested reply system for discussions
- **Moderation**: Teachers can pin/lock topics
- **Real-time Updates**: New posts appear immediately

### Assignments System (`assignments_screen.dart`)
- **Assignment List**: View all class assignments with due dates
- **Submission System**: Text and file submissions
- **Grading Interface**: Teachers can grade and provide feedback
- **Late Submission Handling**: Configurable late submission policies

### Quiz System (`quizzes_screen.dart`)
- **Quiz Taking**: Timed quizzes with multiple attempts
- **Question Types**: Multiple choice, true/false, short answer
- **Automatic Grading**: Instant scoring for objective questions
- **Progress Tracking**: Quiz history and performance analytics

### Participant Management (`participants_screen.dart`)
- **Enrollment List**: View all enrolled students
- **Teacher Overview**: Class statistics and participant management
- **Student View**: See classmates and teacher information

## Security & Permissions

### Row Level Security (RLS)
All tables use RLS policies ensuring:
- Students can only access their enrolled classes
- Teachers can manage their own classes
- Private data remains secure
- Appropriate read/write permissions

### User Roles
- **Students**: Can view/enroll in classes, submit assignments, take quizzes
- **Teachers**: Can create/manage classes, grade assignments, moderate forums
- **Admins**: Full system access (future enhancement)

## Navigation Flow

```
Dashboard (home_screen.dart)
├── Classes Button → Classes Screen (classes_screen.dart)
    ├── Enrolled Classes Tab
    │   └── Class Card → Class Detail (class_detail_screen.dart)
    │       ├── Materials Tab → Materials Screen
    │       ├── Forum Tab → Forum Screen
    │       ├── Assignments Tab → Assignments Screen
    │       ├── Quizzes Tab → Quizzes Screen
    │       └── Participants Tab → Participants Screen
    └── Available Classes Tab
        └── Enroll Button → Enrollment Process
```

## File Storage

### Supabase Storage Integration
- **Bucket**: `class-materials` for storing uploaded files
- **File Types**: Videos, PDFs, documents, images
- **Access Control**: Enrolled students and teachers only
- **Organization**: Files organized by class ID folders

## API Functions

### Custom PostgreSQL Functions
- `enroll_student(class_uuid, student_uuid)`: Safe enrollment with capacity checks
- `calculate_quiz_score(attempt_uuid)`: Automatic quiz scoring
- `get_class_progress(class_uuid, student_uuid)`: Progress calculation
- `generate_ai_recommendations(user_uuid)`: Learning recommendations

## Current Implementation Status

### ✅ Completed Features
- Database schema with full RLS policies
- Class listing and enrollment system
- Class detail screen with tabbed interface
- Materials display with progress tracking
- Basic navigation and UI structure
- Supabase integration throughout

### 🔄 Partially Implemented
- Materials section (display and progress tracking complete, upload pending)
- Basic screen structures for all tabs

### ⏳ Pending Features
- Discussion forum functionality
- Assignment submission and grading
- Quiz taking and scoring system
- Participant management interface
- File upload capabilities
- Teacher management tools

## Testing the Current Implementation

### Basic Testing Flow
1. **Setup Database**: Run `online_classes_schema.sql`
2. **Create Sample Data**: Use sample data functions
3. **Register/Login**: Access the app
4. **Navigate to Classes**: Use the school icon in dashboard
5. **Browse Classes**: View enrolled and available classes
6. **Enter Class**: Tap any class to see the tabbed interface
7. **View Materials**: Check the materials tab (if sample data exists)

### Sample Data Creation
```sql
-- 1. Register users in the app first
-- 2. Get their UUIDs from Supabase Auth dashboard
-- 3. Run sample data creation:
SELECT populate_online_classes_sample_data('teacher-uuid', 'student-uuid');
```

## Future Enhancements

### High Priority
- Complete forum, assignments, and quiz implementations
- File upload and storage integration
- Teacher dashboard for class management
- Notification system for deadlines and updates

### Medium Priority
- Real-time chat within classes
- Video conferencing integration
- Advanced analytics and reporting
- Mobile-responsive design improvements

### Low Priority
- Offline content access
- Advanced quiz question types
- Peer grading system
- Certificate generation

## Troubleshooting

### Common Issues
- **No Classes Showing**: Ensure sample data is created and user is enrolled
- **Permission Errors**: Check RLS policies and user authentication
- **File Upload Issues**: Verify Supabase Storage bucket configuration
- **Navigation Problems**: Ensure all screen files are properly imported

### Debug Steps
1. Check Supabase logs for database errors
2. Verify user authentication status
3. Test with different user roles (student/teacher)
4. Check network connectivity for file operations

## Performance Considerations

- **Lazy Loading**: Implement pagination for large class lists
- **Caching**: Cache frequently accessed data locally
- **Optimized Queries**: Use Supabase's built-in query optimization
- **File Compression**: Compress uploads to reduce storage and bandwidth

This online classes system provides a solid foundation for a comprehensive learning management platform, with room for future enhancements and feature additions.