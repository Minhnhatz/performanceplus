#import <UIKit/UIKit.h>
#import "PPManager.h"

%ctor {
    @autoreleasepool {
        [[PPManager sharedManager] start];
    }
}
