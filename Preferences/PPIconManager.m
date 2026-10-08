#import "PPIconManager.h"

@implementation PPIconManager

+ (NSBundle *)bundle {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundle = [NSBundle bundleForClass:self];
    });
    return bundle;
}

+ (NSString *)iconNameForTitle:(NSString *)title {
    if (![title isKindOfClass:NSString.class] || title.length == 0) {
        return @"activity";
    }

    NSString *normalized = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *lower = [normalized lowercaseString];

    NSDictionary<NSString *, NSString *> *mapping = @{
        @"Automatic Status Updates": @"activity",
        @"Refresh Rate": @"refresh",
        @"FPS / Frame Pacing": @"gauge",
        @"FPS Control": @"gauge",
        @"Touch Optimization": @"hand-click",
        @"Touch Response": @"hand-click",
        @"Stutter Reduction": @"wave-sine",
        @"Gaming Mode": @"device-gamepad-2",
        @"Auto Performance Profile": @"activity",
        @"Stability Optimization": @"shield-check",
        @"Stability / Anti-Glitch": @"shield-check",
        @"Swipe Optimization": @"swipe",
        @"Anti-Spam Swipe": @"swipe",
        @"Keyboard Optimization": @"keyboard",
        @"Control Center Optimization": @"adjustments",
        @"App Compatibility": @"shield-check",
        @"RAM Optimization (Beta)": @"memory",
        @"RAM Optimization (BETA)": @"memory",
        @"CPU Optimization (Beta)": @"cpu",
        @"CPU Optimization (BETA)": @"cpu",
        @"GPU Optimization (Beta)": @"gpu",
        @"GPU Optimization (BETA)": @"gpu",
        @"Thermal Management": @"temperature",
        @"Thermal Profile": @"temperature",
        @"Background Activity Control": @"apps",
        @"Recording Lag Reduction": @"video",
        @"Screen Recording Optimization": @"video",
        @"Screen Recording Status": @"video",
        @"Charging Optimization": @"bolt",
        @"Charging & Heat Alerts": @"bolt",
        @"Battery Optimization": @"battery",
        @"Charging Reminder Threshold": @"battery",
        @"Optimized Charging": @"battery",
        @"Safe Mode": @"restore",
        @"Emergency Recovery": @"restore",
        @"Reset Performance Settings": @"settings",
        @"Respring": @"restore",
        @"Refresh Device Status": @"refresh",
        @"Device Capability": @"info-circle",
        @"Version": @"info-circle",
        @"Credits": @"info-circle",
        @"Performance": @"activity",
        @"Stability": @"shield-check",
        @"System": @"cpu",
        @"Recording & Power": @"battery",
        @"Recovery": @"restore",
        @"About": @"info-circle",
        @"PerformancePlus": @"activity",
        @"Battery": @"battery",
        @"Settings": @"settings",
        @"Master Optimization": @"activity",
        @"Gesture Responsiveness": @"hand-click",
        @"App Compatibility Mode": @"shield-check",
        @"Maximum Display Refresh Rate": @"refresh",
        @"Display Capture": @"video",
        @"CPU Information": @"cpu",
        @"CPU Usage": @"cpu",
        @"Memory Information": @"memory",
        @"Battery Information": @"battery",
        @"Power Mode": @"bolt",
        @"Uptime": @"activity",
        @"iOS Version": @"info-circle",
        @"Device Model": @"info-circle",
        @"Device": @"info-circle",
        @"iOS": @"info-circle",
        @"Jailbreak": @"info-circle",
        @"Rootless status": @"info-circle",
        @"Disable Experimental Features": @"settings",
        @"Reset All Settings": @"settings",
        @"Restore Safe Defaults": @"restore",
        @"Preference Storage": @"settings",
        @"Charging Heat Advice": @"temperature"
    };

    NSString *mapped = mapping[normalized];
    if (mapped) {
        return mapped;
    }

    if ([lower containsString:@"battery"]) return @"battery";
    if ([lower containsString:@"charge"] || [lower containsString:@"bolt"]) return @"bolt";
    if ([lower containsString:@"thermal"] || [lower containsString:@"heat"]) return @"temperature";
    if ([lower containsString:@"record"] || [lower containsString:@"video"]) return @"video";
    if ([lower containsString:@"refresh"]) return @"refresh";
    if ([lower containsString:@"fps"] || [lower containsString:@"frame"]) return @"gauge";
    if ([lower containsString:@"touch"] || [lower containsString:@"gesture"]) return @"hand-click";
    if ([lower containsString:@"stability"]) return @"shield-check";
    if ([lower containsString:@"swipe"]) return @"swipe";
    if ([lower containsString:@"keyboard"]) return @"keyboard";
    if ([lower containsString:@"control center"] || [lower containsString:@"adjust"]) return @"adjustments";
    if ([lower containsString:@"game"]) return @"device-gamepad-2";
    if ([lower containsString:@"ram"] || [lower containsString:@"memory"]) return @"memory";
    if ([lower containsString:@"cpu"]) return @"cpu";
    if ([lower containsString:@"background"]) return @"apps";
    if ([lower containsString:@"safe"] || [lower containsString:@"reset"] || [lower containsString:@"restore"] || [lower containsString:@"recovery"]) return @"restore";
    if ([lower containsString:@"version"] || [lower containsString:@"about"] || [lower containsString:@"info"]) return @"info-circle";
    if ([lower containsString:@"setting"]) return @"settings";
    if ([lower containsString:@"device capability"] || [lower containsString:@"about"]) return @"info-circle";
    return nil;
}

