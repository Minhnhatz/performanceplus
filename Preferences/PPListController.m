#import "PPListController.h"
#import <UIKit/UIKit.h>
#import <spawn.h>
#import <sys/wait.h>
#import "../PPManager.h"

extern char **environ;

@interface PPPreferenceCell : UITableViewCell

- (void)configureWithTitle:(NSString *)title
                  subtitle:(NSString *)subtitle
                    symbol:(NSString *)symbol
                 tintColor:(UIColor *)tintColor
              accessoryView:(UIView *)accessoryView
           accessoryType:(UITableViewCellAccessoryType)accessoryType;

@end

@implementation PPPreferenceCell {
    UIImageView *_symbolView;
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UIColor.secondarySystemGroupedBackgroundColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        _symbolView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _symbolView.translatesAutoresizingMaskIntoConstraints = NO;
        _symbolView.contentMode = UIViewContentModeCenter;
        _symbolView.tintColor = UIColor.whiteColor;
        _symbolView.layer.cornerRadius = 17.0;
        _symbolView.clipsToBounds = YES;
        [self.contentView addSubview:_symbolView];

        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _titleLabel.adjustsFontForContentSizeCategory = YES;
        _titleLabel.textColor = UIColor.labelColor;

        _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _subtitleLabel.font =
            [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        _subtitleLabel.adjustsFontForContentSizeCategory = YES;
        _subtitleLabel.textColor = UIColor.secondaryLabelColor;
        _subtitleLabel.numberOfLines = 0;

        UIStackView *labels =
            [[UIStackView alloc] initWithArrangedSubviews:@[
                _titleLabel, _subtitleLabel
            ]];
        labels.translatesAutoresizingMaskIntoConstraints = NO;
        labels.axis = UILayoutConstraintAxisVertical;
        labels.spacing = 3.0;
        [self.contentView addSubview:labels];

        [NSLayoutConstraint activateConstraints:@[
            [_symbolView.leadingAnchor
                constraintEqualToAnchor:self.contentView.layoutMarginsGuide.leadingAnchor],
            [_symbolView.centerYAnchor
                constraintEqualToAnchor:self.contentView.centerYAnchor],
            [_symbolView.widthAnchor constraintEqualToConstant:34.0],
            [_symbolView.heightAnchor constraintEqualToConstant:34.0],
            [labels.leadingAnchor
                constraintEqualToAnchor:_symbolView.trailingAnchor
                               constant:12.0],
            [labels.trailingAnchor
                constraintEqualToAnchor:self.contentView.layoutMarginsGuide.trailingAnchor],
            [labels.topAnchor
                constraintGreaterThanOrEqualToAnchor:self.contentView.topAnchor
                                             constant:11.0],
            [labels.bottomAnchor
                constraintLessThanOrEqualToAnchor:self.contentView.bottomAnchor
                                          constant:-11.0],
            [labels.centerYAnchor
                constraintEqualToAnchor:self.contentView.centerYAnchor]
        ]];
    }
    return self;
}

- (void)configureWithTitle:(NSString *)title
                  subtitle:(NSString *)subtitle
                    symbol:(NSString *)symbol
                 tintColor:(UIColor *)tintColor
             accessoryView:(UIView *)accessoryView
              accessoryType:(UITableViewCellAccessoryType)accessoryType {
    _titleLabel.text = title;
    _subtitleLabel.text = subtitle;
    _symbolView.backgroundColor = tintColor;
    _symbolView.image = [UIImage systemImageNamed:symbol] ?:
        [UIImage systemImageNamed:@"gearshape.fill"];
    self.accessoryView = accessoryView;
    self.accessoryType = accessoryType;
}

@end

@interface PPListController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *settingsTableView;
@property (nonatomic, copy) NSArray<NSArray<NSDictionary<NSString *, id> *> *> *sections;
@end

@implementation PPListController

