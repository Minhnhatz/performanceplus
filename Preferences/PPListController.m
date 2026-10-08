#import "PPListController.h"
#import "PPIconManager.h"
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>
#import "../PPManager.h"
#import <errno.h>
#import <spawn.h>
#import <sys/wait.h>

extern char **environ;

@interface PPListController ()
@property (nonatomic) BOOL observingStatusChanges;
@property (nonatomic) BOOL didShowChargingReminder;
@property (nonatomic) BOOL didShowChargingHeatWarning;
@end

@implementation PPListController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"PerformancePlus";
    UIImage *icon = [PPIconManager imageForTitle:self.title];

    UIImageView *iconView = [[UIImageView alloc] initWithImage:icon];
    iconView.translatesAutoresizingMaskIntoConstraints = NO;
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.tintColor = [PPIconManager accentColorForIconName:[PPIconManager iconNameForTitle:self.title]];
    iconView.backgroundColor = [[PPIconManager accentColorForIconName:[PPIconManager iconNameForTitle:self.title]] colorWithAlphaComponent:0.15];
    iconView.layer.cornerRadius = 8.0;
    iconView.layer.masksToBounds = YES;
    [NSLayoutConstraint activateConstraints:@[
        [iconView.widthAnchor constraintEqualToConstant:16],
        [iconView.heightAnchor constraintEqualToConstant:16]
    ]];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = self.title;
    titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    titleLabel.textColor = UIColor.labelColor;

    UIStackView *titleView = [[UIStackView alloc] initWithArrangedSubviews:@[iconView, titleLabel]];
    titleView.axis = UILayoutConstraintAxisHorizontal;
    titleView.alignment = UIStackViewAlignmentCenter;
    titleView.spacing = 6;
    titleView.isAccessibilityElement = YES;
    titleView.accessibilityLabel = self.title;
    self.navigationItem.titleView = titleView;

    UITableView *tableView = self.table;
    if (tableView) {
        tableView.backgroundColor = UIColor.systemGroupedBackgroundColor;
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableView.separatorColor = UIColor.separatorColor;
        tableView.rowHeight = 64.0;
        tableView.estimatedRowHeight = 64.0;
        tableView.sectionHeaderHeight = 38.0;
        tableView.estimatedSectionHeaderHeight = 38.0;
        tableView.sectionFooterHeight = 8.0;
        tableView.estimatedSectionFooterHeight = 8.0;
        tableView.contentInset = UIEdgeInsetsMake(4.0, 0.0, 12.0, 0.0);
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self styleVisibleCells];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (@available(iOS 13.0, *)) {
        if (previousTraitCollection &&
            [self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            [self styleVisibleCells];
        }
    }
}

- (void)styleVisibleCells {
    UITableView *tableView = self.table;
    if (!tableView) {
        return;
    }

    for (UITableViewCell *cell in tableView.visibleCells) {
        NSString *title = cell.textLabel.text ?: @"";
        [self styleCell:cell withTitle:title];
    }

    for (NSInteger section = 0; section < tableView.numberOfSections; section++) {
        UITableViewHeaderFooterView *header = [tableView headerViewForSection:section];
        header.textLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightSemibold];
        header.textLabel.textColor = UIColor.secondaryLabelColor;
        header.textLabel.text = [header.textLabel.text localizedCapitalizedString];
    }
}