+ (UIImage *)imageForTitle:(NSString *)title {
    NSString *iconName = [self iconNameForTitle:title];
    if (iconName.length == 0) {
        return nil;
    }
    NSBundle *bundle = [self bundle];
    NSString *path = [bundle pathForResource:iconName ofType:@"png" inDirectory:@"Icons"];
    UIImage *image = path ? [UIImage imageWithContentsOfFile:path] : nil;
    if (!image) {
        return nil;
    }
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

+ (UIColor *)accentColorForIconName:(NSString *)iconName {
    NSDictionary<NSString *, UIColor *> *colors = @{
        @"activity": [UIColor colorWithRed:89.0/255.0 green:160.0/255.0 blue:255.0/255.0 alpha:1.0],
        @"refresh": [UIColor colorWithRed:86.0/255.0 green:171.0/255.0 blue:255.0/255.0 alpha:1.0],
        @"gauge": [UIColor colorWithRed:80.0/255.0 green:197.0/255.0 blue:203.0/255.0 alpha:1.0],
        @"hand-click": [UIColor colorWithRed:164.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0],
        @"shield-check": [UIColor colorWithRed:255.0/255.0 green:175.0/255.0 blue:84.0/255.0 alpha:1.0],
        @"wave-sine": [UIColor colorWithRed:118.0/255.0 green:170.0/255.0 blue:255.0/255.0 alpha:1.0],
        @"swipe": [UIColor colorWithRed:182.0/255.0 green:129.0/255.0 blue:255.0/255.0 alpha:1.0],
        @"keyboard": [UIColor colorWithRed:117.0/255.0 green:143.0/255.0 blue:255.0/255.0 alpha:1.0],
        @"adjustments": [UIColor colorWithRed:188.0/255.0 green:115.0/255.0 blue:255.0/255.0 alpha:1.0],
        @"device-gamepad-2": [UIColor colorWithRed:255.0/255.0 green:148.0/255.0 blue:70.0/255.0 alpha:1.0],
        @"memory": [UIColor colorWithRed:95.0/255.0 green:173.0/255.0 blue:123.0/255.0 alpha:1.0],
        @"cpu": [UIColor colorWithRed:95.0/255.0 green:154.0/255.0 blue:255.0/255.0 alpha:1.0],
        @"gpu": [UIColor colorWithRed:255.0/255.0 green:143.0/255.0 blue:103.0/255.0 alpha:1.0],
        @"temperature": [UIColor colorWithRed:255.0/255.0 green:102.0/255.0 blue:78.0/255.0 alpha:1.0],
        @"apps": [UIColor colorWithRed:255.0/255.0 green:189.0/255.0 blue:92.0/255.0 alpha:1.0],
        @"video": [UIColor colorWithRed:255.0/255.0 green:90.0/255.0 blue:104.0/255.0 alpha:1.0],
        @"battery": [UIColor colorWithRed:68.0/255.0 green:184.0/255.0 blue:110.0/255.0 alpha:1.0],
        @"bolt": [UIColor colorWithRed:84.0/255.0 green:192.0/255.0 blue:72.0/255.0 alpha:1.0],
        @"restore": [UIColor colorWithRed:223.0/255.0 green:78.0/255.0 blue:72.0/255.0 alpha:1.0],
        @"settings": [UIColor colorWithRed:120.0/255.0 green:127.0/255.0 blue:133.0/255.0 alpha:1.0],
        @"info-circle": [UIColor colorWithRed:153.0/255.0 green:161.0/255.0 blue:168.0/255.0 alpha:1.0]
    };

    UIColor *color = iconName.length > 0 ? colors[iconName] : nil;
    return color ?: [UIColor colorWithRed:97.0/255.0 green:164.0/255.0 blue:255.0/255.0 alpha:1.0];
}

+ (NSString *)subtitleForTitle:(NSString *)title {
    NSDictionary<NSString *, NSString *> *subtitles = @{
        @"Automatic Status Updates": @"Refresh device status automatically",
        @"Refresh Rate": @"Maximum display refresh rate",
        @"FPS Control": @"Frame pacing status",
        @"Touch Optimization": @"Reduce interaction latency",
        @"Touch Response": @"Improve touch responsiveness",
        @"Gesture Responsiveness": @"Improve gesture response",
        @"Stutter Reduction": @"Reduce stutter and frame drops",
        @"Gaming Mode": @"Current thermal and power status",
        @"Auto Performance Profile": @"Automatic performance profile",
        @"Stability / Anti-Glitch": @"Improve system stability",
        @"Anti-Spam Swipe": @"Reduce accidental gestures",
        @"Keyboard Optimization": @"Improve keyboard responsiveness",
        @"Control Center Optimization": @"Control Center status",
        @"FPS / Frame Pacing": @"Frame pacing status",
        @"Swipe Optimization": @"Reduce accidental gestures",
        @"App Compatibility Mode": @"Compatibility status",
        @"RAM Optimization (BETA)": @"Memory status",
        @"CPU Optimization (BETA)": @"Processor status",
        @"GPU Optimization (BETA)": @"Graphics status",
        @"Thermal Management": @"Current thermal state",
        @"Thermal Profile": @"Adjust thermal behavior safely",
        @"Background Activity Control": @"Optimize background activity",
        @"Screen Recording Optimization": @"Screen capture status",
        @"Screen Recording Status": @"Recording and mirroring status",
        @"Charging & Heat Alerts": @"Alerts while this page is open",
        @"Charging Reminder Threshold": @"Choose a reminder level",
        @"Charging Optimization": @"Manual charging reminder",
        @"Battery Optimization": @"Battery and power status",
        @"Optimized Charging": @"Use built-in iOS battery settings",
        @"Charging Heat Advice": @"Keep the device cool while charging",
        @"Safe Mode": @"Show status and recovery options",
        @"Device Capability": @"Device support information",
        @"PerformancePlus": @"Device status and battery care",
        @"Preference Storage": @"Saved on this device",
        @"Maximum Display Refresh Rate": @"Reported display capability",
        @"Display Capture": @"Recording and mirroring status",
        @"CPU Information": @"Logical processor cores",
        @"CPU Usage": @"Device-wide usage",
        @"Memory Information": @"System memory status",
        @"Battery Information": @"Charge level and state",
        @"Power Mode": @"Low Power Mode status",
        @"Uptime": @"Time since last restart",
        @"iOS Version": @"Installed system version",
        @"Device Model": @"Detected device model",
        @"Version": @"Installed package version",
        @"Jailbreak": @"Rootless environment",
        @"Rootless status": @"Package compatibility",
        @"Disable Experimental Features": @"Return experimental options to defaults",
        @"Reset All Settings": @"Clear saved preferences",
        @"Restore Safe Defaults": @"Restore recommended settings",
        @"Refresh Device Status": @"Update the values shown here",
        @"Respring": @"Restart SpringBoard"
    };
    return subtitles[title];
}

@end
