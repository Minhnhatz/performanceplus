#import <UIKit/UIKit.h>

@interface PPIconManager : NSObject

+ (UIImage *)imageForTitle:(NSString *)title;
+ (NSString *)iconNameForTitle:(NSString *)title;
+ (UIColor *)accentColorForIconName:(NSString *)iconName;
+ (NSString *)subtitleForTitle:(NSString *)title;

@end
