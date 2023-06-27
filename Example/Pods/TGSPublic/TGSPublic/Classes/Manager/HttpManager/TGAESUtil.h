//
//  TGAESUtil.h
//  HuaRenComic
//
//  Created by luo luo on 2022/1/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TGAESUtil : NSObject
#pragma mark - AES加密
//将string转成带密码的data
+(NSString*)encryptAESData:(NSString*)string;
//将带密码的data转成string
+(NSString*)decryptAESData:(NSString *)string;

@end

@interface NSData (TGAesData)
- (NSData *)AES128EncryptWithKey:(NSString *)key gIv:(NSString *)Iv;
- (NSData *)AES128DecryptWithKey:(NSString *)key gIv:(NSString *)Iv;

@end

NS_ASSUME_NONNULL_END
