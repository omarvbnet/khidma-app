"use strict";
var __assign = (this && this.__assign) || function () {
    __assign = Object.assign || function(t) {
        for (var s, i = 1, n = arguments.length; i < n; i++) {
            s = arguments[i];
            for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p))
                t[p] = s[p];
        }
        return t;
    };
    return __assign.apply(this, arguments);
};
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g = Object.create((typeof Iterator === "function" ? Iterator : Object).prototype);
    return g.next = verb(0), g["throw"] = verb(1), g["return"] = verb(2), typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (g && (g = 0, op[0] && (_ = 0)), _) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
var _a;
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendPushNotification = sendPushNotification;
exports.sendMulticastNotification = sendMulticastNotification;
var app_1 = require("firebase-admin/app");
var messaging_1 = require("firebase-admin/messaging");
// Initialize Firebase Admin SDK only if environment variables are present
var messaging = null;
if (process.env.FIREBASE_PROJECT_ID && process.env.FIREBASE_CLIENT_EMAIL && process.env.FIREBASE_PRIVATE_KEY) {
    if (!(0, app_1.getApps)().length) {
        (0, app_1.initializeApp)({
            credential: (0, app_1.cert)({
                projectId: process.env.FIREBASE_PROJECT_ID,
                clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
                privateKey: (_a = process.env.FIREBASE_PRIVATE_KEY) === null || _a === void 0 ? void 0 : _a.replace(/\\n/g, '\n'),
            }),
        });
    }
    messaging = (0, messaging_1.getMessaging)();
}
else {
    console.warn('⚠️ Firebase Admin SDK not initialized - missing environment variables');
}
// Helper function to validate device token format
function isValidDeviceToken(token) {
    if (!token || typeof token !== 'string') {
        return false;
    }
    // Basic validation for FCM token format
    // FCM tokens are typically 140+ characters and contain alphanumeric characters and some special chars
    if (token.length < 100) {
        return false;
    }
    // Check if token contains only valid characters
    var validTokenRegex = /^[A-Za-z0-9:_-]+$/;
    return validTokenRegex.test(token);
}
// Helper function to convert all data values to strings (FCM requirement)
function convertDataToStrings(data) {
    var stringData = {};
    for (var _i = 0, _a = Object.entries(data); _i < _a.length; _i++) {
        var _b = _a[_i], key = _b[0], value = _b[1];
        if (value === null || value === undefined) {
            stringData[key] = '';
        }
        else if (typeof value === 'object') {
            stringData[key] = JSON.stringify(value);
        }
        else {
            stringData[key] = String(value);
        }
    }
    return stringData;
}
// Send push notification
function sendPushNotification(_a) {
    return __awaiter(this, arguments, void 0, function (_b) {
        var stringData, notificationMessage, dataOnlyMessage, _c, notificationResponse, dataResponse, error_1;
        var token = _b.token, title = _b.title, body = _b.body, _d = _b.data, data = _d === void 0 ? {} : _d;
        return __generator(this, function (_e) {
            switch (_e.label) {
                case 0:
                    if (!messaging) {
                        console.warn('⚠️ Firebase Admin SDK not available - skipping push notification');
                        return [2 /*return*/, null];
                    }
                    // Validate device token
                    if (!isValidDeviceToken(token)) {
                        console.error('❌ Invalid device token format:', {
                            token: token ? "".concat(token.substring(0, 20), "...") : 'null',
                            length: (token === null || token === void 0 ? void 0 : token.length) || 0,
                        });
                        throw new Error('Invalid device token format');
                    }
                    _e.label = 1;
                case 1:
                    _e.trys.push([1, 3, , 4]);
                    stringData = convertDataToStrings(data);
                    console.log('📱 Converting notification data to strings:', {
                        originalData: data,
                        stringData: stringData,
                        token: "".concat(token.substring(0, 20), "..."),
                    });
                    notificationMessage = {
                        token: token,
                        notification: {
                            title: title,
                            body: body,
                        },
                        data: __assign(__assign({}, stringData), { click_action: 'FLUTTER_NOTIFICATION_CLICK', sound: 'default', title: title, body: body }),
                        android: {
                            priority: 'high',
                            notification: {
                                channelId: 'trip_notifications',
                                priority: 'high',
                                defaultSound: true,
                                defaultVibrateTimings: true,
                                icon: '@mipmap/ic_launcher',
                                color: '#2196F3',
                                sound: 'notification_sound',
                                vibrateTimingsMillis: [0, 500, 200, 500],
                                lightSettings: {
                                    color: '#2196F3',
                                    lightOnDurationMillis: 1000,
                                    lightOffDurationMillis: 500,
                                },
                            },
                        },
                        apns: {
                            payload: {
                                aps: {
                                    alert: {
                                        title: title,
                                        body: body,
                                    },
                                    sound: 'default',
                                    badge: 1,
                                    'content-available': 1,
                                    'mutable-content': 1,
                                    category: 'trip_notifications',
                                    'thread-id': 'trip_notifications',
                                },
                            },
                            headers: {
                                'apns-priority': '10',
                                'apns-push-type': 'alert',
                            },
                        },
                    };
                    dataOnlyMessage = {
                        token: token,
                        data: __assign(__assign({}, stringData), { title: title, body: body, click_action: 'FLUTTER_NOTIFICATION_CLICK', sound: 'default', type: stringData.type || 'NEW_TRIP_AVAILABLE', timestamp: new Date().toISOString() }),
                        android: {
                            priority: 'high',
                            data: __assign(__assign({}, stringData), { title: title, body: body, click_action: 'FLUTTER_NOTIFICATION_CLICK', sound: 'default', type: stringData.type || 'NEW_TRIP_AVAILABLE', timestamp: new Date().toISOString() }),
                        },
                        apns: {
                            payload: {
                                aps: {
                                    'content-available': 1,
                                    'mutable-content': 1,
                                    category: 'trip_notifications',
                                    'thread-id': 'trip_notifications',
                                },
                                data: __assign(__assign({}, stringData), { title: title, body: body, type: stringData.type || 'NEW_TRIP_AVAILABLE', timestamp: new Date().toISOString() }),
                            },
                            headers: {
                                'apns-priority': '5', // Lower priority for data-only messages
                                'apns-push-type': 'background',
                            },
                        },
                    };
                    return [4 /*yield*/, Promise.all([
                            messaging.send(notificationMessage),
                            messaging.send(dataOnlyMessage),
                        ])];
                case 2:
                    _c = _e.sent(), notificationResponse = _c[0], dataResponse = _c[1];
                    console.log('✅ Push notifications sent successfully:', {
                        notificationResponse: notificationResponse,
                        dataResponse: dataResponse,
                    });
                    return [2 /*return*/, { notificationResponse: notificationResponse, dataResponse: dataResponse }];
                case 3:
                    error_1 = _e.sent();
                    console.error('❌ Error sending push notification:', error_1);
                    // Handle specific Firebase errors
                    if (error_1 instanceof Error) {
                        if (error_1.message.includes('Requested entity was not found')) {
                            console.error('🔍 Device token not found - token may be invalid or expired:', {
                                token: "".concat(token.substring(0, 20), "..."),
                                error: error_1.message,
                            });
                            throw new Error('Device token not found - token may be invalid or expired');
                        }
                        else if (error_1.message.includes('Invalid registration token')) {
                            console.error('🔍 Invalid registration token:', {
                                token: "".concat(token.substring(0, 20), "..."),
                                error: error_1.message,
                            });
                            throw new Error('Invalid registration token');
                        }
                        else if (error_1.message.includes('Registration token is not valid')) {
                            console.error('🔍 Registration token is not valid:', {
                                token: "".concat(token.substring(0, 20), "..."),
                                error: error_1.message,
                            });
                            throw new Error('Registration token is not valid');
                        }
                    }
                    throw error_1;
                case 4: return [2 /*return*/];
            }
        });
    });
}
// Send notification to multiple devices
function sendMulticastNotification(_a) {
    return __awaiter(this, arguments, void 0, function (_b) {
        var validTokens, invalidTokens, stringData, notificationMessage, dataOnlyMessage, _c, notificationResponse, dataResponse, error_2;
        var tokens = _b.tokens, title = _b.title, body = _b.body, _d = _b.data, data = _d === void 0 ? {} : _d;
        return __generator(this, function (_e) {
            switch (_e.label) {
                case 0:
                    if (!messaging) {
                        console.warn('⚠️ Firebase Admin SDK not available - skipping multicast notification');
                        return [2 /*return*/, null];
                    }
                    validTokens = tokens.filter(function (token) { return isValidDeviceToken(token); });
                    invalidTokens = tokens.filter(function (token) { return !isValidDeviceToken(token); });
                    if (invalidTokens.length > 0) {
                        console.warn('⚠️ Filtered out invalid device tokens:', {
                            totalTokens: tokens.length,
                            validTokens: validTokens.length,
                            invalidTokens: invalidTokens.length,
                            invalidTokenExamples: invalidTokens.slice(0, 3).map(function (t) { return "".concat(t.substring(0, 20), "..."); }),
                        });
                    }
                    if (validTokens.length === 0) {
                        console.warn('⚠️ No valid device tokens found for multicast notification');
                        return [2 /*return*/, null];
                    }
                    _e.label = 1;
                case 1:
                    _e.trys.push([1, 3, , 4]);
                    stringData = convertDataToStrings(data);
                    console.log('📱 Converting multicast notification data to strings:', {
                        originalData: data,
                        stringData: stringData,
                        validTokensCount: validTokens.length,
                    });
                    notificationMessage = {
                        notification: {
                            title: title,
                            body: body,
                        },
                        data: __assign(__assign({}, stringData), { click_action: 'FLUTTER_NOTIFICATION_CLICK', sound: 'default', title: title, body: body }),
                        android: {
                            priority: 'high',
                            notification: {
                                channelId: 'trip_notifications',
                                priority: 'high',
                                defaultSound: true,
                                defaultVibrateTimings: true,
                                icon: '@mipmap/ic_launcher',
                                color: '#2196F3',
                                sound: 'notification_sound',
                                vibrateTimingsMillis: [0, 500, 200, 500],
                                lightSettings: {
                                    color: '#2196F3',
                                    lightOnDurationMillis: 1000,
                                    lightOffDurationMillis: 500,
                                },
                            },
                        },
                        apns: {
                            payload: {
                                aps: {
                                    alert: {
                                        title: title,
                                        body: body,
                                    },
                                    sound: 'default',
                                    badge: 1,
                                    'content-available': 1,
                                    'mutable-content': 1,
                                    category: 'trip_notifications',
                                    'thread-id': 'trip_notifications',
                                },
                            },
                            headers: {
                                'apns-priority': '10', // must be 10 for alert
                                'apns-push-type': 'alert', // must be alert for notification
                            },
                        },
                    };
                    dataOnlyMessage = {
                        data: __assign(__assign({}, stringData), { title: title, body: body, click_action: 'FLUTTER_NOTIFICATION_CLICK', sound: 'default', type: stringData.type || 'NEW_TRIP_AVAILABLE', timestamp: new Date().toISOString() }),
                        android: {
                            priority: 'high',
                            data: __assign(__assign({}, stringData), { title: title, body: body, click_action: 'FLUTTER_NOTIFICATION_CLICK', sound: 'default', type: stringData.type || 'NEW_TRIP_AVAILABLE', timestamp: new Date().toISOString() }),
                        },
                        apns: {
                            payload: {
                                aps: {
                                    'content-available': 1,
                                    'mutable-content': 1,
                                    category: 'trip_notifications',
                                    'thread-id': 'trip_notifications',
                                },
                                data: __assign(__assign({}, stringData), { title: title, body: body, type: stringData.type || 'NEW_TRIP_AVAILABLE', timestamp: new Date().toISOString() }),
                            },
                            headers: {
                                'apns-priority': '5', // Lower priority for data-only messages
                                'apns-push-type': 'background',
                            },
                        },
                    };
                    return [4 /*yield*/, Promise.all([
                            messaging.sendEachForMulticast(__assign(__assign({}, notificationMessage), { tokens: validTokens })),
                            messaging.sendEachForMulticast(__assign(__assign({}, dataOnlyMessage), { tokens: validTokens })),
                        ])];
                case 2:
                    _c = _e.sent(), notificationResponse = _c[0], dataResponse = _c[1];
                    console.log('✅ Multicast notifications sent:', {
                        notificationResponse: {
                            successCount: notificationResponse.successCount,
                            failureCount: notificationResponse.failureCount,
                            responses: notificationResponse.responses,
                        },
                        dataResponse: {
                            successCount: dataResponse.successCount,
                            failureCount: dataResponse.failureCount,
                            responses: dataResponse.responses,
                        },
                    });
                    return [2 /*return*/, { notificationResponse: notificationResponse, dataResponse: dataResponse }];
                case 3:
                    error_2 = _e.sent();
                    console.error('❌ Error sending multicast notification:', error_2);
                    throw error_2;
                case 4: return [2 /*return*/];
            }
        });
    });
}
