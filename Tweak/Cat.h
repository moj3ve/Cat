#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Cephei/HBPreferences.h>

// Utils
HBPreferences *pfs;

// Thanks to Nepeta for the DRM
BOOL dpkgInvalid = NO;

// Option Switches
BOOL enabled = YES;
BOOL playWhenMutedSwitch = YES;
// Keyboard Sound File
BOOL customSoundSwitch = NO;
NSString* soundFileControl = @"0";
// Check if the devices is muted
BOOL RingerMuted;
// Player to play the sound
AVAudioPlayer *player;

// Interfaces
@interface UIKBTree : NSObject
@property (nonatomic, strong, readwrite) NSString * name;
+ (id)sharedInstance;
+ (id)key;
@end

@interface SBCoverSheetPrimarySlidingViewController : UIViewController
- (void)viewDidDisappear:(BOOL)arg1;
@end