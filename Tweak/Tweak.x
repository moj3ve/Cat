#import "Cat.h"

void playClickSound() {

    if (playWhenMutedSwitch) {
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:@"/System/Library/Audio/UISounds/key_press_click.caf"] error:nil];

    }

    int soundLevel = [soundFileControl intValue];

    if (customSoundSwitch && soundLevel == 0) {
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:@"/Library/Cat/iOS6.caf"] error:nil];

    } else if (customSoundSwitch && soundLevel == 1) {
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:@"/Library/Cat/NintendoSwitch.caf"] error:nil];

    } else if (customSoundSwitch && soundLevel == 2) {
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:@"/Library/Cat/DoodleJump.caf"] error:nil];

    }

    player.numberOfLoops = 0;
    player.volume = 1;
    [player play];

}

%group Cat

%hook SBRingerControl

- (BOOL)isRingerMuted { // This would be useful if it worked, unfortunately when you check if the RingerMuted is YES nothing happens

    RingerMuted = %orig;

    return %orig;

}

%end

%hook UIKeyboardLayoutStar

- (void)playKeyClickSoundOnDownForKey:(UIKBTree *)key {

    if (enabled && playWhenMutedSwitch && !customSoundSwitch) {
        playClickSound();

    } else if (enabled && customSoundSwitch) {
        playClickSound();

    } else if (enabled && !playWhenMutedSwitch && !customSoundSwitch) {
        %orig;

    } else {
        %orig;

    }

}

%end

%end

%group CatIntegrityFail

%hook SBCoverSheetPrimarySlidingViewController

- (void)viewDidDisappear:(BOOL)arg1 {

    %orig; //  Thanks to Nepeta for the DRM
    if (!dpkgInvalid) return;
		UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Cat"
		message:@"Seriously? Pirating a free Tweak is awful!\nPiracy repo's Tweaks could contain Malware if you didn't know that, so go ahead and get Cat from the official Source https://repo.shymemoriees.me/.\nIf you're seeing this but you got it from the official source then make sure to add https://repo.shymemoriees.me to Cydia or Sileo."
		preferredStyle:UIAlertControllerStyleAlert];

		UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Aww man" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {

			UIApplication *application = [UIApplication sharedApplication];
			[application openURL:[NSURL URLWithString:@"https://repo.shymemoriees.me/"] options:@{} completionHandler:nil];

	}];

		[alertController addAction:cancelAction];

		[self presentViewController:alertController animated:YES completion:nil];

}

%end

%end

%ctor {

    if (![NSProcessInfo processInfo]) return;
    NSString *processName = [NSProcessInfo processInfo].processName;
    bool isSpringboard = [@"SpringBoard" isEqualToString:processName];

    // Someone smarter than Nepeta invented this.
    // https://www.reddit.com/r/jailbreak/comments/4yz5v5/questionremote_messages_not_enabling/d6rlh88/
    bool shouldLoad = NO;
    NSArray *args = [[NSClassFromString(@"NSProcessInfo") processInfo] arguments];
    NSUInteger count = args.count;
    if (count != 0) {
        NSString *executablePath = args[0];
        if (executablePath) {
            NSString *processName = [executablePath lastPathComponent];
            BOOL isApplication = [executablePath rangeOfString:@"/Application/"].location != NSNotFound || [executablePath rangeOfString:@"/Applications/"].location != NSNotFound;
            BOOL isFileProvider = [[processName lowercaseString] rangeOfString:@"fileprovider"].location != NSNotFound;
            BOOL skip = [processName isEqualToString:@"AdSheet"]
                        || [processName isEqualToString:@"CoreAuthUI"]
                        || [processName isEqualToString:@"InCallService"]
                        || [processName isEqualToString:@"MessagesNotificationViewService"]
                        || [executablePath rangeOfString:@".appex/"].location != NSNotFound;
            if ((!isFileProvider && isApplication && !skip) || isSpringboard) {
                shouldLoad = YES;
            }
        }
    }

    if (!shouldLoad) return;
  
    // Thanks To Nepeta For The DRM
    dpkgInvalid = ![[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/me.shymemoriees.cat.list"];

    if (!dpkgInvalid) dpkgInvalid = ![[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/me.shymemoriees.cat.md5sums"];

    if (dpkgInvalid) {
        %init(CatIntegrityFail);
        return;
    }

  pfs = [[HBPreferences alloc] initWithIdentifier:@"me.shymemoriees.catpreferences"];
  // Enable Switch
  [pfs registerBool:&enabled default:YES forKey:@"Enabled"];
  // Option Switches
  [pfs registerBool:&playWhenMutedSwitch default:YES forKey:@"playWhenMuted"];
  // Sound File Selector
  [pfs registerBool:&customSoundSwitch default:NO forKey:@"customSoundSwitch"];
  [pfs registerObject:&soundFileControl default:@"0" forKey:@"soundFile"];

	if (!dpkgInvalid && enabled) {
        BOOL ok = false;
        
        ok = ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/var/lib/dpkg/info/%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@.cat.md5sums", @"m", @"e", @".", @"s", @"h", @"y", @"m", @"e", @"m", @"o", @"r", @"i", @"e", @"e", @"s"]]
        );

        if (ok && [@"shymemoriees" isEqualToString:@"shymemoriees"]) {
            %init(Cat);
            return;
        } else {
            dpkgInvalid = YES;
        }
    }
}