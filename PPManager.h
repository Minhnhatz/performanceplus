#import <Foundation/Foundation.h>

@interface PPManager : NSObject

+ (instancetype)sharedManager;

- (void)start;

- (BOOL)isEnabled;
- (void)setEnabled:(BOOL)enabled;
- (BOOL)isOptionEnabled:(NSString *)option;
- (void)setOption:(NSString *)option enabled:(BOOL)enabled;

- (NSString *)deviceModel;
- (NSString *)systemVersion;
- (NSString *)cpuStatus;
- (NSString *)memoryStatus;
- (NSString *)batteryStatus;
- (NSString *)thermalStatus;
- (NSString *)powerStatus;
- (NSString *)uptimeStatus;
- (NSString *)loadedTweakStatus;
- (NSString *)possibleConflictStatus;
- (NSString *)installedTweakCountStatus;
- (NSString *)diagnosticsSummary;

@end
