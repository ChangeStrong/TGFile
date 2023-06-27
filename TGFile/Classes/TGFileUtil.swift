//
//  TGFileUtil.swift
//  SwiftFrameworkDemo
//
//  Created by luo luo on 2022/4/30.
//  Copyright © 2022 GL. All rights reserved.
//

import UIKit
import CoreServices
import SwiftUI
import UniformTypeIdentifiers
import TGSPublic
//import SSZipArchive

public extension URL{
    //此接口只可以为本地文件Url使用
    func removeComponentsLastForLocal() -> URL {
        let tempPath = self.path;
        var paths = tempPath.split(separator: "/");
        
        if paths.count == 0 {
            LLog(TAG: TAG(self), "this components of url is zero!");
            return self;
        }
        paths.removeLast()
        return URL.init(fileURLWithPath:  paths.joined(separator: "/"))
    }
}


public class TGFileUtil: NSObject {
    
    //沙盒路径
    public class func getSandboxUrl()->URL{
        return URL.init(fileURLWithPath: NSHomeDirectory())
    }
    //获取document目录的路径
    class func getDocumentsURL() -> URL{
        let manager = FileManager.default
        let urlForDocument = manager.urls(for: .documentDirectory, in:.userDomainMask)
        let url = urlForDocument[0] as URL
        return url;
    }
    
    public class func getApplicationSupportURl() -> URL{
        //application support目录
        let applicationSupportURl:URL? = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        if applicationSupportURl == nil {
            LLog(TAG: TAG(self), "Not find applicationSupportDirectory.!!");
            return URL.init(fileURLWithPath: NSHomeDirectory())
        }
        return applicationSupportURl!;
    }
  public  class func fetchSupportFileFormatDict() -> [String:String]{
        var dict:[String:String] = [:];
        //视频
        dict["avi"] = "video/x-msvideo";
        dict["mov"] = "video/quicktime";
        dict["mp4"] = "video/mp4";
        dict["mpg4"] = "video/mp4";
        
        dict["AVI"] = "video/x-msvideo";
        dict["MOV"] = "video/quicktime";
        dict["MP4"] = "video/mp4";
        dict["MPG4"] = "video/mp4";
        //音频
        dict["mp3"] = "audio/x-mpeg";
        dict["wav"] = "audio/x-wav";
        dict["flac"] = "audio/flac";//audio/flac网上查的不一定靠谱 application/x-flac
        
        dict["MP3"] = "audio/x-mpeg";
        dict["WAV"] = "audio/x-wav";
        dict["FLAC"] = "audio/flac";//audio/flac网上查的不一定靠谱 application/x-flac
        //图片
        dict["jpeg"] = "image/jpeg";
        dict["jpg"] = "image/jpeg";
        dict["png"] = "image/png";
        dict["bmp"] = "image/bmp";
        dict["ico"] = "image/vnd.microsoft.icon";
        
        dict["JPEG"] = "image/jpeg";
        dict["JPG"] = "image/jpeg";
        dict["PNG"] = "image/png";
        dict["BMP"] = "image/bmp";
        //解或压
        dict["rar"] = "application/x-rar-compressed";
        dict["zip"] = "application/x-zip-compressed";
        
        dict["RAR"] = "application/x-rar-compressed";
        dict["ZIP"] = "application/x-zip-compressed";
        //其它
        dict["pdf"] = "application/pdf";
        dict["txt"] = "text/plain";
        dict["epub"] = "application/epub+zip";
        dict["lrc"] = "text/plain";
        dict["obj"] = "text/plain";
        dict["mtl"] = "text/plain";
        dict["html"] = "text/plain";
        dict["css"] = "text/plain";
        
        dict["PDF"] = "application/pdf";
        dict["TXT"] = "text/plain";
        dict["EPUB"] = "application/epub+zip";
        dict["LRC"] = "text/plain";
        dict["OBJ"] = "text/plain";
        dict["MTL"] = "text/plain";
      dict["HTML"] = "text/plain";
      dict["CSS"] = "text/plain";
       
