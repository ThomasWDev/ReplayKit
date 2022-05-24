//
//  SampleHandlerUtil.m
//  Broadcast
//
//  Created by Thomas Woodfin twoodfin@berkeley.edu on 05/22/2022.
//

#import "SampleHandlerUtil.h"

@implementation SampleHandlerUtil
+ (void)finishBroadcastWithNilError:(nullable RPBroadcastSampleHandler *)sampleHandler {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    [sampleHandler finishBroadcastWithError:nil];
#pragma clang diagnostic pop
}
@end
