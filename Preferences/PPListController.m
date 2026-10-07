#import "PPListController.h"
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>
#import "../PPManager.h"
#import <spawn.h>
#import <sys/wait.h>

extern char **environ;

@interface PPListController ()
@property (nonatomic) BOOL hasLoadedDeviceStatus;
@end

@implementation PPListController

- (NSArray *)specifiers {
    if (_specifiers) {
        return _specifiers;
    }

    NSMutableArray<PSSpecifier *> *specifiers = [NSMutableArray array];
    [specifiers addObject:[PSSpecifier groupSpecifierWithName:@"PERFORMANCE"]];

    PSSpecifier *performanceGroup = specifiers.lastObject;
    [performanceGroup setProperty:
        @"These switches save preferences only. They do not change CPU scheduling, memory use, or app launch behavior."
                      forKey:@"footerText"];

    [specifiers addObject:[self switchSpecifierWithTitle:@"Enable PerformancePlus"
                                                     key:@"enabled"
                                                default:@YES]];
    [specifiers addObject:[self switchSpecifierWithTitle:@"Performance Mode"
                                                     key:@"performanceMode"
                                                default:@NO]];
    [specifiers addObject:[self switchSpecifierWithTitle:@"Memory Optimization"
                                                     key:@"memoryOptimization"
                                                default:@NO]];
    [specifiers addObject:[self switchSpecifierWithTitle:@"App Launch Optimization"
                                                     key:@"appLaunchOptimization"
                                                default:@NO]];

    [specifiers addObject:[PSSpecifier groupSpecifierWithName:@"DEVICE STATUS"]];
    PPManager *manager = self.hasLoadedDeviceStatus ? PPManager.sharedManager : nil;
    [specifiers addObject:[self valueSpecifierWithTitle:@"CPU Information"
                                                  value:manager.cpuStatus ?: @"Select Refresh Device Status"]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"Memory Information"
                                                  value:manager.memoryStatus ?: @"Select Refresh Device Status"]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"Battery Information"
                                                  value:manager.batteryStatus ?: @"Select Refresh Device Status"]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"Thermal State"
                                                  value:manager.thermalStatus ?: @"Select Refresh Device Status"]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"Power Mode"
                                                  value:manager.powerStatus ?: @"Select Refresh Device Status"]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"Uptime"
                                                  value:manager.uptimeStatus ?: @"Select Refresh Device Status"]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"iOS Version"
                                                  value:manager.systemVersion ?: @"Select Refresh Device Status"]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"Device Model"
                                                  value:manager.deviceModel ?: @"Select Refresh Device Status"]];

    [specifiers addObject:[PSSpecifier groupSpecifierWithName:@"TWEAK STATUS"]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"Loaded Tweak Status"
                                                  value:manager.loadedTweakStatus ?: @"Select Refresh Device Status"]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"Possible Conflicts"
                                                  value:manager.possibleConflictStatus ?: @"Select Refresh Device Status"]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"Installed Tweak Count"
                                                  value:manager.installedTweakCountStatus ?: @"Select Refresh Device Status"]];

    [specifiers addObject:[PSSpecifier groupSpecifierWithName:@"ACTIONS"]];
    [specifiers addObject:[self buttonSpecifierWithTitle:@"Refresh Device Status"
                                                  action:@selector(refreshDeviceStatus)]];
    [specifiers addObject:[self buttonSpecifierWithTitle:@"Respring"
                                                  action:@selector(confirmRespring)]];

    [specifiers addObject:[PSSpecifier groupSpecifierWithName:@"ABOUT"]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"PerformancePlus"
                                                  value:@"Device information and user preferences"]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"Version"
                                                  value:@"1.0.0"]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"Developer"
                                                  value:@"Blue"]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"Source"
                                                  value:@"github.com/Minhnhatz/performanceplus"]];

    _specifiers = specifiers;
    return _specifiers;
}