        return dict;
    }
    // TODO: 查询相关
    //获取剩余磁盘大小
   public class func getRemainDiskSize() -> Double {
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
    
   public class func convetByteToFormatString(_ bytes:Int64) -> String{
        if bytes > 1024*1024*1024 {
            //GB
            return "\(bytes/1024/1024/1024)GB"
        }else if bytes > 1024*1024 {
            return "\(bytes/1024/1024)MB"
        }else if bytes > 1024 {
            return "\(bytes/1024)KB"
        }
        return "\(bytes)B"
    }
    
    //获取文件大小
   public class  func fetchSize(url: URL)->UInt64
    {
        var fileSize : UInt64 = 0
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: url.path)
            fileSize = attr[FileAttributeKey.size] as! UInt64
            let dict = attr as NSDictionary
            fileSize = dict.fileSize()
        } catch {
            print("Error: \(error)")
        }
        return fileSize
    }
    
    //判断文件和文件夹是否存在
    public    class func jugeFileIsExist(filePath:String) -> Bool{
        let fileManager = FileManager.default
        //        let filePath:String = NSHomeDirectory() + "/Documents/hangge.txt"
        let exist = fileManager.fileExists(atPath: filePath)
        return exist;
    }
    //判断是否是目录
    public class func jugeIsDirectory(_ path:String) -> Bool{
        var directoryExists = ObjCBool.init(false)
        let fileExists = FileManager.default.fileExists(atPath: path, isDirectory: &directoryExists)
        return fileExists && directoryExists.boolValue
    }
    
    //创建文件夹
    public class func createFolder(folderPath:String) -> Bool{
        //        let myDirectory:String = NSHomeDirectory() + "/Documents/myFolder/Files"
        let fileManager = FileManager.default
        //withIntermediateDirectories为ture表示路径中间如果有不存在的文件夹都会创建
        let exist = fileManager.fileExists(atPath: folderPath)
        if !exist {
            do {
                try fileManager.createDirectory(atPath: folderPath,
                                                withIntermediateDirectories: true, attributes: nil)
            } catch let e {
                LLog(TAG: TAG(self), "createFolder error:\(e)");
                return false;
            }
        }
        return true;
    }
    //在基路径下面追加一个文件夹--如果已存在使用已存在的
    public class func createFolder(name:String,baseUrl:NSURL) -> Bool{
        let manager = FileManager.default
        let folder = baseUrl.appendingPathComponent(name, isDirectory: true)
        let exist = manager.fileExists(atPath: folder!.path)
        if !exist {
            do {
                try manager.createDirectory(at: folder!, withIntermediateDirectories: true,
                                            attributes: nil)
            } catch let e {
                LLog(TAG: TAG(self), "createFolder2 error:\(e)");
                return false;
            }
        }
        return true;
    }
    
    //保存
    //字符串、数组、字典可以直接使用write方法写入
    //try! info.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
    public class func saveFile(data:Data,filePath:String) -> Bool {
        do {
            try data.write(to: URL(fileURLWithPath: filePath))
        } catch let e {
            LLog(TAG: TAG(self), "saveFile error:\(e)");
            return false;
        }
        return true;
    }
    
    public class func fetchDataBy(filePath:String) -> Data?{
        let url:URL? = URL.init(string: filePath);
        if url == nil {
            LLog(TAG: TAG(self), "path is error.!!");
            return nil;
        }
        do {
            let data:Data? = try  Data.init(contentsOf: url!)
            if data == nil {
                LLog(TAG: TAG(self), "data is nil2.!!");
            }
            return data;
        } catch let e {
            LLog(TAG: TAG(self), "fetchDataBy error:\(e)");
            return nil;
        }
    }
    
    //覆盖复制文件
    public class func copyAndOverwrite(srcPath:String,toPath:String)  -> Bool{
        if self.jugeFileIsExist(filePath: toPath) {
            //已存在--先删除
          let _ =  self.deleteFileOrFolder(srcPath: toPath)
        }
        //然后复制
        let fileManager = FileManager.default
        do {
            try fileManager.copyItem(atPath: srcPath, toPath: toPath)
        } catch let e {
            LLog(TAG: TAG(self), "error:\(e)");
            return false;
        }
        return true;
    }
    //普通复制
    public class func copyFile(srcPath:String,toPath:String) -> Bool{
        let fileManager = FileManager.default
        do {
            try fileManager.copyItem(atPath: srcPath, toPath: toPath)
        } catch let e {
            LLog(TAG: TAG(self), "error:\(e)");
            return false;
        }
        return true;
    }
    
    //移动文件/改名
    public class func moveFile(srcPath:String,toPath:String) -> (result:Bool,msg:String){
        if self.jugeFileIsExist(filePath: toPath) == true {
            //已存在--先进行删除
            let _ = self.deleteFileOrFolder(srcPath: toPath)
        }
        let fileManager = FileManager.default
        do {
            try fileManager.moveItem(atPath: srcPath, toPath: toPath)
        } catch let e {
          let msg =  e.localizedDescription
            LLog(TAG: TAG(self), "error:\(e)");
            return (false,msg);
        }
        return (true,"");
    }
    
    public class  func modifyFileName(srcPath:String,newName:String) ->Bool {
        let fileManager = FileManager.default
        do {
            var url:URL? = URL.init(string: srcPath);
            if url == nil {
                LLog(TAG: TAG(self), "file path is error.!");
                return false;
            }
            url = url!.deletingLastPathComponent();
            url!.appendPathComponent(newName);
            try fileManager.moveItem(atPath: srcPath, toPath: url!.path)
        } catch let e {
            LLog(TAG: TAG(self), "error:\(e)");
            return false;
        }
        return true;
    }
    //文件名+后缀
    public class func getFileNameAndSuffix(path:String) -> String?{
        
        let url:URL? = URL.init(fileURLWithPath: path)
        //URL.init(string: path);
        if url == nil {
            LLog(TAG: TAG(self), "file path is error.!");
            return nil;
        }
        //如果只有一级目录
        let temp = url!.lastPathComponent
        //        if temp.isEmpty {
        //            temp =  url!.pathComponents.first ?? ""
        //        }
        return  temp ;
    }
    
    public class func getFileSuffix(path:String) -> String?{
        let lastPath = self.getFileNameAndSuffix(path: path);
        if lastPath == nil {
            return nil;
        }
        let array = lastPath!.split(separator: ".")
        if array.count == 0 {
            LLog(TAG: TAG(self), "array is nil.!");
            return nil
        }
        return ".\(array.last!)"
    }
    
    //删除文件或者文件夹
    public class func deleteFileOrFolder(srcPath:String) -> Bool {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(atPath: srcPath)
        } catch let e {
            LLog(TAG: TAG(self), "error:\(e)");
            return false;
        }
        
        return true;
    }
    
    //获取文件相关属性 创建时间，修改时间，文件大小，文件类型等信息
    public  class func getFileAttributeDic(path:String) -> Dictionary<FileAttributeKey, Any>?{
        let manager = FileManager.default
        //        let urlForDocument = manager.urls(for: .documentDirectory, in:.userDomainMask)
        //        let docPath = urlForDocument[0]
        //        let file = docPath.appendingPathComponent("test.txt")
        var dict:Dictionary<FileAttributeKey, Any>?
        
        do {
            let attributes = try manager.attributesOfItem(atPath: path) //结果为Dictionary类型
            print("attributes: \(attributes)")
            dict = attributes;
        } catch let e {
            LLog(TAG: TAG(self), "error:\(e)");
            return nil;
        }
        
        //        print("创建时间：\(attributes![FileAttributeKey.creationDate]!)")
        //        print("修改时间：\(attributes![FileAttributeKey.modificationDate]!)")
        //        print("文件大小：\(attributes![FileAttributeKey.size]!)")
        return dict;
    }
    
    //获取文件夹下的所有文件
    public  class func getContentsOfFolder(folderPath:String) -> [String]{
        let manager = FileManager.default
        var fileNames:[String] = [];
        do {
            
            fileNames = try manager.contentsOfDirectory(atPath: folderPath)
        } catch let e {
            LLog(TAG: TAG(self), "error:\(e)");
        }
        return fileNames;
    }
    
    ///获取文件夹下所有文件的相对路径包括子目录的文件
    public class func fetchAllFilsRelativePathOfFolder(folderPath:String) -> [String]{
        var datas:[String] = []
        let manager = FileManager.default
        let directoryEnumerator = manager.enumerator(atPath: folderPath)
        if directoryEnumerator == nil {
            LLog(TAG: TAG(self), "Not find any file");
            return datas
        }
        for item in directoryEnumerator!.allObjects {
            //            LLog(TAG: TAG(self), "item path=\(item)");
            datas.append("\(item)")
        }
        return datas;
    }
    
    //根据文件的后缀获取文件的mimetype
   fileprivate class func mimeTypeForFile(atPath path: String?) -> String? {
        // 这里使用文件管理者的相关方法判断文件路径是否有后缀名
        if !FileManager().fileExists(atPath: path ?? "") {
            return nil
        }
        // [path pathExtension] 获得文件的后缀名 MIME类型字符串转化为UTI字符串
        var UTI: CFString? = nil
        let url = URL(fileURLWithPath: path!)
       let pathExtension = url.pathExtension as CFString?
       if pathExtension != nil {
           //如果以上系统方法未找到--直接使用字典查询--优化后面的查询时间
           let dict = fetchSupportFileFormatDict();
           let mime:String? = dict["\(pathExtension!)"];
           if mime != nil {
               return mime;
           }
       }
        if  pathExtension != nil{
                if #available(iOS 14.0, *) {
                    UTI = UTType(tag: "pkpass", tagClass: .filenameExtension, conformingTo:nil)?.preferredMIMEType as CFString?
                } else {
                    // Fallback on earlier versions
                    UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension!, nil)?.takeRetainedValue()
                }
        }
        // UTI字符串转化为后缀扩展名
        var MIMEType: CFString? = nil
        if let UTI = UTI {
            MIMEType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType)?.takeRetainedValue()
            //as? CFString
        }
        
        // application/octet-stream，此参数表示通用的二进制类型。
