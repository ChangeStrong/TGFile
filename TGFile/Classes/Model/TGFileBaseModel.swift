//
//  TGFileBaseModel.swift
//  SwiftFrameworkDemo
//
//  Created by luo luo on 2022/5/1.
//  Copyright © 2022 GL. All rights reserved.
//

import UIKit
import HandyJSON
import TGSPublic

public enum TGFileUpdateType:Int {
    case name //改名
    case cover
    case sortMethod
}
public let kProductBasePath = "Library/Application Support/TGProducts";
public let kRepositoryBasePath = "Documents";
public class TGFileBaseModel: TGBaseModel {
    //相对沙盒的路径
    public  var relativePath:String?{
        didSet{
            if relativePath == nil {
                fileNameAndSuffix = "";
                LLog(TAG: TAG(self), "relativePath is nil.!!!");
                return;
            }
            fileNameAndSuffix = TGFileUtil.getFileNameAndSuffix(path: relativePath!) ?? "";
        }
    }
    public var fileNameAndSuffix:String = "";
    public   var createDate:Date = Date.init()
    ///在父级中的排序号
    public var sortIndex:Int = 0;
    public var width:Float = 200;
    public var height:Float = 200;
    
    public enum TGFileType:Int,HandyJSONEnum {
        case unknow = 0
        case image = 10
        case video = 30
        case audio = 40
        case folder = 50 //文件夹
        case zip = 60
        case rar = 70
        case lyric = 80 //歌词文件
        case articles = 90 //文章
        case pdf = 100 //pdf文件
        case obj = 110 //3d obj文件
        case html = 200 //网页文件
    }
    public var fileType:TGFileType = .unknow
    public enum TGFileSubType:Int,HandyJSONEnum {
        case unknow = 0
        case eBook = 901//电子书
    }
    public var fileSubType:TGFileSubType = .unknow
    //文件初始化状态监听
    public typealias TGFileStatusBlock = (_ result: TGFileStatus) -> Void
    public enum TGFileStatus:Int,HandyJSONEnum {
        case unknow
        case identifyingFileType //正在识别文件类型
        case completed //处理完成
    }
    public var status:TGFileStatus = .unknow {
        didSet{
            //回调block
            for item in self.statusBlock {
                item(status)
            }
        }
    }
    public var statusBlock:[TGFileStatusBlock] = []
    
    //根据json生成不同类
    public static func createByJsonString(_ json:String) -> TGFileBaseModel?{
        var temp:TGFileBaseModel? = TGFileBaseModel.deserialize(from: json)
        if temp?.fileType == .folder {
            temp = TGFolderModel.deserialize(from: json)
        }else{
            //文件
            temp = TGFileModel.deserialize(from: json)
        }
        return temp;
    }
    
    //作者信息相关
    //作者呢称
    public var authorUserName:String = ""
    //平台号
    public var authorPlatformCode:String = ""
    ///对应的帖子id
    public var postId:String = ""
    //需要更新的对象
    public typealias UpdateBlock = (_ type:TGFileUpdateType,_ result: Any?) -> Void
    public var updateBlocks:[String:UpdateBlock?] = [:];
    
    
    public required init() {
        super.init()
        
    }
    
    public init(relativePath:String?){
        super.init()
        
        self.relativePath = relativePath;
        
        if relativePath == nil {
            LLog(TAG: TAG(self), "path is nil.!!");
            return
        }
        fileNameAndSuffix = TGFileUtil.getFileNameAndSuffix(path: relativePath!) ?? "";
        let attributes:Dictionary? = try? FileManager.default.attributesOfItem(atPath: self.getUrl().path)
        if attributes != nil {
            let creationDate:Date? = attributes![FileAttributeKey.creationDate] as? Date;
            if creationDate != nil {
                self.createDate = creationDate!;
            }
        }
        //        LLog(TAG: TAG(self), "fileAttributes:\(attributes)");
        
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        //        fatalError("init(from:) has not been implemented")
    }
    // TODO: HandJson
    public override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        ///忽略某个属性
        mapper >>> self.updateBlocks
        mapper >>> self.statusBlock
        ///时间格式转一下
        mapper <<<
            createDate <-- CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss:SSS")
    }
    
    public func getUrl() -> URL {
        if self.relativePath == nil {
            return TGFileUtil.getSandboxUrl();
        }
        let tempRelative:String = self.relativePath!
        //self.relativePath!.addingPercentEncoding(
        //            withAllowedCharacters: .urlFragmentAllowed) ?? "TGunknow.file"
        return  TGFileUtil.getSandboxUrl().appendingPathComponent(tempRelative)
        //      return  URL.init(string: self.path!)
    }
    
    public func getSizeScale() -> CGFloat {
        
        if self.height == 0 {
            return 1
        }
        if self.width == 0 {
            return 1
        }
        
        return CGFloat.init(self.height/self.width)
    }
    //获取没有后缀的名字
    public func getFileName() -> String {
        if self.fileNameAndSuffix.contains(".") == true {
            var array = self.fileNameAndSuffix.split(separator: ".")
            if array.count == 0 {
                return self.fileNameAndSuffix;
            }
            array.removeLast()
            let tempStr = array.joined(separator: ".")
            return tempStr;
            //            if array.count > 0 {
            //                return String(array.first!)
            //            }
        }
        return self.fileNameAndSuffix;
    }
    //获取文件的后缀 文件夹的为空字符串
    public func getFileSuffix() -> String {
        let paths = self.relativePath?.split(separator: "/");
        if paths == nil {
            LLog(TAG: TAG(self), "this folder haven't father.!");
            return "";
        }
        if paths!.count == 0 {
            LLog(TAG: TAG(self), "this folder haven't suffix.!");
            return "";
        }
        let tempStr:String = String.init(paths!.last!);
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
    
    // MARK: 获取上级文件夹
    //获取父级文件夹
    public func fetchFatherFolder() -> TGFolderModel? {
        var paths = self.relativePath?.split(separator: "/");
        if paths == nil {
            LLog(TAG: TAG(self), "this folder haven't father.!");
            return nil;
        }
        if paths!.count <= 1 {
            LLog(TAG: TAG(self), "this folder haven't father.!");
            return nil;
        }
        paths?.removeLast()
        let fatherRelativePath = paths?.joined(separator: "/")
        let fatherModel = TGFolderModel.init(relativePath: fatherRelativePath, isNeedCreat: false)
        if fatherModel.isLocalExist() == false {
            return nil
        }
        return fatherModel
    }
    
    public func toDelete(_ completion:@escaping (_ msg: String , _ isSuccess: Bool) -> Void) {
        
        let result =   TGFileUtil.deleteFileOrFolder(srcPath: self.getUrl().path)
        if result == false {
            completion("删除失败",false)
        }
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: TGFileManager.kFileDidChangedNotification), object: nil)
        }
        completion("",true)
    }
    
    
    
    // MARK: 其它
    //获取lrc歌词文件可能的后缀
    public class func fetchSupportSuffixOfLrc() -> [String] {
        return [".lrc",".LRC",".txt",".TXT"]
    }
    
    public func jugementIsApplicationSupportFile() -> Bool {
        if self.relativePath?.contains(kProductBasePath) == true{
            return true
        }
        return false;
    }
    
    public func fetchShowName() -> String {
        if self.relativePath == kRepositoryBasePath {
            return "Repository".localized
        }
        if self.relativePath == kProductBasePath {
            return "Download".localized
        }
        return self.getFileName()
    }
    
    
    
}

