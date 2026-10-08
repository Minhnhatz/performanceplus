#import "PPManager.h"
#import <UIKit/UIKit.h>
#import <sys/sysctl.h>
#import <mach/mach.h>
#import <math.h>

static NSString * const kPPDomain = @"com.blue.performanceplus";
static NSString * const kPPEnabledKey = @"enabled";
static NSString * const kPPPerformanceModeKey = @"performanceMode";
static NSString * const kPPMemoryOptimizationKey = @"memoryOptimization";
static NSString * const kPPAppLaunchOptimizationKey = @"appLaunchOptimization";

static NSArray<NSString *> *PPDefaultFeatureKeys(void) {
    static NSArray<NSString *> *keys;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keys = @[
            @"enabled",
            @"performanceMode",
            @"memoryOptimization",
            @"appLaunchOptimization",
            @"PPRefreshRate",
            @"PPFPSLimit",
            @"PPTouchOptimization",
            @"PPTouchResponse",
            @"PPGestureResponsiveness",
            @"PPStabilityMode",
            @"PPAntiGlitch",
            @"PPStutterReduction",
            @"PPSwipeProtection",
            @"PPKeyboardOptimization",
            @"PPControlCenterOptimization",
            @"PPAppCompatibility",
            @"PPRAMOptimization",
            @"PPCPUOptimization",
            @"PPGPUOptimization",
            @"PPRecordingOptimization",
            @"PPChargingOptimization",
            @"PPChargingReminderEnabled",
            @"PPBatteryOptimization",
            @"PPGamingMode",
            @"PPAutoProfile",
            @"PPThermalManagement",
            @"PPThermalProfile",
            @"PPBackgroundActivity",
            @"PPBackgroundMode",
            @"PPSafeMode",
            @"PPAutomaticStatusUpdates"
        ];
    });
    return keys;
}

static NSUserDefaults *PPPreferences(void) {
    return [[NSUserDefaults alloc] initWithSuiteName:kPPDomain];
}

static NSString *PPHardwareIdentifier(void) {
    char machine[256] = {0};
    size_t size = sizeof(machine);
    if (sysctlbyname("hw.machine", machine, &size, NULL, 0) != 0) {
        return @"";
    }

    machine[sizeof(machine) - 1] = '\0';
    return [NSString stringWithUTF8String:machine] ?: @"";
}

static NSDictionary<NSString *, id> *PPDefaultPreferences(void) {
    static NSDictionary *defaults;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaults = @{
            kPPEnabledKey: @YES,
            kPPPerformanceModeKey: @NO,
            kPPMemoryOptimizationKey: @NO,
            kPPAppLaunchOptimizationKey: @NO,
            @"PPRefreshRate": @"Auto",
            @"PPFPSLimit": @"Auto",
            @"PPTouchOptimization": @YES,
            @"PPTouchResponse": @YES,
            @"PPGestureResponsiveness": @YES,
            @"PPStabilityMode": @YES,
            @"PPAntiGlitch": @YES,
            @"PPStutterReduction": @YES,
            @"PPSwipeProtection": @YES,
            @"PPKeyboardOptimization": @YES,
            @"PPControlCenterOptimization": @YES,
            @"PPAppCompatibility": @YES,
            @"PPRAMOptimization": @NO,
            @"PPCPUOptimization": @NO,
            @"PPGPUOptimization": @NO,
            @"PPRecordingOptimization": @YES,
            @"PPChargingOptimization": @YES,
            @"PPChargingReminderEnabled": @YES,
            @"PPBatteryOptimization": @YES,
            @"PPGamingMode": @NO,
            @"PPAutoProfile": @"Auto",
            @"PPThermalManagement": @YES,
            @"PPThermalProfile": @"Auto",
            @"PPBackgroundActivity": @YES,
            @"PPBackgroundMode": @"Auto",
            @"PPSafeMode": @NO,
            @"PPAutomaticStatusUpdates": @YES
        };
    });
    return defaults;
}

static NSSet<NSString *> *PPOptionKeys(void) {
    static NSSet<NSString *> *keys;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keys = [NSSet setWithArray:PPDefaultFeatureKeys()];
    });
    return keys;
}

@implementation PPManager

+ (instancetype)sharedManager {
    static PPManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self registerDefaultPreferences];
    }
    return self;
}

- (void)registerDefaultPreferences {
    NSUserDefaults *defaults = PPPreferences();
    if (!defaults) {
        return;
    }
    [defaults registerDefaults:PPDefaultPreferences()];
}

