# Notification Troubleshooting Guide

## Common Issues with Scheduled Notifications

### 1. **Android Battery Optimization**
- **Problem**: Android may kill the app or prevent notifications to save battery
- **Solution**: 
  - Go to Settings > Apps > Plant Care > Battery > Battery Optimization
  - Select "Don't optimize" for the Plant Care app

### 2. **Exact Alarm Permissions (Android 12+)**
- **Problem**: Android 12+ requires special permission for exact alarms
- **Solution**:
  - The app should request this automatically
  - If not working, go to Settings > Apps > Plant Care > Permissions
  - Enable "Alarms & reminders" permission

### 3. **Notification Permissions**
- **Problem**: Notifications are disabled for the app
- **Solution**:
  - Go to Settings > Apps > Plant Care > Notifications
  - Enable all notification categories

### 4. **Do Not Disturb Mode**
- **Problem**: Phone is in Do Not Disturb mode
- **Solution**: 
  - Disable Do Not Disturb or
  - Add Plant Care to allowed apps in DND settings

### 5. **Time Zone Issues**
- **Problem**: Notifications scheduled for wrong time zone
- **Solution**: Ensure phone's time zone is correct

## Debug Features in the App

### Test Buttons in Home Screen:
1. **Clock Icon**: Schedule test notification for 1 minute
2. **Bell Icon**: Schedule test notification for 5 seconds  
3. **Info Icon**: Check notification permissions and status
4. **Clear Icon**: Clear all plant data

### Console Logs to Check:
- Look for "🔔 Scheduling notifications" messages
- Check "✅ Notification scheduled successfully" confirmations
- Verify "📋 Pending notifications" count
- Monitor "⏰ Exact alarm permission" status

## Testing Steps:

1. **Test Immediate Notifications**: Use the 5-second test button
2. **Test Scheduled Notifications**: Use the 1-minute test button
3. **Check Permissions**: Use the info button to verify all permissions
4. **Create Custom Plant**: Add a plant with custom watering times
5. **Monitor Console**: Watch debug logs for any errors

## If Notifications Still Don't Work:

1. **Restart the app** completely
2. **Restart the phone** to refresh system services
3. **Check Android version** - some older versions have limitations
4. **Try different times** - avoid times that have already passed today
5. **Check phone manufacturer settings** - some brands (Samsung, Xiaomi, etc.) have additional battery optimization settings

## Expected Behavior:

- ✅ Test notifications (5 seconds) should work immediately
- ✅ Test notifications (1 minute) should arrive exactly after 1 minute
- ✅ Plant watering notifications should repeat daily at scheduled times
- ✅ Custom schedule notifications should work for any time set by user