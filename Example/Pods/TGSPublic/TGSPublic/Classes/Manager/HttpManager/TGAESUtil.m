//
//  TGAESUtil.m
//  HuaRenComic
//
//  Created by luo luo on 2022/1/28.
//

#import "TGAESUtil.h"
#import <CommonCrypto/CommonCryptor.h>
static  NSString * const AesKey = @"KeyRTYUIOPASDFGH";
static  NSString * const AesIv = @"IvZWSXEDCRFVTGBY";
@implementation TGAESUtil
//将string转成带密码的data
+(NSString*)encryptAESData:(NSString*)string
{
    //将nsstring转化为nsdata
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    //使用密码对nsdata进行加密
    NSData *encryptedData = [data AES128EncryptWithKey:AesKey gIv:AesIv];
    //返回进行base64进行转码的加密字符串
    
    NSString *base64Str = [encryptedData base64EncodedStringWithOptions:0];
    return base64Str;
}

#pragma mark - AES解密
//将带密码的data转成string
+(NSString*)decryptAESData:(NSString *)string
{
   //base64解密
   NSData *decodeBase64Data=[[NSData alloc]initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
   //使用密码对data进行解密
   NSData *decryData = [decodeBase64Data AES128DecryptWithKey:AesKey gIv:AesIv];
   //将解了密码的nsdata转化为nsstring
   NSString *str = [[NSString alloc] initWithData:decryData encoding:NSUTF8StringEncoding];
   return str;
}

@end

@implementation NSData (TGAesData)
//(key和iv向量这里是16位的) 这里是CBC加密模式，安全性更高
- (NSData *)AES128EncryptWithKey:(NSString *)key gIv:(NSString *)Iv{//加密
    char keyPtr[kCCKeySizeAES128+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCKeySizeAES128+1];
    memset(ivPtr, 0, sizeof(ivPtr));
    [Iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,//kCCOptionPKCS7Padding
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          ivPtr,
                                          [self bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return nil;
}

//AES解密
- (NSData *)AES128DecryptWithKey:(NSString *)key gIv:(NSString *)Iv {
    char keyPtr[kCCKeySizeAES128+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCKeySizeAES128+1];
    memset(ivPtr, 0, sizeof(ivPtr));
    [Iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          ivPtr,
                                          [self bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    free(buffer);
    return nil;
}

@end