- (void)styleCell:(UITableViewCell *)cell withTitle:(NSString *)title {
    if (!cell || !cell.textLabel) {
        return;
    }

    UIView *card = cell.backgroundView;
    if (!card || card.tag != 7104) {
        card = [[UIView alloc] initWithFrame:cell.bounds];
        card.tag = 7104;
        cell.backgroundView = card;
    }
    card.backgroundColor = UIColor.secondarySystemGroupedBackgroundColor;
    card.layer.borderWidth = 0.0;
    NSIndexPath *indexPath = [self.table indexPathForCell:cell];
    NSInteger rowCount = indexPath ? [self.table numberOfRowsInSection:indexPath.section] : 1;
    BOOL firstRow = !indexPath || indexPath.row == 0;
    BOOL lastRow = !indexPath || indexPath.row == rowCount - 1;
    card.layer.cornerRadius = (firstRow || lastRow) ? 14.0 : 0.0;
    CACornerMask roundedCorners = 0;
    if (firstRow) {
        roundedCorners |= kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    }
    if (lastRow) {
        roundedCorners |= kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
    }
    card.layer.maskedCorners = roundedCorners;
    card.frame = CGRectInset(cell.bounds, 14.0, 0.0);
    card.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    cell.backgroundColor = UIColor.clearColor;
    cell.contentView.backgroundColor = UIColor.clearColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = UIColor.labelColor;
    cell.textLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightSemibold];
    cell.textLabel.numberOfLines = 1;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.minimumScaleFactor = 0.9;

    if (cell.detailTextLabel) {
        cell.detailTextLabel.textColor = UIColor.secondaryLabelColor;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightMedium];
        cell.detailTextLabel.numberOfLines = 1;
        cell.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }

    UIImage *icon = [PPIconManager imageForTitle:title];
    UIImageView *iconView = cell.imageView;
    if (icon && iconView) {
        UIColor *accent = [PPIconManager accentColorForIconName:[PPIconManager iconNameForTitle:title]];
        iconView.image = icon;
        iconView.tintColor = accent;
        iconView.backgroundColor = [accent colorWithAlphaComponent:0.15];
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        iconView.layer.cornerRadius = 10.0;
        iconView.layer.masksToBounds = YES;
        cell.separatorInset = UIEdgeInsetsMake(0.0, 58.0, 0.0, 14.0);
    } else {
        iconView.image = nil;
        cell.separatorInset = UIEdgeInsetsMake(0.0, 20.0, 0.0, 14.0);
    }
    if (lastRow) {
        cell.separatorInset = UIEdgeInsetsMake(0.0, CGRectGetWidth(self.table.bounds), 0.0, 0.0);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startObservingStatusChanges];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopObservingStatusChanges];
}

- (void)startObservingStatusChanges {
    PPManager *manager = PPManager.sharedManager;
    BOOL automaticUpdates = [manager isOptionEnabled:@"PPAutomaticStatusUpdates"];
    BOOL chargingReminder = [manager isOptionEnabled:@"PPChargingReminderEnabled"];
    if (self.observingStatusChanges || (!automaticUpdates && !chargingReminder)) {
        return;
    }

    NSNotificationCenter *notificationCenter = NSNotificationCenter.defaultCenter;
    NSMutableArray<NSNotificationName> *notifications = [NSMutableArray array];
    if (automaticUpdates || chargingReminder) {
        UIDevice.currentDevice.batteryMonitoringEnabled = YES;
        [notifications addObjectsFromArray:@[
            UIDeviceBatteryLevelDidChangeNotification,
            UIDeviceBatteryStateDidChangeNotification
        ]];
    }
    if (automaticUpdates || chargingReminder) {
        [notifications addObject:NSProcessInfoThermalStateDidChangeNotification];
    }
    if (automaticUpdates) {
        [notifications addObjectsFromArray:@[
            NSProcessInfoPowerStateDidChangeNotification,
            UIScreenCapturedDidChangeNotification
        ]];
    }
    for (NSNotificationName notification in notifications) {
        [notificationCenter addObserver:self
                               selector:@selector(statusDidChange:)
                                   name:notification
                                 object:nil];
    }
    self.observingStatusChanges = YES;
    [self evaluateChargingReminder];
}

- (void)stopObservingStatusChanges {
    if (!self.observingStatusChanges) {
        return;
    }
    [NSNotificationCenter.defaultCenter removeObserver:self];
    UIDevice.currentDevice.batteryMonitoringEnabled = NO;
    self.observingStatusChanges = NO;
}

- (void)statusDidChange:(NSNotification *)notification {
    if (!self.view.window) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.view.window) {
            if ([notification.name isEqualToString:UIDeviceBatteryLevelDidChangeNotification] ||
                [notification.name isEqualToString:UIDeviceBatteryStateDidChangeNotification] ||
                [notification.name isEqualToString:NSProcessInfoThermalStateDidChangeNotification]) {
                [self evaluateChargingReminder];
            }
            [self refreshDeviceStatus];
        }
    });
}

