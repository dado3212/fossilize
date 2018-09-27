#include "Secret.h"

#define kCBMsgArgCharacteristicHandle @"kCBMsgArgCharacteristicHandle"
#define kCBMsgArgData @"kCBMsgArgData"

NSString *lastCarTriggered = [[NSString alloc] init];
NSString *lastRingTriggered = [[NSString alloc] init];

NSString *toHexString(NSData *data) {
  const unsigned char *dataBuffer = (const unsigned char *)[data bytes];

  int dataLength = [data length];
  NSMutableString *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];

  for (int i = 0; i < dataLength; i++) {
    [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
  }

  return [[NSString alloc] initWithFormat:@"%@", hexString];
}

%hook CBPeripheral
- (void)handleCharacteristicValueUpdated:(id)arg1 {
  if ([[arg1 objectForKey:kCBMsgArgCharacteristicHandle] intValue] == 526) {
    NSString *argData = toHexString([arg1 objectForKey:kCBMsgArgData]);

    if ([argData length] >= 8 && [[argData substringWithRange:NSMakeRange(2, 6)] isEqualToString:@"e10102"]) {
      NSString *shortened = [argData substringFromIndex:2];
      if (![shortened isEqualToString:lastCarTriggered]) {
        [Secret goodNight]; // or whatever you want to run
        [lastCarTriggered release];
        lastCarTriggered = [[NSString alloc] initWithFormat:@"%@", shortened];
      }
      return;
    } else if ([argData length] >= 8 && [[argData substringWithRange:NSMakeRange(2, 6)] isEqualToString:@"e10101"]) {
      NSString *shortened = [argData substringFromIndex:2];
      if (![shortened isEqualToString:lastRingTriggered]) {
        [Secret goodMorning]; // or whatever you want to run
        [lastRingTriggered release];
        lastRingTriggered = [[NSString alloc] initWithFormat:@"%@", shortened];
      }
      return;
    }
  }
  return %orig;
}
%end