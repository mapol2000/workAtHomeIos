//
//  cryptoUtils.m
//  TouchEnAppIronDemo
//
//  Created by 김평구 on 10/14/24.
//

#import "cryptoUtils.h"
#import "KISA_SEED_ECB.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation cryptoUtils
+(NSData *) decryt: (NSData *) data {
    
    // 데이터 사이즈
    NSUInteger size = [data length] / sizeof(unsigned char);
    
    // data -> unsigned char array
    unsigned char pbData[data.length];
    [data getBytes:pbData length:data.length];
    
    
    
    // 약속된 키 생성 로직
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSDate *date = [NSDate new];
    NSString *currentDate = [dateFormatter stringFromDate:date];
    NSString *plus = [NSString stringWithFormat:@"%@%@", currentDate, [[NSBundle mainBundle] bundleIdentifier]];
    
    // pbUserKey = 키
    const char *cStr = [plus UTF8String];
    unsigned char pbUserKey[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), pbUserKey ); // This is the md5 call
    
    // pdwRoundKey = 라운드 키
    unsigned long pdwRoundKey[32];
    
    // Derive roundkeys from user secret key
    SEED_KeySchedKey(
                     pdwRoundKey,
                     pbUserKey);
    // Decryption
    SEED_Decrypt_ECB(
                     pbData,
                     pdwRoundKey);
    NSData* decryptedData = [NSData dataWithBytes:(const void *)pbData length:sizeof(unsigned char)*size];

    return decryptedData;
}
@end