- (BOOL)isEnabled {
    NSUserDefaults *defaults = PPPreferences();
    if (!defaults) {
        return YES;
    }
    NSNumber *value = [defaults objectForKey:kPPEnabledKey];
    return [value isKindOfClass:NSNumber.class] ? value.boolValue : YES;
}

- (void)setEnabled:(BOOL)enabled {
    NSUserDefaults *defaults = PPPreferences();
    if (!defaults) {
        return;
    }
    [defaults setBool:enabled forKey:kPPEnabledKey];
}

- (BOOL)boolForKey:(NSString *)key defaultValue:(BOOL)defaultValue {
    if (![key isKindOfClass:NSString.class] || ![PPOptionKeys() containsObject:key]) {
        return defaultValue;
    }
    NSUserDefaults *defaults = PPPreferences();
    if (!defaults) {
        return defaultValue;
    }
    NSNumber *value = [defaults objectForKey:key];
    return [value isKindOfClass:NSNumber.class] ? value.boolValue : defaultValue;
}

- (void)setBool:(BOOL)enabled forKey:(NSString *)key {
    if (![key isKindOfClass:NSString.class] || ![PPOptionKeys() containsObject:key]) {
        return;
    }
    NSUserDefaults *defaults = PPPreferences();
    if (!defaults) {
        return;
    }
    [defaults setBool:enabled forKey:key];
}

- (NSString *)stringForKey:(NSString *)key defaultValue:(NSString *)defaultValue {
    if (![key isKindOfClass:NSString.class] || ![PPOptionKeys() containsObject:key]) {
        return defaultValue ?: @"Auto";
    }
    NSUserDefaults *defaults = PPPreferences();
    if (!defaults) {
        return defaultValue ?: @"Auto";
    }
    NSString *value = [defaults stringForKey:key];
    return [value isKindOfClass:NSString.class] && value.length > 0 ? value : (defaultValue ?: @"Auto");
}

- (void)setString:(NSString *)value forKey:(NSString *)key {
    if (![key isKindOfClass:NSString.class] || ![PPOptionKeys() containsObject:key]) {
        return;
    }
    NSUserDefaults *defaults = PPPreferences();
    if (!defaults) {
        return;
    }
    if ([value isKindOfClass:NSString.class]) {
        [defaults setObject:value forKey:key];
    }
}

- (BOOL)isOptionEnabled:(NSString *)option {
    if (![option isKindOfClass:NSString.class] || ![PPOptionKeys() containsObject:option]) {
        return NO;
    }
    return [self boolForKey:option defaultValue:NO];
}

- (void)setOption:(NSString *)option enabled:(BOOL)enabled {
    if (![option isKindOfClass:NSString.class] || ![PPOptionKeys() containsObject:option]) {
        return;
    }
    [self setBool:enabled forKey:option];
}

- (NSArray<NSString *> *)refreshRateOptions {
    NSInteger maxFps = (NSInteger)UIScreen.mainScreen.maximumFramesPerSecond;
    if (maxFps <= 0) {
        return @[@"Auto", @"60 Hz"];
    }

    NSMutableArray<NSString *> *rates = [NSMutableArray arrayWithObject:@"Auto"];
    if (maxFps >= 120) {
        [rates addObjectsFromArray:@[@"60 Hz", @"90 Hz", @"120 Hz"]];
    } else if (maxFps >= 90) {
        [rates addObjectsFromArray:@[@"60 Hz", @"90 Hz"]];
    } else {
        [rates addObject:@"60 Hz"];
    }
    return rates;
}

- (NSArray<NSString *> *)fpsOptions {
    NSInteger maxFps = (NSInteger)UIScreen.mainScreen.maximumFramesPerSecond;
    NSMutableArray<NSString *> *fps = [NSMutableArray arrayWithObject:@"Auto"];
    if (maxFps >= 120) {
        [fps addObjectsFromArray:@[@"30 FPS", @"60 FPS", @"90 FPS", @"120 FPS"]];
    } else if (maxFps >= 90) {
        [fps addObjectsFromArray:@[@"30 FPS", @"60 FPS", @"90 FPS"]];
    } else if (maxFps >= 60) {
        [fps addObjectsFromArray:@[@"30 FPS", @"60 FPS"]];
    } else {
        [fps addObject:@"30 FPS"];
    }
    return fps;
}

- (NSString *)unsupportedMessage {
    return @"Not supported on this device/iOS version.";
}

- (NSString *)experimentalMessage {
    return @"Experimental feature. Results may vary.";
}

- (NSString *)limitedByIOSMessage {
    return @"Limited by iOS.";
}

