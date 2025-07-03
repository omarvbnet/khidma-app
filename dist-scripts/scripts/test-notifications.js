"use strict";
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
Object.defineProperty(exports, "__esModule", { value: true });
var client_1 = require("@prisma/client");
var firebase_admin_1 = require("../src/lib/firebase-admin");
var prisma = new client_1.PrismaClient();
function testNotifications() {
    return __awaiter(this, void 0, void 0, function () {
        var usersWithTokens, _i, usersWithTokens_1, user, result, error_1, cleanupError_1, remainingUsers, _a, remainingUsers_1, user, error_2;
        var _b;
        return __generator(this, function (_c) {
            switch (_c.label) {
                case 0:
                    console.log('🧪 Testing notification system...');
                    _c.label = 1;
                case 1:
                    _c.trys.push([1, 14, 15, 17]);
                    return [4 /*yield*/, prisma.user.findMany({
                            where: {
                                deviceToken: {
                                    not: null
                                }
                            },
                            select: {
                                id: true,
                                fullName: true,
                                phoneNumber: true,
                                deviceToken: true,
                                platform: true,
                                role: true,
                                status: true
                            }
                        })];
                case 2:
                    usersWithTokens = _c.sent();
                    console.log("\uD83D\uDCCA Found ".concat(usersWithTokens.length, " users with device tokens"));
                    _i = 0, usersWithTokens_1 = usersWithTokens;
                    _c.label = 3;
                case 3:
                    if (!(_i < usersWithTokens_1.length)) return [3 /*break*/, 12];
                    user = usersWithTokens_1[_i];
                    console.log("\n\uD83E\uDDEA Testing notification for ".concat(user.fullName, " (").concat(user.phoneNumber, ")"));
                    console.log("   Role: ".concat(user.role, ", Platform: ").concat(user.platform, ", Status: ").concat(user.status));
                    console.log("   Token: ".concat((_b = user.deviceToken) === null || _b === void 0 ? void 0 : _b.substring(0, 30), "..."));
                    _c.label = 4;
                case 4:
                    _c.trys.push([4, 6, , 11]);
                    return [4 /*yield*/, (0, firebase_admin_1.sendPushNotification)({
                            token: user.deviceToken,
                            title: 'Test Notification',
                            body: 'This is a test notification to verify your device token is working.',
                            data: {
                                type: 'TEST',
                                userId: user.id,
                                timestamp: new Date().toISOString()
                            }
                        })];
                case 5:
                    result = _c.sent();
                    console.log("   \u2705 SUCCESS: Notification sent successfully");
                    console.log("   \uD83D\uDCF1 Response:", result);
                    return [3 /*break*/, 11];
                case 6:
                    error_1 = _c.sent();
                    console.log("   \u274C FAILED: ".concat(error_1.message));
                    if (!(error_1.message.includes('Requested entity was not found') ||
                        error_1.message.includes('Invalid registration token') ||
                        error_1.message.includes('Registration token is not valid') ||
                        error_1.message.includes('Device token not found'))) return [3 /*break*/, 10];
                    console.log("   \uD83E\uDDF9 This appears to be an invalid token - should be cleaned up");
                    _c.label = 7;
                case 7:
                    _c.trys.push([7, 9, , 10]);
                    return [4 /*yield*/, prisma.user.update({
                            where: { id: user.id },
                            data: { deviceToken: null }
                        })];
                case 8:
                    _c.sent();
                    console.log("   \u2705 Invalid token cleaned up for ".concat(user.fullName));
                    return [3 /*break*/, 10];
                case 9:
                    cleanupError_1 = _c.sent();
                    console.log("   \u274C Failed to clean up token: ".concat(cleanupError_1.message));
                    return [3 /*break*/, 10];
                case 10: return [3 /*break*/, 11];
                case 11:
                    _i++;
                    return [3 /*break*/, 3];
                case 12: return [4 /*yield*/, prisma.user.findMany({
                        where: {
                            deviceToken: {
                                not: null
                            }
                        },
                        select: {
                            id: true,
                            fullName: true,
                            phoneNumber: true,
                            role: true
                        }
                    })];
                case 13:
                    remainingUsers = _c.sent();
                    console.log("\n\uD83D\uDCCA Final Summary: ".concat(remainingUsers.length, " users still have valid device tokens"));
                    for (_a = 0, remainingUsers_1 = remainingUsers; _a < remainingUsers_1.length; _a++) {
                        user = remainingUsers_1[_a];
                        console.log("   - ".concat(user.fullName, " (").concat(user.phoneNumber, ") - ").concat(user.role));
                    }
                    return [3 /*break*/, 17];
                case 14:
                    error_2 = _c.sent();
                    console.error('❌ Error during notification testing:', error_2);
                    return [3 /*break*/, 17];
                case 15: return [4 /*yield*/, prisma.$disconnect()];
                case 16:
                    _c.sent();
                    return [7 /*endfinally*/];
                case 17: return [2 /*return*/];
            }
        });
    });
}
// Run the test
testNotifications()
    .then(function () {
    console.log('✅ Notification testing completed');
    process.exit(0);
})
    .catch(function (error) {
    console.error('❌ Notification testing failed:', error);
    process.exit(1);
});
