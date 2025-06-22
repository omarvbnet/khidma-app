#!/bin/bash

# Script to update Flutter app .env file with proper Firebase configuration

echo "🔧 Updating Flutter app .env file..."

# Create backup of existing .env file
if [ -f "waddiny/.env" ]; then
    cp waddiny/.env waddiny/.env.backup
    echo "✅ Created backup of existing .env file"
fi

# Create new .env file with proper configuration
cat > waddiny/.env << 'EOF'
# Firebase Configuration
FIREBASE_PROJECT_ID=wadiny-13e7a
FIREBASE_APP_ID=1:690659070480:android:9aa7cac5048f8a7d5cb095
FIREBASE_API_KEY=AIzaSyCOlYe3ui-PCKtO_YsmYrOUuIlWDQYaLHk

# API Configuration
API_BASE_URL=https://khidma-app1.vercel.app/api/flutter
API_KEY=your_api_key_here

# Google Maps
GOOGLE_MAPS_API_KEY=AIzaSyCOlYe3ui-PCKtO_YsmYrOUuIlWDQYaLHk
EOF

echo "✅ Updated .env file with proper Firebase configuration"
echo ""
echo "📋 Next steps:"
echo "1. Regenerate GoogleService-Info.plist from Firebase Console"
echo "2. Replace the file in ios/Runner/GoogleService-Info.plist"
echo "3. Test notifications using the notification test screen"
echo ""
echo "🔍 To test notifications:"
echo "- Open the Flutter app"
echo "- Navigate to notification test screen"
echo "- Test local notifications first"
echo "- Then test Firebase notifications"
echo "- Finally test driver notifications" 