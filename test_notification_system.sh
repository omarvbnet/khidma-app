#!/bin/bash

echo "🚀 NOTIFICATION SYSTEM TESTING SCRIPT"
echo "======================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "SUCCESS")
            echo -e "${GREEN}✅ $message${NC}"
            ;;
        "ERROR")
            echo -e "${RED}❌ $message${NC}"
            ;;
        "WARNING")
            echo -e "${YELLOW}⚠️  $message${NC}"
            ;;
        "INFO")
            echo -e "${BLUE}ℹ️  $message${NC}"
            ;;
    esac
}

echo "📋 Testing Notification System Components..."
echo ""

# 1. Check Flutter dependencies
print_status "INFO" "Checking Flutter dependencies..."
if flutter pub deps | grep -q "flutter_local_notifications"; then
    print_status "SUCCESS" "flutter_local_notifications dependency found"
else
    print_status "ERROR" "flutter_local_notifications dependency missing"
fi

if flutter pub deps | grep -q "firebase_messaging"; then
    print_status "SUCCESS" "firebase_messaging dependency found"
else
    print_status "ERROR" "firebase_messaging dependency missing"
fi

echo ""

# 2. Check iOS configuration files
print_status "INFO" "Checking iOS configuration files..."

if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
    print_status "SUCCESS" "GoogleService-Info.plist found"
else
    print_status "ERROR" "GoogleService-Info.plist missing"
fi

if [ -f "ios/Runner/Info.plist" ]; then
    if grep -q "NSUserNotificationUsageDescription" ios/Runner/Info.plist; then
        print_status "SUCCESS" "Notification permissions configured in Info.plist"
    else
        print_status "WARNING" "Notification permissions not found in Info.plist"
    fi
else
    print_status "ERROR" "Info.plist missing"
fi

if [ -f "ios/Runner/Runner.entitlements" ]; then
    if grep -q "aps-environment" ios/Runner/Runner.entitlements; then
        print_status "SUCCESS" "Push notification entitlements configured"
    else
        print_status "WARNING" "Push notification entitlements not found"
    fi
else
    print_status "ERROR" "Runner.entitlements missing"
fi

echo ""

# 3. Check Android configuration files
print_status "INFO" "Checking Android configuration files..."

if [ -f "android/app/google-services.json" ]; then
    print_status "SUCCESS" "google-services.json found"
else
    print_status "ERROR" "google-services.json missing"
fi

if [ -f "android/app/src/main/AndroidManifest.xml" ]; then
    if grep -q "permission.*INTERNET" android/app/src/main/AndroidManifest.xml; then
        print_status "SUCCESS" "Internet permission configured"
    else
        print_status "WARNING" "Internet permission not found"
    fi
else
    print_status "ERROR" "AndroidManifest.xml missing"
fi

echo ""

# 4. Check backend API endpoints (from parent directory)
print_status "INFO" "Checking backend API endpoints..."

if [ -f "../src/app/api/notifications/send/route.ts" ]; then
    print_status "SUCCESS" "Notification send endpoint found"
else
    print_status "ERROR" "Notification send endpoint missing"
fi

if [ -f "../src/app/api/notifications/send-simple/route.ts" ]; then
    print_status "SUCCESS" "Simple notification endpoint found"
else
    print_status "ERROR" "Simple notification endpoint missing"
fi

if [ -f "../src/app/api/users/device-token/route.ts" ]; then
    print_status "SUCCESS" "Device token endpoint found"
else
    print_status "ERROR" "Device token endpoint missing"
fi

echo ""

# 5. Check Prisma schema (from parent directory)
print_status "INFO" "Checking Prisma schema..."

if [ -f "../prisma/schema.prisma" ]; then
    if grep -q "model Notification" ../prisma/schema.prisma; then
        print_status "SUCCESS" "Notification model found in Prisma schema"
    else
        print_status "ERROR" "Notification model missing from Prisma schema"
    fi
    
    if grep -q "deviceToken" ../prisma/schema.prisma; then
        print_status "SUCCESS" "Device token field found in User model"
    else
        print_status "WARNING" "Device token field not found in User model"
    fi
