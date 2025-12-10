# Smart Classroom Dashboard Setup Guide

## Overview
The Smart Classroom app now includes a comprehensive dashboard that displays:
- Weekly learning progress
- Current subjects
- Today's class schedule
- Upcoming assignments with deadlines
- AI-powered learning recommendations

## Database Setup

### 1. Run the Schema
Execute the `supabase_schema.sql` file in your Supabase SQL editor to create all necessary tables, policies, and functions.

### 2. Populate Sample Data (Optional)
For testing purposes, you can populate sample data using the `sample_data.sql` file:

1. Register a user in the app
2. Get the user ID from Supabase Auth dashboard (Auth > Users)
3. Run the function: `SELECT populate_sample_data_for_user('your-user-uuid-here');`

## Dashboard Features

### Weekly Learning Progress
- Displays average progress across all enrolled subjects
- Color-coded progress bar (green ≥80%, orange ≥60%, red <60%)
- Based on `learning_progress` table data

### Current Subjects
- Shows all subjects the user is enrolled in
- Fetched from `user_subjects` and `subjects` tables

### Today's Class Schedule
- Lists all classes scheduled for the current day
- Includes time, location, and subject information
- Ordered by start time

### Upcoming Assignments
- Shows assignments due within the next 7 days
- Color-coded by priority (red=high, orange=medium, green=low)
- Excludes completed assignments

### AI Recommendations
- Automatically generated based on learning history and quiz performance
- Considers:
  - Subjects with below-average quiz scores
  - Subjects not studied recently
  - Learning patterns and gaps
- Uses the `generate_ai_recommendations` PostgreSQL function

## Data Flow

### User Registration/Login
1. User registers/logs in via Supabase Auth
2. User data stored in `auth.users`

### Dashboard Data Loading
1. App fetches user ID from Supabase Auth
2. Parallel queries to all dashboard tables
3. AI recommendations generated/refreshed on each load
4. Data displayed in organized cards

### Real-time Updates
- Refresh button in app bar to reload all data
- Data automatically updates when user completes activities

## Database Tables

### Core Tables
- `subjects` - Available subjects
- `user_subjects` - User enrollments
- `learning_progress` - Weekly progress tracking
- `quiz_scores` - Quiz results
- `class_schedules` - Class timetables
- `assignments` - Homework/tasks
- `learning_history` - Activity log
- `ai_recommendations` - AI suggestions

### Security
- Row Level Security (RLS) enabled on all tables
- Users can only access their own data
- Policies ensure data privacy

## AI Recommendation Algorithm

The AI system analyzes:
1. **Quiz Performance**: Identifies weak subjects (below average scores)
2. **Learning Gaps**: Finds subjects not studied recently
3. **Activity Patterns**: Considers study frequency and duration

Recommendations are prioritized by:
- Performance gap severity
- Time since last study
- Subject difficulty level

## Testing the Dashboard

1. **Setup Database**: Run schema and sample data
2. **Register/Login**: Create a user account
3. **View Dashboard**: Navigate to home screen after login
4. **Test Features**:
   - Check progress calculations
   - Verify schedule display
   - Review assignment priorities
   - Examine AI recommendations

## Future Enhancements

Potential improvements:
- Real-time notifications for deadlines
- Progress charts and analytics
- Study streak tracking
- Peer comparison features
- Advanced AI personalization
- Mobile push notifications

## Troubleshooting

### No Data Displayed
- Ensure user is properly authenticated
- Check Supabase connection and API key
- Verify sample data is inserted for the user
- Check browser console for errors

### AI Recommendations Not Working
- Ensure `generate_ai_recommendations` function exists
- Check learning history and quiz data exists
- Verify function permissions in Supabase

### Performance Issues
- Consider adding database indexes on frequently queried columns
- Implement data caching in the app
- Use pagination for large datasets