- (void)loadView {
    UITableView *tableView =
        [[UITableView alloc] initWithFrame:CGRectZero
                                     style:UITableViewStyleInsetGrouped];
    tableView.backgroundColor = UIColor.systemGroupedBackgroundColor;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 68.0;
    tableView.separatorInset = UIEdgeInsetsMake(0.0, 58.0, 0.0, 0.0);
    [tableView registerClass:PPPreferenceCell.class
      forCellReuseIdentifier:@"PPPreferenceCell"];

    self.settingsTableView = tableView;
    self.view = tableView;
    self.title = @"PerformancePlus";
    self.navigationItem.largeTitleDisplayMode =
        UINavigationItemLargeTitleDisplayModeAlways;
    [self rebuildSections];
}

- (NSDictionary<NSString *, id> *)rowWithTitle:(NSString *)title
                                      subtitle:(NSString *)subtitle
                                        symbol:(NSString *)symbol
                                         color:(UIColor *)color
                                          kind:(NSString *)kind {
    return @{
        @"title": title,
        @"subtitle": subtitle,
        @"symbol": symbol,
        @"color": color,
        @"kind": kind
    };
}

- (NSDictionary<NSString *, id> *)switchRowWithTitle:(NSString *)title
                                             subtitle:(NSString *)subtitle
                                               symbol:(NSString *)symbol
                                                color:(UIColor *)color
                                                  key:(NSString *)key {
    NSMutableDictionary<NSString *, id> *row = [[self
        rowWithTitle:title
            subtitle:subtitle
              symbol:symbol
               color:color
                kind:@"switch"] mutableCopy];
    row[@"key"] = key;
    return row;
}

- (void)rebuildSections {
    PPManager *manager = PPManager.sharedManager;
    self.sections = @[
        @[
            [self switchRowWithTitle:@"Enable PerformancePlus"
                            subtitle:@"Stores your preference without changing iOS thermal or kernel controls."
                              symbol:@"bolt.fill"
                               color:UIColor.systemBlueColor
                                 key:@"enabled"],
            [self switchRowWithTitle:@"Performance Mode"
                            subtitle:@"Userspace preference only; iOS continues to manage CPU scheduling."
                              symbol:@"speedometer"
                               color:UIColor.systemOrangeColor
                                 key:@"performanceMode"],
            [self switchRowWithTitle:@"Memory Optimization"
                            subtitle:@"Preference only; this does not purge memory or alter kernel behavior."
                              symbol:@"memorychip.fill"
                               color:UIColor.systemPurpleColor
                                 key:@"memoryOptimization"],
            [self switchRowWithTitle:@"App Launch Optimization"
                            subtitle:@"Preference only; system app-launch scheduling is unchanged."
                              symbol:@"arrow.up.forward.app.fill"
                               color:UIColor.systemGreenColor
                                 key:@"appLaunchOptimization"]
        ],
        @[
            [self rowWithTitle:@"CPU Information"
                      subtitle:manager.cpuStatus
                        symbol:@"cpu"
                         color:UIColor.systemRedColor
                          kind:@"device-cpu"],
            [self rowWithTitle:@"Memory Information"
                      subtitle:manager.memoryStatus
                        symbol:@"memorychip"
                         color:UIColor.systemPurpleColor
                          kind:@"device-memory"],
            [self rowWithTitle:@"Battery Information"
                      subtitle:manager.batteryStatus
                        symbol:@"battery.100percent"
                         color:UIColor.systemGreenColor
                          kind:@"device-battery"],
            [self rowWithTitle:@"iOS Version"
                      subtitle:manager.systemVersion
                        symbol:@"gear"
                         color:UIColor.systemGrayColor
                          kind:@"device-ios"],
            [self rowWithTitle:@"Device Model"
                      subtitle:manager.deviceModel
                        symbol:@"iphone"
                         color:UIColor.systemTealColor
                          kind:@"device-model"]
        ],
        @[
            [self rowWithTitle:@"Loaded Tweak Status"
                      subtitle:manager.loadedTweakStatus
                        symbol:@"square.stack.3d.up.fill"
                         color:UIColor.systemBlueColor
                          kind:@"status-loaded"],
            [self rowWithTitle:@"Possible Conflicts"
                      subtitle:manager.possibleConflictStatus
                        symbol:@"exclamationmark.triangle.fill"
                         color:UIColor.systemOrangeColor
                          kind:@"status-conflicts"],
            [self rowWithTitle:@"Installed Tweak Count"
                      subtitle:manager.installedTweakCountStatus
                        symbol:@"shippingbox.fill"
                         color:UIColor.systemIndigoColor
                          kind:@"status-count"],
            [self rowWithTitle:@"Refresh Status"
                      subtitle:@"Update device and tweak status information."
                        symbol:@"arrow.clockwise"
                         color:UIColor.systemCyanColor
                          kind:@"refresh"]
        ],
        @[
            [self rowWithTitle:@"Respring"
                      subtitle:@"Restart SpringBoard to reload injected tweaks."
                        symbol:@"arrow.triangle.2.circlepath"
                         color:UIColor.systemRedColor
                          kind:@"respring"],
            [self rowWithTitle:@"Reload Preferences"
                      subtitle:@"Refresh the values shown on this page."
                        symbol:@"slider.horizontal.3"
                         color:UIColor.systemGrayColor
                          kind:@"refresh"]
        ],
        @[
            [self rowWithTitle:@"PerformancePlus"
                      subtitle:@"Performance and system status controls"
                        symbol:@"bolt.fill"
                         color:UIColor.systemBlueColor
                          kind:@"about"],
            [self rowWithTitle:@"Version"
                      subtitle:@"1.0.0"
                        symbol:@"number"
                         color:UIColor.systemGrayColor
                          kind:@"about"],
            [self rowWithTitle:@"Developer"
                      subtitle:@"Blue"
                        symbol:@"person.fill"
                         color:UIColor.systemIndigoColor
                          kind:@"about"],
            [self rowWithTitle:@"GitHub"
                      subtitle:@"View source and report issues"
                        symbol:@"chevron.left.forwardslash.chevron.right"
                         color:UIColor.systemGrayColor
                          kind:@"github"]
        ]
    ];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.sections[section].count;
}

