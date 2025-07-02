# Province Tracking System

This document describes the province tracking system that monitors user and driver locations every 2 minutes and updates their provinces when they move to different regions.

## Overview

The province tracking system ensures that users and drivers are always associated with their current province, which is crucial for:
- Matching drivers with nearby trip requests
- Providing location-based services
- Ensuring accurate trip pricing and availability

## System Components

### 1. Flutter App (Frontend)

#### Location Service (`waddiny/lib/services/location_service.dart`)
- **Frequent Province Checking**: Runs every 2 minutes
- **Automatic Updates**: Updates province when user moves to different region
- **Local Storage**: Maintains last known province to avoid unnecessary updates
- **Error Handling**: Graceful handling of location permission and network issues

#### Key Methods:
```dart
// Start frequent province checking every 2 minutes
void startFrequentProvinceChecking()

// Stop province checking
void stopFrequentProvinceChecking()

// Check and update province if changed
Future<void> _checkAndUpdateProvince()
```

#### Integration Points:
- **User Main Screen**: Starts province checking for regular users
- **Driver Main Screen**: Starts province checking for drivers
- **Auth Service**: Updates province after login/registration

### 2. Backend API (Next.js)

#### Location Update Endpoint (`/api/flutter/users/location`)
- **POST**: Updates user location and province with coordinates
- **GET**: Retrieves user's current location data
- **Automatic Province Detection**: Determines province from coordinates
- **Database Updates**: Stores location and province in database

#### Province Detection Endpoint (`/api/flutter/location/province`)
- **GET**: Determines province from coordinates
- **POST**: Updates user province with coordinates

#### Province Update Endpoint (`/api/flutter/users/province`)
- **PATCH**: Updates user province directly

### 3. Background Service (Node.js)

#### Province Checking Script (`scripts/check-user-provinces.js`)
- **Periodic Execution**: Runs every 2 minutes
- **Batch Processing**: Checks all active users
- **Location Validation**: Only processes recent location data (< 30 minutes old)
- **Error Handling**: Continues processing even if individual users fail

#### Key Functions:
```javascript
// Check and update all user provinces
async function checkAndUpdateUserProvinces()

// Update specific user location
async function updateUserLocation(userId, lat, lng)

// Start periodic checking
function startPeriodicProvinceChecking()
```

## Province Mapping

The system uses coordinate-based province detection for Iraq and surrounding regions:

| Province | Latitude Range | Longitude Range |
|----------|----------------|-----------------|
| Baghdad | 33.0 - 34.0 | 44.0 - 45.0 |
| Erbil | 36.0 - 37.0 | 43.0 - 44.0 |
| Duhok | 36.0 - 37.0 | 42.0 - 43.0 |
| Sulaymaniyah | 35.0 - 36.0 | 45.0 - 46.0 |
| Babil | 32.0 - 33.0 | 44.0 - 45.0 |
| Karbala | 31.0 - 32.0 | 44.0 - 45.0 |
| Wasit | 32.0 - 33.0 | 45.0 - 46.0 |
| Basra | 30.0 - 31.0 | 47.0 - 48.0 |
| Aleppo | 36.0 - 37.0 | 37.0 - 38.0 |
| Damascus | 33.0 - 34.0 | 36.0 - 37.0 |

## Database Schema

### User Model Updates
```prisma
model User {
  // ... existing fields ...
  lastKnownLatitude  Float?  // Last known latitude for province tracking
  lastKnownLongitude Float?  // Last known longitude for province tracking
  lastLocationUpdate DateTime? // When the location was last updated
  // ... existing fields ...
}
```

## Usage

### Starting the System

#### 1. Flutter App
The province checking starts automatically when users open the main screens:
- User Main Screen: Starts for regular users
- Driver Main Screen: Starts for drivers

#### 2. Backend Service
Run the background service:
```bash
node scripts/check-user-provinces.js
```

#### 3. Testing
Test the province detection:
```bash
node scripts/test-province-checking.js
```

### API Endpoints

#### Update User Location
```http
POST /api/flutter/users/location
Authorization: Bearer <token>
Content-Type: application/json

{
  "lat": 33.3152,
  "lng": 44.3661
}
```

#### Get User Location
```http
GET /api/flutter/users/location
Authorization: Bearer <token>
```

#### Get Province from Coordinates
```http
GET /api/flutter/location/province?lat=33.3152&lng=44.3661
```

## Monitoring and Logging

### Console Logs
The system provides detailed logging:
- `🔄 Checking province every 2 minutes...`
- `📍 Province Check: Saved vs Current vs Last Known`
- `🔄 Province changed from X to Y`
- `✅ Province updated successfully`
- `❌ Error checking province: <error>`

### Database Logs
- Location updates are logged in the database
- Province changes are tracked with timestamps
- Failed updates are recorded for debugging

## Error Handling

### Flutter App
- **Location Permission**: Graceful handling if location access is denied
- **Network Issues**: Retry mechanism with exponential backoff
- **API Failures**: Fallback to local province detection
- **Battery Optimization**: Continues working in background

### Backend Service
- **Database Errors**: Individual user failures don't stop batch processing
- **Invalid Coordinates**: Validation and fallback to default province
- **Network Timeouts**: Configurable timeout settings
- **Service Restarts**: Automatic recovery from crashes

## Performance Considerations

### Flutter App
- **Battery Usage**: Optimized location requests (every 2 minutes)
- **Network Usage**: Minimal API calls, only when province changes
- **Memory Usage**: Efficient local storage management

### Backend Service
- **Database Load**: Batch processing to minimize database connections
- **CPU Usage**: Efficient coordinate calculations
- **Memory Usage**: Streaming processing for large user bases

## Security

### Data Protection
- **Location Privacy**: Coordinates are only used for province detection
- **Token Authentication**: All API calls require valid JWT tokens
- **Input Validation**: Coordinate validation to prevent injection attacks
- **Rate Limiting**: API endpoints are rate-limited to prevent abuse

## Troubleshooting

### Common Issues

#### 1. Province Not Updating
- Check location permissions in Flutter app
- Verify network connectivity
- Check API endpoint availability
- Review console logs for errors

#### 2. Incorrect Province Detection
- Verify coordinate ranges in province mapping
- Check if user is in a border region
- Review location accuracy settings

#### 3. High Battery Usage
- Check if location service is running too frequently
- Verify background app refresh settings
- Review location accuracy requirements

### Debug Commands

#### Test Province Detection
```bash
node scripts/test-province-checking.js
```

#### Check Database Schema
```bash
npx prisma db push
npx prisma generate
```

#### Monitor API Endpoints
```bash
curl -X POST http://localhost:3000/api/flutter/users/location \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"lat": 33.3152, "lng": 44.3661}'
```

## Future Enhancements

### Planned Features
1. **Geofencing**: More precise location boundaries
2. **Real-time Updates**: WebSocket-based location streaming
3. **Analytics Dashboard**: Province change tracking and analytics
4. **Custom Regions**: User-defined location boundaries
5. **Offline Support**: Local province detection when offline

### Performance Improvements
1. **Caching**: Redis-based location caching
2. **Batch Processing**: Optimized database operations
3. **CDN Integration**: Faster API response times
4. **Compression**: Reduced network payload sizes

## Support

For issues or questions about the province tracking system:
1. Check the console logs for error messages
2. Review this documentation
3. Test with the provided test scripts
4. Contact the development team with specific error details 