- (void)evaluateChargingReminder {
    PPManager *manager = PPManager.sharedManager;
    if (![manager isOptionEnabled:@"PPChargingReminderEnabled"]) {
        self.didShowChargingReminder = NO;
        self.didShowChargingHeatWarning = NO;
        return;
    }

    NSInteger batteryLevel = manager.batteryLevelPercentage;
    BOOL isCharging = manager.isBatteryCharging;
    if (!isCharging) {
        self.didShowChargingReminder = NO;
        self.didShowChargingHeatWarning = NO;
        return;
    }

    if (manager.isThermalStateSeriousOrCritical) {
        if (!self.didShowChargingHeatWarning && self.view.window) {
            self.didShowChargingHeatWarning = YES;
            [self showMessage:@"iPhone is warm while charging"
                      message:@"iOS reports a serious or critical thermal state while the battery is charging. Stop demanding apps, move the iPhone out of direct sun to a cool, ventilated place, and disconnect the charger if the device feels unusually hot. Let it cool naturally. iOS manages charging and thermal protection; PerformancePlus cannot control either."];
        }
        return;
    }
    self.didShowChargingHeatWarning = NO;

    NSInteger threshold = manager.chargingReminderThreshold;
    if (batteryLevel < threshold) {
        self.didShowChargingReminder = NO;
        return;
    }

    if (self.didShowChargingReminder || !self.view.window) {
        return;
    }

    self.didShowChargingReminder = YES;
    [self showMessage:[NSString stringWithFormat:@"%ld%% charging reminder",
                       (long)threshold]
              message:[NSString stringWithFormat:
                       @"Battery is at %ld%% and still charging. Unplug manually if you want to stop charging near %ld%%. PerformancePlus cannot stop charging. For routine-based optimized charging, use the built-in iOS Battery settings.",
                       (long)batteryLevel, (long)threshold]];
}

