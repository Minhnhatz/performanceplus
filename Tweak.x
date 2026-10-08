#import <Foundation/Foundation.h>

static void PPApplySafeProfileState(void) {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.blue.performanceplus"];
    if (!defaults) {
        return;
    }

    BOOL enabled = [defaults objectForKey:@"enabled"] ? [defaults boolForKey:@"enabled"] : YES;
    BOOL gamingMode = [defaults boolForKey:@"PPGamingMode"];
    BOOL safeMode = [defaults boolForKey:@"PPSafeMode"];
    BOOL thermalManagement = [defaults boolForKey:@"PPThermalManagement"];

    if (!enabled || safeMode) {
        return;
    }

    NSString *thermalProfile = [defaults stringForKey:@"PPThermalProfile"] ?: @"Auto";
    if (thermalManagement && [thermalProfile isEqualToString:@"Performance"]) {
        (void)gamingMode;
    }
}

%ctor {
    PPApplySafeProfileState();
}