//        if MIMEType == nil {
//            
//            return nil
//        }
        return MIMEType as String?
    }
    
    public typealias TGFBlock = (_ result: Any) -> Void
    public class func fetchMimeType(_ path: String?, completion:@escaping TGFBlock) {
        let defaultMime = "application/octet-stream";
        if !FileManager().fileExists(atPath: path ?? "") {
            LLog(TAG: TAG(self), "not find file.!!");
            completion(defaultMime)
            return
        }
        if self.jugeIsDirectory(path!) {
            LLog(TAG: TAG(self), "not file is Directory.!!");
            completion(defaultMime)
            return
        }
        //先同步查询尝试
        let mime1:String? = mimeTypeForFile(atPath: path);
        if mime1 != nil{
            //通过扩展名直接获取的方式获取到了
            completion(mime1!)
            return
        }
        LLog(TAG: TAG(self), "注意:此文件耗时:=\(path ?? "")");
        //使用异步查询
        let url = URL(fileURLWithPath: path ?? "")
        let request = URLRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            print("\(response?.mimeType ?? "")")
            completion(response?.mimeType ?? defaultMime);
        }
        task.resume()
        
    }
    
    //异步方式获取mimetype
    public class func asyGetMimeType(_ path: String?,completion:@escaping (_ mime:String) -> Void) {
        // 创建URL
        let url = URL(fileURLWithPath: path ?? "")
        // 创建请求对象
        let request = URLRequest(url: url)
        // 发送异步请求 在请求的
        //            NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) { response, data, connectionError in
        //
        //            }
        let session:URLSession = URLSession.shared;
        session.dataTask(with: request) { data, response, connectionError in
            print("\(response?.mimeType ?? "")")
            completion(response?.mimeType ?? "")
        }
    }
    //默认aes 加密的
    public class  func compressZip(folderPath:String,destPath:String) -> Bool {
        if TGFileUtil.jugeFileIsExist(filePath: folderPath) == false {
            return false;
        }
        //不存在--压缩
        let result =  SSZipArchive.createZipFile(atPath: destPath, withContentsOfDirectory: folderPath, keepParentDirectory:true ,withPassword: TGFolderModel.passwordForCompressOrDepress);
        if result == false {
            LLog(TAG: TAG(self), "compress zip failtue.!!");
            return false
        }
        return true;
    }
    
    // MARK: 解压相关
    //statuss 0 - 失败 1-成功 2-正在解压
    public class func decompressFile(_ vc:TGBaseVC,_ fileModel:TGFileModel,_ completion:@escaping ((_ statuss:Int,_ code:Int,_ msg:String,_ progress:Float)->Void)) -> Void {
        //mustBeUsedInApp
        let zipPath:String = fileModel.getUrl().path
        let unarchive = SARUnArchiveANY.init(path: zipPath)
        var isPassword:Bool = false;
        if SARUnArchiveANY.hasPaasword(for: zipPath) {
            //有密码--尝试一次默认密码
            isPassword = true;
            unarchive?.password = TGFolderModel.passwordForCompressOrDepress
        }
        unarchive?.completionBlock = {filePaths in
            //解压完成--同步接收文件夹的内容
            if filePaths == nil {
                LLog(TAG: TAG(self), "it is empty!");
                completion(0,1,"it is empty!",0)
                return;
            }
            completion(1,0,"success",1)
        }
        unarchive?.progressBlock = { temp in
            completion(2,0,"doing",temp)
        }
        unarchive?.failureBlock = {
            //解压失败
            LLog(TAG: TAG(self), "decompress failture.!!");
            if isPassword == true {
                //尝试一次让用输入密码
                self.decompressWithInputPaasword2(vc, zipPath, completion)
            }else{
                completion(0,1,"decompress failture.!!",0)
            }
            
        }
        if unarchive == nil {
            LLog(TAG: TAG(self), "unarchive is nil.!!");
            completion(0,1,"unarchive is nil.!!",0)
            return
        }
        unarchive?.decompress();
    }
    //弹出输入密码再解压
    public class func decompressWithInputPaasword2(_ vc:TGBaseVC, _ path:String,_ completion:@escaping ((_ statuss:Int,_ code:Int,_ msg:String,_ progress:Float)->Void)) -> Void {
        //弹出弹框让用输入
        vc.showAlertDecompressInputPassword { isSure, password in
            if isSure {
                //使用用户输入的密码
                if String.isNull(str: password) {
                    completion(0,2,"password is empty.!",0)
                    return;
                }
                self.decompressWithPassword3(path, password!, completion)
            }
        }
    }
    
    public class func decompressWithPassword3(_ path:String,_ password:String,_ completion:@escaping ((_ statuss:Int,_ code:Int,_ msg:String,_ progress:Float)->Void)) -> Void {
        let unarchive = SARUnArchiveANY.init(path: path)
        if SARUnArchiveANY.hasPaasword(for: path) {
            //有密码--尝试一次默认密码
            unarchive?.password = password
        }
        //创建解压接收文件夹
        unarchive?.completionBlock = {filePaths in
            //解压完成--同步接收文件夹的内容
            if filePaths == nil {
                LLog(TAG: TAG(self), "it is empty!");
                completion(0,1,"it is empty!",0)
                return;
            }
            completion(1,0,"success",1)
        }
        unarchive?.progressBlock = { temp in
            completion(2,0,"doing",temp)
        }
        unarchive?.failureBlock = {
            //解压失败
            LLog(TAG: TAG(self), "decompress failture.!!");
            completion(0,1,"decompress failture.!!",0)
            
        }
        if unarchive == nil {
            LLog(TAG: TAG(self), "unarchive is nil.!!");
            completion(0,1,"unarchive is nil.!!",0)
        }
        unarchive?.decompress();
    }
    
    
}



