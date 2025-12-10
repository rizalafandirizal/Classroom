# Troubleshooting Guide - Smart Classroom

## Login Issues After Registration

### Problem: "Can't login after registering"

**Most Common Cause: Email Confirmation Required**

Supabase requires email confirmation by default for security. Here's what to do:

### Step 1: Check Supabase Email Confirmation Settings
1. Go to your Supabase Dashboard
2. Navigate to **Authentication > Settings**
3. Scroll down to **Email Confirmation**
4. If **Enable email confirmations** is ON, you need to confirm your email

### Step 2: Confirm Your Email
1. After registering, check your email inbox (including spam/junk folder)
2. Look for an email from Supabase with subject like "Confirm your email"
3. Click the confirmation link in the email
4. Return to the app and try logging in again

### Step 3: Alternative - Disable Email Confirmation (Development Only)
⚠️ **Warning: Only do this for development/testing. Never disable in production!**

1. In Supabase Dashboard > Authentication > Settings
2. Turn OFF "Enable email confirmations"
3. Save changes
4. Try registering again

### Step 4: Check Your Credentials
- Make sure you're using the exact email you registered with
- Passwords are case-sensitive
- Check for typos in email/password

### Step 5: Clear App Data (if needed)
If you're still having issues:
1. Close the app completely
2. Clear app data/cache
3. Restart the app
4. Try logging in again

## Other Common Issues

### "Invalid login credentials"
- Double-check email and password
- Make sure email is confirmed (see above)

### "Email not confirmed"
- You need to click the confirmation link in your email
- Check spam/junk folder
- The confirmation link expires after 24 hours

### Network Issues
- Make sure you have internet connection
- Try switching between WiFi and mobile data

### App Crashes
- Try restarting the app
- Clear app cache
- Reinstall the app if needed

## Testing Registration/Login

### Quick Test Process:
1. Register with a real email you can access
2. Check email for confirmation link
3. Click the confirmation link
4. Return to app and login with same credentials

### Using Temporary Email (for testing only):
- Services like TempMail, Guerrilla Mail, etc.
- Not recommended for production use

## Supabase Configuration Checklist

- ✅ Supabase URL is correct in `main.dart`
- ✅ Supabase Anon Key is correct in `main.dart`
- ✅ Database schema is applied (`supabase_schema.sql`)
- ✅ Email confirmation settings match your needs
- ✅ SMTP settings are configured (if using custom email)

## Getting Help

If you're still having issues:
1. Check the app logs for error messages
2. Verify your Supabase project settings
3. Test with a different email address
4. Contact support with specific error messages

## Development Notes

For local development, you might want to:
- Disable email confirmation in Supabase settings
- Use test email addresses
- Check Supabase logs in the dashboard for auth errors