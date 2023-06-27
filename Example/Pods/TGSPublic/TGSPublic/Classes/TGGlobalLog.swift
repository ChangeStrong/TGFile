//
//  TGGlobalLog.swift
//  SwiftFrameworkDemo
//
//  Created by mac on 2020/6/10.
//  Copyright © 2020 GL. All rights reserved.
//

import Foundation
import UIKit
//打印日志的全局方法
public func TAG(_ temp:Any) -> String{
    return String(describing: type(of: temp))
}

//日志系统
public class TGLog {
    //打印APP基本信息
    public static func printAPPBaseInfo() -> Void {
        LLog(TAG: "\n\n", "AppDelegate- didFinishLaunching...")
        LLog(TAG: "App-", "appversion:\(String(describing: Bundle.main.object(forInfoDictionaryKey:"CFBundleShortVersionString"))) system:\(UIDevice.current.systemVersion) systemModel:\( self.modelName())")
        LLog(TAG: "App-", "remainDiskSize=\(getRemainDiskSize()/1024/1024/1024)GB")
    }
    
    //删除多余的日志
    public static  func deleteRedundantLog(){
        DispatchQueue.global().async {
            //异步删除
            let needDeleteFiles:[String] = getAllCanDeleteFile()
            print("Log- will delete count is \(needDeleteFiles.count)")
            for item in needDeleteFiles {
                var isDir: ObjCBool = true
                if FileManager.default.fileExists(atPath: item, isDirectory: &isDir) {
                    if !isDir.boolValue {
                       //确认是文件 移除
                        do {
                            try FileManager.default.removeItem(atPath: item)
                        } catch  {
                            print("delete file failed.! \(error)")
                        }
                    }
                }
            }
        }
    }
    
      static private func modelName() ->String{
              var systemInfo = utsname()
              uname(&systemInfo)
              let machineMirror = Mirror(reflecting: systemInfo.machine)
              let identifier = machineMirror.children.reduce("") { identifier, element in
                  guard let value = element.value as? Int8, value != 0 else{return identifier }
                  return identifier + String(UnicodeScalar(UInt8(value)))
              }
              return identifier
          }

}
//****日志打印
// MARK: 外部Api
//fileprivate  let TAG: String = "<#content#>"
public var TGisSaveToFile:Bool = true
//保存的日志天数
fileprivate let TGLogDefaultSaveDayCount:Double = 2

public func LLog(TAG :String, _ items: Any...) -> Void {
    let dateformatter = DateFormatter()
    dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss:SSS"
    let timeStr = dateformatter.string(from: Date())
    let logStr:String = "\(timeStr): " + TAG + items.description
    //打印
    print(logStr)
    if TGisSaveToFile {
        if getRemainDiskSize() < 1024 {
            //至少1KB
            print("Log- device available disk size is't enough.")
            return
        }
        //字符串保存到文件路径
        saveLogToPath(content: logStr)
    }
}

public func PrintLog<T>(_ message: T, fileName: String = #file, lineNumber: Int = #line){
    //文件名、方法、行号、打印信息
    print("\((fileName as NSString).lastPathComponent)[\(lineNumber)] : \(message)")
}




// MARK: 内部APi
//日志文件默认路径
let TGLogDirectoryPath = getApplicationSupportURl().appendingPathComponent("LLogDir").path;

fileprivate  func getApplicationSupportURl() -> URL{
    //application support目录
     let applicationSupportURl:URL? = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
    if applicationSupportURl == nil {
        print("Not find applicationSupportDirectory.!!");
        return URL.init(fileURLWithPath: NSHomeDirectory())
    }
    return applicationSupportURl!;
}

//文件名改为以每天时间日志信息
fileprivate func TGgetLogFileName()-> String{
    let dateformatter = DateFormatter()
       dateformatter.dateFormat = "yyyy-MM-dd"
    let timeStr = dateformatter.string(from: Date())
    return "LLog-" + timeStr + ".text"
}

fileprivate func getAllCanDeleteFile() -> [String] {
    var needDeleteFiles:[String] = []
    
    let manager = FileManager.default
        let exist = manager.fileExists(atPath: TGLogDirectoryPath)
        if !exist {
            print("delete failed. no dir.")
            return needDeleteFiles
        }
        let files:[String] = getAllFilePath(TGLogDirectoryPath)!
        
        for item in files {
            
            let fileNameUrl:String? = item.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            if fileNameUrl == nil {
                continue
            }
            let fileName = (fileNameUrl! as NSString).lastPathComponent
            let prefixStr = "LLog-"
            if !fileName.hasPrefix(prefixStr) {
                print("delete failed. no hasPrefix.")
                continue
            }
            let preRange:Range? = fileName.range(of: prefixStr)
            if preRange == nil {
                print("delete failed. no Prefix range.")
                continue
            }
            //移除后缀
            var timeStr = fileName
            timeStr.removeSubrange(preRange!)
            let suffixStr = ".text"
            if !timeStr.hasSuffix(suffixStr) {
                print("delete failed. no hasSuffix.")
                continue
            }
            let subRange:Range? = timeStr.range(of: suffixStr)
            if subRange == nil {
                print("delete failed. no subRange.")
                continue
            }
            timeStr.removeSubrange(subRange!)
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "yyyy-MM-dd"
            let oldDate:Date = dateformatter.date(from: timeStr) ?? Date()
            let current:Date = Date()
    //        print("last=\(dateformatter.string(from: oldDate)) now= \(dateformatter.string(from: current))")
            let interval:TimeInterval = current.timeIntervalSince(oldDate)
            if interval > TGLogDefaultSaveDayCount*24*60*60 {
                //与今天相差默认天数的进行移除
                 needDeleteFiles.append(item)
            }
        }
    return needDeleteFiles
}

