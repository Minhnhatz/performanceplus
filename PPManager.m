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

static NSUserDefaults *PPPreferences(void) {
    return [[NSUserDefaults alloc] initWithSuiteName:kPPDomain];
}

static NSSet<NSString *> *PPOptionKeys(void) {
    static NSSet<NSString *> *keys;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keys = [NSSet setWithObjects:
            kPPPerformanceModeKey,
            kPPMemoryOptimizationKey,
            kPPAppLaunchOptimizationKey,
            nil];
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

- (BOOL)isOptionEnabled:(NSString *)option {
    if (![option isKindOfClass:NSString.class] ||
        ![PPOptionKeys() containsObject:option]) {
        return NO;
    }
    NSUserDefaults *defaults = PPPreferences();
    return defaults ? [defaults boolForKey:option] : NO;
}

- (void)setOption:(NSString *)option enabled:(BOOL)enabled {
    if (![option isKindOfClass:NSString.class] ||
        ![PPOptionKeys() containsObject:option]) {
        return;
    }
    NSUserDefaults *defaults = PPPreferences();
    if (!defaults) {
        return;
    }
    [defaults setBool:enabled forKey:option];
}

- (NSString *)deviceModel {
    char machine[256] = {0};
    size_t size = sizeof(machine);
    NSString *identifier = @"";

    if (sysctlbyname("hw.machine", machine, &size, NULL, 0) == 0) {
        machine[sizeof(machine) - 1] = '\0';
        identifier = [NSString stringWithUTF8String:machine] ?: @"";
    }

    NSString *model = UIDevice.currentDevice.model ?: @"Unknown";
    return identifier.length > 0
        ? [NSString stringWithFormat:@"%@ (%@)", model, identifier]
        : model;
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
    float level = device.batteryLevel;
    UIDeviceBatteryState state = device.batteryState;

    if (level < 0.0f || level > 1.0f) {
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

    return [NSString stringWithFormat:@"%.0f%% • %@",
            level * 100.0f, stateDescription];
}

- (NSString *)thermalStatus {
    if (@available(iOS 11.0, *)) {
        NSProcessInfoThermalState state =
            NSProcessInfo.processInfo.thermalState;
        switch (state) {
            case NSProcessInfoThermalStateNominal:
                return @"Nominal";
            case NSProcessInfoThermalStateFair:
                return @"Fair";
            case NSProcessInfoThermalStateSerious:
                return @"Serious";
            case NSProcessInfoThermalStateCritical:
                return @"Critical";
        }
    }
    return @"Unavailable";
}

- (NSString *)powerStatus {
    return NSProcessInfo.processInfo.isLowPowerModeEnabled
        ? @"Low Power Mode"
        : @"Normal Power";
}

- (NSString *)uptimeStatus {
    NSTimeInterval seconds =
        NSProcessInfo.processInfo.systemUptime;
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

- (NSString *)loadedTweakStatus {
    return @"Unable to determine reliably";
}

- (NSString *)possibleConflictStatus {
    return @"Unable to determine";
}

- (NSString *)installedTweakCountStatus {
    NSString *directory =
        @"/var/jb/Library/MobileSubstrate/DynamicLibraries";
    NSError *error = nil;
    NSArray<NSString *> *contents =
        [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory
                                                            error:&error];

    if (!contents) {
        return @"Unable to determine";
    }

    NSUInteger libraryCount = 0;
    for (NSString *name in contents) {
        if ([name.pathExtension isEqualToString:@"dylib"]) {
            libraryCount++;
        }
    }

    return [NSString stringWithFormat:@"%lu tweak libraries found",
            (unsigned long)libraryCount];
}

- (NSString *)diagnosticsSummary {
    NSInteger cpuCount =
        [NSProcessInfo processInfo].processorCount;

    return [NSString stringWithFormat:
            @"Device: %@\n"
             "iOS: %@\n"
             "CPU cores: %ld\n"
             "Memory: %@\n"
             "Thermal: %@\n"
             "Power: %@\n"
             "Uptime: %@\n"
             "Performance Mode: %@",
            [self deviceModel],
            [self systemVersion],
            (long)cpuCount,
            [self memoryStatus],
            [self thermalStatus],
            [self powerStatus],
            [self uptimeStatus],
            [self isEnabled] ? @"ON" : @"OFF"];
}

@end
