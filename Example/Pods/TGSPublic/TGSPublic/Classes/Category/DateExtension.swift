//
//  DateExtension.swift
//  ComicChatSwift
//
//  Created by luo luo on 2020/4/20.
//  Copyright © 2020 GL. All rights reserved.
//

import Foundation


public typealias DateExtension = Date
public extension DateExtension{
    
    enum TGWeekDay:Int {
        case Sunday = 1
        case Monday = 2
        case Tuesday = 3
        case Wednesday = 4
        case Thursday = 5
        case Friday = 6
        case Saturday = 7
    }
    
    func date(withFormat format: String?) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    /// 日期字符串转化为Date类型
      ///
      /// - Parameters:
      ///   - string: 日期字符串
      ///   - dateFormat: 格式化样式，默认为“yyyy-MM-dd HH:mm:ss”
      /// - Returns: Date类型
      static func stringConvertDate(_ string:String, _ dateFormat:String="yyyy-MM-dd HH:mm:ss") -> Date {
          let dateFormatter = DateFormatter.init()
          dateFormatter.dateFormat = dateFormat
          let date = dateFormatter.date(from: string)
          return date!
      }
    
    //获取凌晨格式化的时间
    func getZeroFormatTimeTimeBy() ->  String {
        //现在的代码会是：
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        return "\(year)-\(month)-\(day)"
    }
    
    
    func getCurrentWeekDay() ->Int{
        
        guard let calendar = NSCalendar(identifier: NSCalendar.Identifier.gregorian) else {
            LLog(TAG: "Date- ", "get calendar is error.!")
            return 0
        }
        let components = calendar.components([.weekOfYear,.weekOfMonth,.weekday,.weekdayOrdinal], from: self)
        //今年的第几周
        //        let weekOfYear = components.weekOfYear!
        //这个月第几周
        //        let weekOfMonth = components.weekOfMonth!
        //周几
        let weekday = components.weekday!
        //这个月第几周
        //        let weekdayOrdinal = components.weekdayOrdinal!
        //        print(weekOfYear)
        //        print(weekOfMonth)
        
        //        print(weekdayOrdinal)
        //return "第\(components.weekOfYear!)周";
        return weekday
    }
    
    func getCurrentWeekDayStr() -> String {
        let weekDays:[String] = ["无","周日","周一","周二","周三","周四","周五","周六"]
        let index = self.getCurrentWeekDay()
        //         print("weekday:\(weekDays[index])")
        if index < weekDays.count && index >= 0 {
            return weekDays[index]
        }
        print("Date- get week day str error.!!")
        return ""
    }
    
    func formatSimpleExpress() -> String{
        let currentDate:Date = Date();
        var timeInterval:TimeInterval = currentDate.timeIntervalSince(self);
        //毫秒转为秒
//        LLog(TAG: TAG(self), "timeInterval=\(timeInterval)");
        var result:String = ""
        var temp:Double = 0
        if timeInterval/60 < 1 {
            result = "刚刚"
            
        }else if (timeInterval/60) < 60{
            temp = timeInterval/60
            result = "\(Int(temp))分钟前"
        }else if timeInterval/(60 * 60) < 24 {
            
            temp = timeInterval/(60*60)
            result = "\(Int(temp))小时前"
            
        }else if timeInterval/(24 * 60 * 60) < 30  {
            
            temp = timeInterval / (24 * 60 * 60)
            result = "\(Int(temp))天前"
            
        }else if timeInterval/(30 * 24 * 60 * 60)  < 12 {
            
            temp = timeInterval/(30 * 24 * 60 * 60)
            result = "\(Int(temp))个月前"
            
        }else{
            temp = timeInterval/(12 * 30 * 24 * 60 * 60)
            result = "\(Int(temp))年前"
        }
        return result
    }
    
    func distanceNowTime() -> String {
        let currentDate:Date = Date();
        let timeInterval:TimeInterval = self.timeIntervalSince(currentDate);
        var result:String = ""
        var temp:Double = 0
        if timeInterval/60 < 1 {
            result = "The End".localized
            
        }else if (timeInterval/60) < 60{
            temp = timeInterval/60
            result = String.init(format: "after %.0f minute end".localized, temp) //"在\(Int(temp))分钟结束"
            
        }else if timeInterval/(60 * 60) < 24 {
            
            temp = timeInterval/(60*60)
            result = String.init(format: "after %.1f hours end".localized, temp) // "在\(Int(temp))小时后结束"
            
        }else if timeInterval/(24 * 60 * 60) < 30  {
            
            temp = timeInterval / (24 * 60 * 60)
            result =  String.init(format: "after %.1f days end".localized, temp) //"after \(Int(temp)) days end"
            
        }else if timeInterval/(30 * 24 * 60 * 60)  < 12 {
            
            temp = timeInterval/(30 * 24 * 60 * 60)
            result = String.init(format: "after %.1f month end".localized, temp) //"after \(Int(temp)) month end"
            
        }else{
            temp = timeInterval/(12 * 30 * 24 * 60 * 60)
            result = String.init(format: "after %.1f year end".localized, temp) //"after \(Int(temp)) year end"
        }
        return result
    }
    
    //获取当前距离1970的秒数
    static func fetchCurrentSeconds() -> Int {
       return Int(Date().timeIntervalSince1970)
    }
    
    
}