- (NSArray *)specifiers {
    if (_specifiers) {
        return _specifiers;
    }

    PPManager *manager = PPManager.sharedManager;
    NSMutableArray<PSSpecifier *> *specifiers = [NSMutableArray array];

    if ([manager isOptionEnabled:@"PPSafeMode"]) {
        [specifiers addObject:[PSSpecifier groupSpecifierWithName:@"Safe Mode"]];
        [specifiers addObject:[self switchSpecifierWithTitle:@"Safe Mode" key:@"PPSafeMode" default:@NO]];
        [specifiers addObject:[PSSpecifier groupSpecifierWithName:@"Device Status"]];
        [self addDeviceStatusSpecifiersToArray:specifiers manager:manager];
        [self addRecoverySpecifiersToArray:specifiers];
        [specifiers addObject:[self buttonSpecifierWithTitle:@"Refresh Device Status" action:@selector(refreshDeviceStatus)]];
        [specifiers addObject:[self buttonSpecifierWithTitle:@"Respring" action:@selector(confirmRespring)]];
        _specifiers = specifiers;
        return _specifiers;
    }

    [specifiers addObject:[PSSpecifier groupSpecifierWithName:@"Performance"]];
    [specifiers addObject:[self unsupportedSpecifierWithTitle:@"Master Optimization"]];
    [specifiers addObject:[self switchSpecifierWithTitle:@"Automatic Status Updates" key:@"PPAutomaticStatusUpdates" default:@YES]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"Refresh Rate" value:manager.displayRefreshRateStatus]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"FPS / Frame Pacing" value:@"App-specific frame-rate limits"]];
    [specifiers addObject:[self unsupportedSpecifierWithTitle:@"Touch Optimization"]];
    [specifiers addObject:[self unsupportedSpecifierWithTitle:@"Touch Response"]];
    [specifiers addObject:[self unsupportedSpecifierWithTitle:@"Gesture Responsiveness"]];
    [specifiers addObject:[self unsupportedSpecifierWithTitle:@"Stutter Reduction"]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"Gaming Mode" value:[NSString stringWithFormat:@"Thermal: %@ · Power: %@", manager.thermalStatus, manager.powerStatus]]];
    [specifiers addObject:[self unsupportedSpecifierWithTitle:@"Auto Performance Profile"]];

    [specifiers addObject:[PSSpecifier groupSpecifierWithName:@"Stability"]];
    [specifiers addObject:[self unsupportedSpecifierWithTitle:@"Stability / Anti-Glitch"]];
    [specifiers addObject:[self unsupportedSpecifierWithTitle:@"Swipe Optimization"]];
    [specifiers addObject:[self unsupportedSpecifierWithTitle:@"Keyboard Optimization"]];
    [specifiers addObject:[self unsupportedSpecifierWithTitle:@"Control Center Optimization"]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"App Compatibility Mode" value:@"Detection only"]];

    [specifiers addObject:[PSSpecifier groupSpecifierWithName:@"System"]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"RAM Optimization (Beta)" value:[NSString stringWithFormat:@"Read-only · %@", manager.memoryStatus]]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"CPU Optimization (Beta)" value:[NSString stringWithFormat:@"Read-only · %@", manager.cpuUsageStatus]]];
    [specifiers addObject:[self unsupportedSpecifierWithTitle:@"GPU Optimization (Beta)"]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"Thermal Management" value:[NSString stringWithFormat:@"iOS managed · %@", manager.thermalStatus]]];
    [specifiers addObject:[self unsupportedSpecifierWithTitle:@"Thermal Profile"]];
    [specifiers addObject:[self unsupportedSpecifierWithTitle:@"Background Activity Control"]];

    [specifiers addObject:[PSSpecifier groupSpecifierWithName:@"Recording & Power"]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"Screen Recording Status" value:manager.displayCaptureStatus]];

    [specifiers addObject:[self switchSpecifierWithTitle:@"Charging & Heat Alerts" key:@"PPChargingReminderEnabled" default:@YES]];
    [specifiers addObject:[self listSpecifierWithTitle:@"Charging Reminder Threshold"
                                                   key:@"PPChargingReminderThreshold"
                                           defaultValue:@"80"
                                                 values:@[@"80", @"85", @"90", @"95", @"100"]
                                                 titles:@[@"80%", @"85%", @"90%", @"95%", @"100%"]]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"Charging Optimization" value:@"Manual reminder; iOS controls charging"]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"Battery Optimization" value:[NSString stringWithFormat:@"Status · %@ · %@", manager.batteryStatus, manager.powerStatus]]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"Optimized Charging" value:@"Use iOS Battery settings"]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"Charging Heat Advice" value:@"Keep the device cool while charging"]];

    [self addRecoverySpecifiersToArray:specifiers];
    [specifiers addObject:[self buttonSpecifierWithTitle:@"Refresh Device Status" action:@selector(refreshDeviceStatus)]];
    [specifiers addObject:[self buttonSpecifierWithTitle:@"Respring" action:@selector(confirmRespring)]];

    [specifiers addObject:[PSSpecifier groupSpecifierWithName:@"About"]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"Preference Storage" value:@"Saved on this device"]];
    [self addDeviceStatusSpecifiersToArray:specifiers manager:manager];
    [specifiers addObject:[self valueSpecifierWithTitle:@"PerformancePlus" value:@"Low-overhead device status"]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"Version" value:@"1.1.6"]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"Device" value:manager.deviceModel]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"iOS" value:manager.systemVersion]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"Jailbreak" value:@"Dopamine rootless" ]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"Rootless status" value:@"Rootless compatible"]];

    _specifiers = specifiers;
    return _specifiers;
}

- (void)addDeviceStatusSpecifiersToArray:(NSMutableArray<PSSpecifier *> *)specifiers
                                 manager:(PPManager *)manager {
    [specifiers addObject:[self valueSpecifierWithTitle:@"Device Capability" value:manager.deviceCapabilityStatus]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"Maximum Display Refresh Rate" value:manager.displayRefreshRateStatus]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"Display Capture" value:manager.displayCaptureStatus]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"CPU Information" value:manager.cpuStatus]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"CPU Usage" value:manager.cpuUsageStatus]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"Memory Information" value:manager.memoryStatus]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"Battery Information" value:manager.batteryStatus]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"Power Mode" value:manager.powerStatus]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"Uptime" value:manager.uptimeStatus]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"iOS Version" value:manager.systemVersion]];
    [specifiers addObject:[self valueSpecifierWithTitle:@"Device Model" value:manager.deviceModel]];
}