- (NSString *)tableView:(UITableView *)tableView
    titleForHeaderInSection:(NSInteger)section {
    NSArray<NSString *> *titles = @[
        @"PERFORMANCE",
        @"DEVICE STATUS",
        @"TWEAK STATUS",
        @"ACTIONS",
        @"ABOUT"
    ];
    return titles[section];
}

- (UIView *)tableView:(UITableView *)tableView
    viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    label.adjustsFontForContentSizeCategory = YES;
    label.textColor = UIColor.secondaryLabelColor;
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForHeaderInSection:(NSInteger)section {
    return 42.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary<NSString *, id> *row = self.sections[indexPath.section][indexPath.row];
    PPPreferenceCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"PPPreferenceCell"
                                        forIndexPath:indexPath];
    NSString *key = row[@"key"];
    NSString *kind = row[@"kind"];
    UIView *accessoryView = nil;
    UITableViewCellAccessoryType accessoryType =
        UITableViewCellAccessoryNone;

    if ([kind isEqualToString:@"switch"]) {
        UISwitch *toggle = [[UISwitch alloc] initWithFrame:CGRectZero];
        toggle.on = [key isEqualToString:@"enabled"]
            ? PPManager.sharedManager.isEnabled
            : [PPManager.sharedManager isOptionEnabled:key];
        toggle.accessibilityLabel = row[@"title"];
        toggle.accessibilityIdentifier = key;
        [toggle addTarget:self
                   action:@selector(switchValueChanged:)
         forControlEvents:UIControlEventValueChanged];
        accessoryView = toggle;
    } else if ([kind hasPrefix:@"device-"] ||
               [kind hasPrefix:@"status-"] ||
               [kind isEqualToString:@"respring"] ||
               [kind isEqualToString:@"github"]) {
        accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    [cell configureWithTitle:row[@"title"]
                    subtitle:row[@"subtitle"]
                      symbol:row[@"symbol"]
                   tintColor:row[@"color"]
                accessoryView:accessoryView
             accessoryType:accessoryType];
    return cell;
}