else
    print_status "ERROR" "Prisma schema missing"
fi

echo ""

# 6. Check Flutter notification service
print_status "INFO" "Checking Flutter notification service..."

if [ -f "lib/services/notification_service.dart" ]; then
    print_status "SUCCESS" "Notification service found"
    
    if grep -q "initialize()" lib/services/notification_service.dart; then
        print_status "SUCCESS" "Notification service initialization method found"
    else
        print_status "ERROR" "Notification service initialization method missing"
    fi
    
    if grep -q "showLocalNotification" lib/services/notification_service.dart; then
        print_status "SUCCESS" "Local notification method found"
    else
        print_status "ERROR" "Local notification method missing"
    fi
    
    if grep -q "handleTripStatusChangeForUser" lib/services/notification_service.dart; then
        print_status "SUCCESS" "Trip status change handler found"
    else
        print_status "ERROR" "Trip status change handler missing"
    fi
else
    print_status "ERROR" "Notification service missing"
fi

echo ""

# 7. Check notification test screen
print_status "INFO" "Checking notification test screen..."

if [ -f "lib/screens/notification_test_screen.dart" ]; then
    print_status "SUCCESS" "Notification test screen found"
else
    print_status "WARNING" "Notification test screen missing"
fi

echo ""

# 8. Check main.dart Firebase initialization
print_status "INFO" "Checking Firebase initialization..."

if [ -f "lib/main.dart" ]; then
    if grep -q "firebase_core" lib/main.dart; then
        print_status "SUCCESS" "Firebase core initialization found"
    else
        print_status "WARNING" "Firebase core initialization not found"
    fi
    
    if grep -q "NotificationService.initialize" lib/main.dart; then
        print_status "SUCCESS" "Notification service initialization found"
    else
        print_status "WARNING" "Notification service initialization not found"
    fi
else
    print_status "ERROR" "main.dart missing"
fi

echo ""

# 9. Check documentation files (from parent directory)
print_status "INFO" "Checking documentation files..."

if [ -f "../NOTIFICATION_SYSTEM.md" ]; then
    print_status "SUCCESS" "Notification system documentation found"
else
    print_status "WARNING" "Notification system documentation missing"
fi

if [ -f "../FIREBASE_NOTIFICATION_TESTING.md" ]; then
    print_status "SUCCESS" "Firebase testing guide found"
else
    print_status "WARNING" "Firebase testing guide missing"
fi

if [ -f "../IOS_NOTIFICATION_SETUP.md" ]; then
    print_status "SUCCESS" "iOS setup guide found"
else
    print_status "WARNING" "iOS setup guide missing"
fi

echo ""

# 10. Summary
print_status "INFO" "NOTIFICATION SYSTEM TESTING SUMMARY"
echo "================================================"
echo ""
print_status "INFO" "To test the notification system:"
echo "1. Install the app on a physical device"
echo "2. Navigate to the notification test screen"
echo "3. Test local notifications"
echo "4. Test Firebase notifications"
echo "5. Test trip status notifications"
echo "6. Verify notification permissions"
echo ""
print_status "INFO" "For iOS testing:"
echo "- Ensure notification permissions are granted"
echo "- Test in foreground, background, and terminated states"
echo "- Check console logs for detailed debugging"
echo ""
print_status "INFO" "For Android testing:"
echo "- Verify Firebase configuration"
echo "- Test notification delivery"
echo "- Check notification settings"
echo ""

print_status "SUCCESS" "Notification system testing script completed!"
echo ""
print_status "INFO" "Next steps:"
echo "1. Deploy to test device"
echo "2. Run manual notification tests"
echo "3. Verify all notification scenarios work"
echo "4. Test with real trip data"
echo "5. Monitor notification delivery rates" 