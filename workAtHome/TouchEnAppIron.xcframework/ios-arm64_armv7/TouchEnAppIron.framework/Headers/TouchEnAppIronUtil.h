//
//  TouchEnAppIronUtil.h
//  TouchEnAppIron
//
//  Created by Joseph Cha on 2022/01/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TouchEnAppIronUtil : NSObject
+(NSData *) getDevice: (NSData *) data;
+(NSData *) encryptSeed: (NSData *) jsonData;
+(NSString *) decryptSeed: (NSData *) resultData;
@end

NS_ASSUME_NONNULL_END
