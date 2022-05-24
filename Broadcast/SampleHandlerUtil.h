//
//  SampleHandlerUtil.h
//  Broadcast
//
//  Created by Thomas Woodfin twoodfin@berkeley.edu on 05/22/2022.
//

#import <Foundation/Foundation.h>
#import <ReplayKit/ReplayKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SampleHandlerUtil : NSObject
+ (void)finishBroadcastWithNilError:(nullable RPBroadcastSampleHandler *)sampleHandler;
@end

NS_ASSUME_NONNULL_END