fileprivate func getAllFilePath(_ dirPath: String) -> [String]? {
    var filePaths = [String]()
    
    do {
        let array = try FileManager.default.contentsOfDirectory(atPath: dirPath)
        for fileName in array {
            var isDir: ObjCBool = true
            let fullPath = "\(dirPath)/\(fileName)"
            
            if FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDir) {
                if !isDir.boolValue {
                    filePaths.append(fullPath)
                }
            }
        }
        
    } catch let error as NSError {
        print("get file path error: \(error)")
    }
    return filePaths;
}

//将字符串追加到指定文件路径
fileprivate func saveLogToPath(content:String?){
    let path = TGLogDirectoryPath + "/" + TGgetLogFileName()
    let manager = FileManager.default
    let exist = manager.fileExists(atPath: path)
    if !exist
    {
        do{
            //创建指定位置上的文件夹
            try manager.createDirectory(atPath: TGLogDirectoryPath, withIntermediateDirectories: true, attributes: nil)
            print("Succes to create llog folder")
        }
        catch{
            print("Error to create folder")
        }
    }
    do{
        if content == nil {
            return
        }
        let writeStr:String = content! + "\n"
        //            将文本文件写入到指定位置的文本文件，并且使用utf-8的编码方式
        try writeStr.appendToURL(fileURL: URL.init(fileURLWithPath: path))
        //write(toFile: path, atomically: true, encoding: .utf8)
//        print("Success to write a file.\n")
    }catch{
        print("Error to write a file.\n")
    }
    
}

//MARK:- Extension for String
public extension String
{
    func appendLineToURL(fileURL: URL) throws
    {
        try (self + "\n").appendToURL(fileURL: fileURL)
    }
    func appendToURL(fileURL: URL) throws
    {
        let data = self.data(using: String.Encoding.utf8)!
        try data.append(fileURL: fileURL)
    }
}
//MARK:- Extension for File data
public extension Data
{
    //data的追加在某个文件末尾
    func append(fileURL: URL) throws {
        if let fileHandle = FileHandle(forWritingAtPath: fileURL.path)
        {
            defer
            {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        }else
        {
            //文件不存在 直接写成文件
            try write(to: fileURL, options: .atomic)
        }
    }
}


public func getRemainDiskSize() -> Double {
    /// 总大小
//    var totalsize: Double = 0.0
    /// 剩余大小
    var freesize: Double = 0.0
    /// 是否登录
     let error: Error? = nil
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).map { (url) -> String in
        
        return url.path;
    }
//    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).map(\.path)
    var dictionary: [FileAttributeKey : Any]? = nil
    do {
        dictionary = try FileManager.default.attributesOfFileSystem(forPath: paths.last ?? "")
    } catch {
        print("get remain disk size failed.!!")
    }
    if dictionary != nil {
        let _free = dictionary?[.systemFreeSize] as? NSNumber
        //得到B
     freesize = Double(_free?.uint64Value ?? 0) * 1.0 //     / (1024.0)
    
//        let _total = dictionary?[.systemSize] as? NSNumber
//     totalsize = Double(_total?.uint64Value ?? 0) * 1.0 / (1024.0)
//        print(" totalsize \(totalsize / 1024.0 / 1024.0) G,freesize \(freesize / 1024.0 / 1024.0) G")
    } else {
        print(String(format: "Error Obtaining System Memory Info: Domain = %@, Code = %ld", (error as NSError?)?.domain ?? ""))
    }
    return freesize
}

//获取今天日志文件内容
public func TGGetTodayLogFileContent() -> String {
    var content:String = ""
    let path:String = TGLogDirectoryPath + "/" + TGgetLogFileName()
    var isDir: ObjCBool = true
    if FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
        if !isDir.boolValue {
            do {
                let contents = try String(contentsOfFile: path)
            content = contents
            } catch {
                // 内容无法加载
                content = "getTodayLogFile failed.!! error=\(error)"
                print("getTodayLogFile failed. \(error)")
            }
        }
    }
    return content
}

//****end
