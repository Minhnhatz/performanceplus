#import <Foundation/Foundation.h>

@interface PPManager : NSObject

+ (instancetype)sharedManager;

- (void)registerDefaultPreferences;

- (BOOL)isEnabled;
- (void)setEnabled:(BOOL)enabled;
- (BOOL)isOptionEnabled:(NSString *)option;
- (void)setOption:(NSString *)option enabled:(BOOL)enabled;

- (BOOL)boolForKey:(NSString *)key defaultValue:(BOOL)defaultValue;
- (void)setBool:(BOOL)enabled forKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key defaultValue:(NSString *)defaultValue;
- (void)setString:(NSString *)value forKey:(NSString *)key;

- (NSArray<NSString *> *)refreshRateOptions;
- (NSArray<NSString *> *)fpsOptions;
- (NSString *)unsupportedMessage;
- (NSString *)experimentalMessage;
- (NSString *)limitedByIOSMessage;
- (NSString *)deviceModel;
- (NSString *)deviceCapabilityStatus;
- (NSString *)displayRefreshRateStatus;
- (NSString *)displayCaptureStatus;
- (NSString *)systemVersion;
- (NSString *)cpuStatus;
- (NSString *)cpuUsageStatus;
- (NSString *)memoryStatus;
- (NSInteger)batteryLevelPercentage;
- (NSInteger)chargingReminderThreshold;
- (BOOL)isBatteryCharging;
- (NSString *)batteryStatus;
- (NSString *)thermalStatus;
- (BOOL)isThermalStateSeriousOrCritical;
- (NSString *)powerStatus;
- (NSString *)uptimeStatus;

@end