- (void)addRecoverySpecifiersToArray:(NSMutableArray<PSSpecifier *> *)specifiers {
    [specifiers addObject:[PSSpecifier groupSpecifierWithName:@"RECOVERY"]];
    [specifiers addObject:[self switchSpecifierWithTitle:@"Safe Mode" key:@"PPSafeMode" default:@NO]];
    [specifiers addObject:[self buttonSpecifierWithTitle:@"Disable Experimental Features" action:@selector(disableExperimentalFeatures)]];
    [specifiers addObject:[self buttonSpecifierWithTitle:@"Reset All Settings" action:@selector(resetAllSettings)]];
    [specifiers addObject:[self buttonSpecifierWithTitle:@"Restore Safe Defaults" action:@selector(restoreSafeDefaults)]];
}

- (PSSpecifier *)switchSpecifierWithTitle:(NSString *)title key:(NSString *)key default:(NSNumber *)defaultValue {
    PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:title
                                                            target:self
                                                               set:@selector(setPreferenceValue:specifier:)
                                                               get:@selector(readPreferenceValue:)
                                                            detail:nil
                                                              cell:PSSwitchCell
                                                              edit:nil];
    [specifier setProperty:key forKey:@"key"];
    [specifier setProperty:defaultValue ?: @NO forKey:@"default"];
    return specifier;
}

- (PSSpecifier *)listSpecifierWithTitle:(NSString *)title
                                   key:(NSString *)key
                           defaultValue:(NSString *)defaultValue
                                 values:(NSArray *)values
                                 titles:(NSArray *)titles {
    PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:title
                                                            target:self
                                                               set:@selector(setPreferenceValue:specifier:)
                                                               get:@selector(readPreferenceValue:)
                                                            detail:nil
                                                              cell:PSLinkListCell
                                                              edit:nil];
    [specifier setProperty:key forKey:@"key"];
    [specifier setProperty:defaultValue ?: @"Auto" forKey:@"default"];
    [specifier setProperty:titles ?: values forKey:@"titles"];
    [specifier setProperty:values ?: @[] forKey:@"values"];
    return specifier;
}

- (PSSpecifier *)valueSpecifierWithTitle:(NSString *)title value:(NSString *)value {
    NSString *displayValue = [value isKindOfClass:NSString.class] ? value : @"Unavailable";
    if ([displayValue hasPrefix:@"Not Supported "]) {
        displayValue = @"Not Supported";
    }
    PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:title
                                                            target:self
                                                               set:nil
                                                               get:@selector(valueForSpecifier:)
                                                            detail:nil
                                                              cell:PSTitleValueCell
                                                              edit:nil];
    [specifier setProperty:(displayValue.length > 0 ? displayValue : @"Unavailable") forKey:@"value"];
    return specifier;
}

- (PSSpecifier *)unsupportedSpecifierWithTitle:(NSString *)title {
    return [self valueSpecifierWithTitle:title value:PPManager.sharedManager.unsupportedMessage];
}

- (PSSpecifier *)buttonSpecifierWithTitle:(NSString *)title action:(SEL)action {
    PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:title
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
    if (![key isKindOfClass:NSString.class]) {
        return [specifier propertyForKey:@"default"] ?: @NO;
    }

    PPManager *manager = PPManager.sharedManager;
    NSNumber *cellType = [specifier propertyForKey:@"cell"];
    if (cellType.integerValue == PSLinkListCell) {
        return [manager stringForKey:key defaultValue:[specifier propertyForKey:@"default"] ?: @"Auto"];
    }
    if ([key isEqualToString:@"enabled"]) {
        return @(manager.isEnabled);
    }
    return @([manager isOptionEnabled:key]);
}

