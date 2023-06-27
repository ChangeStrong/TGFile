//
//  String+Comm.swift
//  SwiftFrameworkDemo
//
//  Created by gleeeli on 2020/8/3.
//  Copyright © 2020 GL. All rights reserved.
//

import Foundation
let KUrlCodingReservedCharacters = "!*'();:|@&=+$,/?%#[]{}"
public extension String{
    /// url编码
    ///
    /// - Returns: NSString
   public func urlEncode() -> String? {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: KUrlCodingReservedCharacters).inverted)
        
    }
    
    func urlEncodeOnlyUTF8() -> String? {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "").inverted)! 
        
    }
    
    /// url解码
    ///
    /// - Returns: NSString
    func urlDecode() -> NSString? {
        return self.removingPercentEncoding as NSString?
    }
    
    //GBK()转UTF16字符串
    //let gbkData = text.data(using: String.Encoding.isoLatin1)
  static func conventGBKToUTF16(_ gbkData:Data) -> String? {
        //获取GBK编码, 使用GB18030是因为它向下兼容GBK
        let cfEncoding = CFStringEncodings.GB_18030_2000
        let encoding2 = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEncoding.rawValue))
        //从GBK编码的Data里初始化NSString, 返回的NSString是UTF-16编码(即OC默认的编码)
        if let str = NSString(data: gbkData, encoding: encoding2) {
           return str as String
        } else {
            LLog(TAG: TAG(self), "gbk to utf16 failture.!");
            return nil
        }
    }
    
    static func isNull(str:String?) -> Bool {
        if str == nil {
            return true
        }
        if str!.isEmpty {
            return true;
        }
        if str == "<null>" {
            return true;
        }
        return false;
    }
    
    func appendingPathComponent2(_ temp:String) -> String {
        return self + "/" + temp;
    }
    //移除首个目录
    func removeFirstComponent2() -> String? {
        var temps = self.split(separator: "/")
        
        if temps.count == 0 {
            LLog(TAG: TAG(self), "not contain any other character.!");
            return nil
        }
        temps.removeFirst();
        let tempStr =  temps.joined(separator: "/")
          return tempStr;
    }
    
    func removeLastComponent2() -> String? {
        var temps = self.split(separator: "/")
        if temps.count == 0 {
            LLog(TAG: TAG(self), "not contain any other character.!");
            return nil
        }
        temps.removeLast();
        var tempStr =  temps.joined(separator: "/")
        if self.hasPrefix("/") && tempStr.hasPrefix("/")==false{
            //解决路径最前面是/问题
            tempStr = "/"+tempStr;
        }
     
        return tempStr;
    }
    //获取路径最后的 文件名或者文件夹名
    func fetchLastComponent2() -> String {
        let temps = self.split(separator: "/")
        if temps.count == 0 {
            LLog(TAG: TAG(self), "not contain any other character.!");
            return self
        }
        return String(temps.last!);
    }
    
    func fetchFirstComponent2() -> String? {
        var temps = self.split(separator: "/")
        if temps.count == 0 {
            LLog(TAG: TAG(self), "not contain any other character.!");
            return nil
        }
       return String(temps.first!)
    }
    
    func fetchFileSuffix() -> String {
        let tempStr:String = self.fetchLastComponent2();
        if tempStr.contains(".") == false {
            return ""
        }
        let array2 = tempStr.split(separator: ".")
        if array2.count == 0 {
            //是文件夹没有.
            return "";
        }
        return "\(array2.last!)"
    }
    
    /**
          匹配字符串中所有的URL
          */
      func  getUrls() -> [ String ] {
             var  urls = [ String ]()
             // 创建一个正则表达式对象
             do {
                 let  dataDetector = try  NSDataDetector (types:
                                                            NSTextCheckingTypes ( NSTextCheckingResult.CheckingType . link .rawValue))
                 // 匹配字符串，返回结果集
                 let  res = dataDetector.matches(in: self,
                                                 options:  NSRegularExpression.MatchingOptions (rawValue: 0),
                     range:  NSMakeRange (0, self.count))
                 // 取出结果
                 for  checkingRes  in  res {
                     urls.append((self  as  NSString ).substring(with: checkingRes.range))
                 }
             }
             catch {
                 print (error)
             }
             return  urls
         }
    
    //是否是纯Int类型数据
    static func isPurnInt(string: String) -> Bool {
           let scan: Scanner = Scanner(string: string)
           var val:Int = 0
           return scan.scanInt(&val) && scan.isAtEnd
    
       }
    
    
}

public extension String {
    func toNSRange(_ range: Range<String.Index>) -> NSRange {
        guard let from = range.lowerBound.samePosition(in: utf16), let to = range.upperBound.samePosition(in: utf16) else {
            return NSMakeRange(0, 0)
        }
        return NSMakeRange(utf16.distance(from: utf16.startIndex, to: from), utf16.distance(from: from, to: to))
    }
    
    func toRange(_ range: NSRange) -> Range<String.Index>? {
        guard let from16 = utf16.index(utf16.startIndex, offsetBy: range.location, limitedBy: utf16.endIndex) else { return nil }
        guard let to16 = utf16.index(from16, offsetBy: range.length, limitedBy: utf16.endIndex) else { return nil }
        guard let from = String.Index(from16, within: self) else { return nil }
        guard let to = String.Index(to16, within: self) else { return nil }
        return from ..< to
    }
}