- (void)switchValueChanged:(UISwitch *)toggle {
    NSString *key = toggle.accessibilityIdentifier;
    if ([key isEqualToString:@"enabled"]) {
        [PPManager.sharedManager setEnabled:toggle.isOn];
    } else {
        [PPManager.sharedManager setOption:key enabled:toggle.isOn];
    }
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary<NSString *, id> *row = self.sections[indexPath.section][indexPath.row];
    [self performActionForRow:row];
}

- (void)performActionForRow:(NSDictionary<NSString *, id> *)row {
    NSString *kind = row[@"kind"];
    if ([kind isEqualToString:@"switch"]) {
        return;
    }

    if ([kind isEqualToString:@"refresh"]) {
        [self rebuildSections];
        [self.settingsTableView reloadData];
        return;
    }

    if ([kind isEqualToString:@"github"]) {
        NSURL *url = [NSURL URLWithString:@"https://github.com/Minhnhatz/PerformancePlus"];
        [UIApplication.sharedApplication openURL:url
                                         options:@{}
                               completionHandler:^(BOOL success) {
            if (!success) {
                [self showMessage:@"Unable to Open GitHub"
                          message:@"The GitHub page could not be opened."];
            }
        }];
        return;
    }

    if ([kind isEqualToString:@"respring"]) {
        UIAlertController *confirmation =
            [UIAlertController alertControllerWithTitle:@"Respring"
                                                message:@"Restart SpringBoard now?"
                                         preferredStyle:UIAlertControllerStyleAlert];
        [confirmation addAction:
            [UIAlertAction actionWithTitle:@"Cancel"
                                     style:UIAlertActionStyleCancel
                                   handler:nil]];
        [confirmation addAction:
            [UIAlertAction actionWithTitle:@"Respring"
                                     style:UIAlertActionStyleDestructive
                                   handler:^(__unused UIAlertAction *action) {
            [self respring];
        }]];
        [self presentViewController:confirmation animated:YES completion:nil];
        return;
    }

    [self showDetailsForRow:row];
}

- (void)showDetailsForRow:(NSDictionary<NSString *, id> *)row {
    NSString *kind = row[@"kind"];
    PPManager *manager = PPManager.sharedManager;
    NSString *message = row[@"subtitle"];

    if ([kind isEqualToString:@"device-cpu"]) {
        message = [NSString stringWithFormat:@"%@\nNo hardware performance controls are changed.",
                   manager.cpuStatus];
    } else if ([kind isEqualToString:@"device-memory"]) {
        message = [NSString stringWithFormat:@"%@\nMemory values are read-only estimates.",
                   manager.memoryStatus];
    } else if ([kind isEqualToString:@"device-battery"]) {
        message = [NSString stringWithFormat:@"%@\nThermal state: %@\nPower mode: %@",
                   manager.batteryStatus,
                   manager.thermalStatus,
                   manager.powerStatus];
    } else if ([kind isEqualToString:@"device-ios"]) {
        message = manager.systemVersion;
    } else if ([kind isEqualToString:@"device-model"]) {
        message = manager.deviceModel;
    } else if ([kind isEqualToString:@"status-loaded"]) {
        message = @"Unable to determine which tweaks are loaded system-wide from this preference page.";
    } else if ([kind isEqualToString:@"status-conflicts"]) {
        message = @"Unable to determine. No tweak is reported as conflicting without verifiable evidence.";
    } else if ([kind isEqualToString:@"status-count"]) {
        message = [NSString stringWithFormat:
                   @"%@\nThis counts dynamic libraries, not package-manager records.",
                   manager.installedTweakCountStatus];
    }

    [self showMessage:row[@"title"] message:message];
}

- (void)respring {
    pid_t process = 0;
    char *arguments[] = {
        "/usr/bin/killall",
        "-9",
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