- (NSString *)deviceModel {
    NSString *identifier = PPHardwareIdentifier();
    NSString *model = UIDevice.currentDevice.model ?: @"Unknown";
    return identifier.length > 0
        ? [NSString stringWithFormat:@"%@ (%@)", model, identifier]
        : model;
}

- (NSString *)deviceCapabilityStatus {
    NSString *model = UIDevice.currentDevice.model ?: @"";
    NSString *identifier = PPHardwareIdentifier();
    NSString *generationString = [[identifier componentsSeparatedByString:@","].firstObject
                                  stringByReplacingOccurrencesOfString:@"iPhone"
                                  withString:@""];
    NSInteger generation = generationString.integerValue;

    if ([model rangeOfString:@"iPhone" options:NSCaseInsensitiveSearch].location == NSNotFound ||
        ![identifier hasPrefix:@"iPhone"] ||
        generation < 8) {
        return [NSString stringWithFormat:@"%@ Device information is available; iPhone 6s+ support cannot be confirmed.",
                self.unsupportedMessage];
    }

    return [NSString stringWithFormat:@"Compatible (iPhone 6s or later, %@)", identifier];
}

- (NSString *)displayRefreshRateStatus {
    NSInteger maximumFramesPerSecond = (NSInteger)UIScreen.mainScreen.maximumFramesPerSecond;
    if (maximumFramesPerSecond <= 0) {
        return self.unsupportedMessage;
    }

    return [NSString stringWithFormat:@"Up to %ld Hz (read-only; controlled by iOS)",
            (long)maximumFramesPerSecond];
}

- (NSString *)displayCaptureStatus {
    if (@available(iOS 11.0, *)) {
        return UIScreen.mainScreen.isCaptured
            ? @"Display is being captured or mirrored"
            : @"No display capture or mirroring detected";
    }
    return self.unsupportedMessage;
}

- (NSString *)systemVersion {
    return UIDevice.currentDevice.systemVersion ?: @"Unknown";
}

- (NSString *)cpuStatus {
    NSUInteger processorCount = NSProcessInfo.processInfo.processorCount;
    return processorCount > 0
        ? [NSString stringWithFormat:@"%lu logical cores",
           (unsigned long)processorCount]
        : @"Unavailable";
}

- (NSString *)cpuUsageStatus {
    mach_port_t host = mach_host_self();
    if (host == MACH_PORT_NULL) {
        return @"Unavailable";
    }

    host_cpu_load_info_data_t loadInfo = {0};
    mach_msg_type_number_t count = HOST_CPU_LOAD_INFO_COUNT;
    kern_return_t result = host_statistics(host,
                                           HOST_CPU_LOAD_INFO,
                                           (host_info_t)&loadInfo,
                                           &count);
    mach_port_deallocate(mach_task_self(), host);
    if (result != KERN_SUCCESS || count < HOST_CPU_LOAD_INFO_COUNT) {
        return @"Unavailable";
    }

    uint64_t activeTicks = (uint64_t)loadInfo.cpu_ticks[CPU_STATE_USER] +
                           loadInfo.cpu_ticks[CPU_STATE_SYSTEM] +
                           loadInfo.cpu_ticks[CPU_STATE_NICE];
    uint64_t totalTicks = activeTicks + loadInfo.cpu_ticks[CPU_STATE_IDLE];

    static BOOL hasPreviousSample = NO;
    static uint64_t previousActiveTicks = 0;
    static uint64_t previousTotalTicks = 0;
    @synchronized (self) {
        if (!hasPreviousSample) {
            hasPreviousSample = YES;
            previousActiveTicks = activeTicks;
            previousTotalTicks = totalTicks;
            return @"Sampling — refresh again for CPU usage";
        }

        uint64_t activeDelta = activeTicks - previousActiveTicks;
        uint64_t totalDelta = totalTicks - previousTotalTicks;
        previousActiveTicks = activeTicks;
        previousTotalTicks = totalTicks;
        if (totalDelta == 0) {
            return @"Sampling — refresh again shortly";
        }

        double usage = 100.0 * (double)activeDelta / (double)totalDelta;
        usage = fmin(100.0, fmax(0.0, usage));
        return [NSString stringWithFormat:@"%.0f%% (device-wide)", usage];
    }
}