- (id)valueForSpecifier:(PSSpecifier *)specifier {
    id value = [specifier propertyForKey:@"value"];
    return [value isKindOfClass:NSString.class] && [value length] > 0 ? value : @"Unavailable";
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    NSString *key = [specifier propertyForKey:@"key"];
    if (![key isKindOfClass:NSString.class]) {
        return;
    }

    PPManager *manager = PPManager.sharedManager;
    if ([value isKindOfClass:NSString.class]) {
        [manager setString:value forKey:key];
        if ([key isEqualToString:@"PPChargingReminderThreshold"]) {
            self.didShowChargingReminder = NO;
            [self evaluateChargingReminder];
        }
        return;
    }
    if ([value respondsToSelector:@selector(boolValue)]) {
        if ([key isEqualToString:@"enabled"]) {
            [manager setEnabled:[value boolValue]];
        } else {
            [manager setOption:key enabled:[value boolValue]];
        }

        if ([key isEqualToString:@"PPAutomaticStatusUpdates"]) {
            [self stopObservingStatusChanges];
            [self startObservingStatusChanges];
        } else if ([key isEqualToString:@"PPChargingReminderEnabled"]) {
            self.didShowChargingReminder = NO;
            [self stopObservingStatusChanges];
            [self startObservingStatusChanges];
        } else if ([key isEqualToString:@"PPSafeMode"]) {
            _specifiers = nil;
            [self reloadSpecifiers];
        }
    }
}

- (void)refreshDeviceStatus {
    _specifiers = nil;
    [self reloadSpecifiers];
}

- (void)disableExperimentalFeatures {
    PPManager *manager = PPManager.sharedManager;
    [manager setOption:@"PPRAMOptimization" enabled:NO];
    [manager setOption:@"PPCPUOptimization" enabled:NO];
    [manager setOption:@"PPGPUOptimization" enabled:NO];
    [manager setString:@"Balanced" forKey:@"PPThermalProfile"];
    [self showMessage:@"Experimental features disabled" message:@"The tweak has been returned to a safe default profile."];
}

- (void)resetAllSettings {
    PPManager *manager = PPManager.sharedManager;
    [manager registerDefaultPreferences];
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.blue.performanceplus"];
    [defaults removePersistentDomainForName:@"com.blue.performanceplus"];
    [manager registerDefaultPreferences];
    [self showMessage:@"Settings reset" message:@"All PerformancePlus preferences were reset to safe defaults."];
    _specifiers = nil;
    [self reloadSpecifiers];
}

- (void)restoreSafeDefaults {
    [self disableExperimentalFeatures];
    [self resetAllSettings];
}

- (void)confirmRespring {
    UIAlertController *confirmation = [UIAlertController alertControllerWithTitle:@"Respring" message:@"Restart SpringBoard now?" preferredStyle:UIAlertControllerStyleAlert];
    [confirmation addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    __weak PPListController *weakSelf = self;
    [confirmation addAction:[UIAlertAction actionWithTitle:@"Respring" style:UIAlertActionStyleDestructive handler:^(__unused UIAlertAction *action) {
        [weakSelf respring];
    }]];
    [self presentViewController:confirmation animated:YES completion:nil];
}

- (void)respring {
    const char *executable = "/var/jb/usr/bin/sbreload";
    pid_t process = 0;
    char *arguments[] = {(char *)executable, NULL};
    int spawnError = posix_spawn(&process, executable, NULL, NULL, arguments, environ);
    if (spawnError != 0) {
        [self showMessage:@"Respring failed" message:[NSString stringWithFormat:@"Could not start %@ (error %d).", @(executable), spawnError]];
        return;
    }

    int status = 0;
    pid_t waitedProcess;
    do {
        waitedProcess = waitpid(process, &status, 0);
    } while (waitedProcess == -1 && errno == EINTR);

    if (waitedProcess == -1 || !WIFEXITED(status) || WEXITSTATUS(status) != 0) {
        [self showMessage:@"Respring failed" message:@"SpringBoard could not be restarted through sbreload."];
    }
}

- (void)showMessage:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