- (PSSpecifier *)switchSpecifierWithTitle:(NSString *)title
                                      key:(NSString *)key
                                  default:(NSNumber *)defaultValue {
    PSSpecifier *specifier =
        [PSSpecifier preferenceSpecifierNamed:title
                                        target:self
                                           set:@selector(setPreferenceValue:specifier:)
                                           get:@selector(readPreferenceValue:)
                                        detail:nil
                                          cell:PSSwitchCell
                                          edit:nil];
    [specifier setProperty:key forKey:@"key"];
    [specifier setProperty:defaultValue forKey:@"default"];
    return specifier;
}

- (PSSpecifier *)valueSpecifierWithTitle:(NSString *)title
                                   value:(NSString *)value {
    PSSpecifier *specifier =
        [PSSpecifier preferenceSpecifierNamed:title
                                        target:nil
                                           set:nil
                                           get:nil
                                        detail:nil
                                          cell:PSTitleValueCell
                                          edit:nil];
    [specifier setProperty:value forKey:@"value"];
    return specifier;
}

- (PSSpecifier *)buttonSpecifierWithTitle:(NSString *)title action:(SEL)action {
    PSSpecifier *specifier =
        [PSSpecifier preferenceSpecifierNamed:title
                                        target:self
                                           set:nil
                                           get:nil
                                        detail:nil
                                          cell:PSButtonCell
                                          edit:nil];
    specifier.buttonAction = action;
    return specifier;
}

- (id)readPreferenceValue:(PSSpecifier *)specifier {
    NSString *key = [specifier propertyForKey:@"key"];
    id defaultValue = [specifier propertyForKey:@"default"];
    if (![key isKindOfClass:NSString.class]) {
        return defaultValue ?: @NO;
    }

    PPManager *manager = PPManager.sharedManager;
    if ([key isEqualToString:@"enabled"]) {
        return @(manager.isEnabled);
    }
    return @([manager isOptionEnabled:key]);
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    NSString *key = [specifier propertyForKey:@"key"];
    if (![key isKindOfClass:NSString.class] ||
        ![value respondsToSelector:@selector(boolValue)]) {
        return;
    }

    PPManager *manager = PPManager.sharedManager;
    BOOL enabled = [value boolValue];
    if ([key isEqualToString:@"enabled"]) {
        [manager setEnabled:enabled];
    } else {
        [manager setOption:key enabled:enabled];
    }
}

- (void)refreshDeviceStatus {
    self.hasLoadedDeviceStatus = YES;
    _specifiers = nil;
    [self reloadSpecifiers];
}

- (void)confirmRespring {
    UIAlertController *confirmation =
        [UIAlertController alertControllerWithTitle:@"Respring"
                                            message:@"Restart SpringBoard now?"
                                     preferredStyle:UIAlertControllerStyleAlert];
    [confirmation addAction:
        [UIAlertAction actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleCancel
                               handler:nil]];
    __weak PPListController *weakSelf = self;
    [confirmation addAction:
        [UIAlertAction actionWithTitle:@"Respring"
                                 style:UIAlertActionStyleDestructive
                               handler:^(__unused UIAlertAction *action) {
        [weakSelf respring];
    }]];
    [self presentViewController:confirmation animated:YES completion:nil];
}

- (void)respring {
    pid_t process = 0;
    char *arguments[] = {
        "/usr/bin/killall",
        "-TERM",
        "SpringBoard",
        NULL
    };
    int spawnError = posix_spawn(&process,
                                 arguments[0],
                                 NULL,
                                 NULL,
                                 arguments,
                                 environ);
    if (spawnError != 0) {
        [self showMessage:@"Respring Failed"
                  message:[NSString stringWithFormat:
                           @"Could not start killall (error %d).", spawnError]];
        return;
    }

    int status = 0;
    if (waitpid(process, &status, 0) == -1 ||
        !WIFEXITED(status) ||
        WEXITSTATUS(status) != 0) {
        [self showMessage:@"Respring Failed"
                  message:@"SpringBoard could not be restarted. Check jailbreak permissions."];
    }
}

- (void)showMessage:(NSString *)title message:(NSString *)message {
    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:title
                                            message:message
                                     preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:
        [UIAlertAction actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                               handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