- (NSString *)memoryStatus {
    mach_msg_type_number_t count = HOST_VM_INFO64_COUNT;
    vm_statistics64_data_t vmStats = {0};
    mach_port_t host = mach_host_self();
    if (host == MACH_PORT_NULL) {
        return @"Unavailable";
    }

    kern_return_t statisticsResult = host_statistics64(host,
                           HOST_VM_INFO64,
                           (host_info64_t)&vmStats,
                           &count);
    vm_size_t pageSize = 0;
    kern_return_t pageSizeResult = host_page_size(host, &pageSize);
    mach_port_deallocate(mach_task_self(), host);

    if (statisticsResult != KERN_SUCCESS ||
        pageSizeResult != KERN_SUCCESS ||
        pageSize == 0) {
        return @"Unavailable";
    }

    unsigned long long freeMemory =
        (unsigned long long)vmStats.free_count * pageSize;
    unsigned long long active =
        (unsigned long long)vmStats.active_count * pageSize;
    unsigned long long inactive =
        (unsigned long long)vmStats.inactive_count * pageSize;
    unsigned long long wired =
        (unsigned long long)vmStats.wire_count * pageSize;
    unsigned long long used = active + inactive + wired;

    double usedMB = (double)used / 1024.0 / 1024.0;
    double freeMB = (double)freeMemory / 1024.0 / 1024.0;
    double totalMB =
        (double)NSProcessInfo.processInfo.physicalMemory / 1024.0 / 1024.0;

    return [NSString stringWithFormat:
            @"Used %.0f MB • Free %.0f MB • Total %.0f MB",
            usedMB, freeMB, totalMB];
}

- (NSString *)batteryStatus {
    UIDevice *device = UIDevice.currentDevice;
    device.batteryMonitoringEnabled = YES;
    NSInteger percentage = [self batteryLevelPercentage];
    UIDeviceBatteryState state = device.batteryState;

    if (percentage < 0) {
        return @"Unavailable";
    }

    NSString *stateDescription = @"Unknown state";
    switch (state) {
        case UIDeviceBatteryStateUnplugged:
            stateDescription = @"On battery";
            break;
        case UIDeviceBatteryStateCharging:
            stateDescription = @"Charging";
            break;
        case UIDeviceBatteryStateFull:
            stateDescription = @"Fully charged";
            break;
        case UIDeviceBatteryStateUnknown:
            break;
    }

    return [NSString stringWithFormat:@"%ld%% • %@",
            (long)percentage, stateDescription];
}

- (NSInteger)batteryLevelPercentage {
    UIDevice *device = UIDevice.currentDevice;
    device.batteryMonitoringEnabled = YES;
    float level = device.batteryLevel;
    if (!isfinite(level) || level < 0.0f || level > 1.0f) {
        return -1;
    }
    return (NSInteger)lroundf(level * 100.0f);
}

- (BOOL)isBatteryCharging {
    UIDevice *device = UIDevice.currentDevice;
    device.batteryMonitoringEnabled = YES;
    return device.batteryState == UIDeviceBatteryStateCharging;
}

- (NSString *)thermalStatus {
    if (@available(iOS 11.0, *)) {
        NSProcessInfoThermalState state = NSProcessInfo.processInfo.thermalState;
        switch (state) {
            case NSProcessInfoThermalStateNominal:
                return @"Normal";
            case NSProcessInfoThermalStateFair:
                return @"Fair";
            case NSProcessInfoThermalStateSerious:
                return @"Serious";
            case NSProcessInfoThermalStateCritical:
                return @"Critical";
        }
    }
    return @"Thermal monitoring unavailable.";
}

- (BOOL)isThermalStateSeriousOrCritical {
    if (@available(iOS 11.0, *)) {
        NSProcessInfoThermalState state = NSProcessInfo.processInfo.thermalState;
        return state == NSProcessInfoThermalStateSerious ||
               state == NSProcessInfoThermalStateCritical;
    }
    return NO;
}

- (NSString *)powerStatus {
    return NSProcessInfo.processInfo.isLowPowerModeEnabled
        ? @"Low Power Mode"
        : @"Normal Power";
}

- (NSString *)uptimeStatus {
    NSTimeInterval seconds = NSProcessInfo.processInfo.systemUptime;
    if (!isfinite(seconds) || seconds < 0.0) {
        return @"Unavailable";
    }

    NSInteger totalMinutes = (NSInteger)(seconds / 60.0);
    NSInteger days = totalMinutes / (60 * 24);
    NSInteger hours = (totalMinutes / 60) % 24;
    NSInteger minutes = totalMinutes % 60;

    if (days > 0) {
        return [NSString stringWithFormat:@"%ldd %ldh %ldm",
                (long)days, (long)hours, (long)minutes];
    }

    return [NSString stringWithFormat:@"%ldh %ldm",
            (long)hours, (long)minutes];
}

@end
