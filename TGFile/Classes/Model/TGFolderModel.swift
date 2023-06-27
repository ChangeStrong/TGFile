//
//  TGFolderModel.swift
//  SwiftFrameworkDemo
//
//  Created by luo luo on 2022/5/1.
//  Copyright © 2022 GL. All rights reserved.
//

import UIKit
import HandyJSON
import SSZipArchive
import TGSPublic

public class TGFolderModel: TGFileBaseModel {
    //描述文件名和后缀
    static  let profileNameAndSuff:String = ".TGFolderProfile";
    //文件夹缩略图
    static let coverNameAndSuff:String = "TGCoverOfFolder.jpeg";
    static let rubshFiles:[String] = ["__MACOSX","Inbox"];
    //音乐附属文件夹前缀
    static let musicPackagePrefix:String = ".TGMP_";
    //16位压缩密码
    static let passwordForCompressOrDepress:String = "Yeast277821200";
    //*通知相关
    static let kNotiChangeCoverOfFolder:String = "kNotiChangeCoverOfFolder";
    //*end
    //描述文件版本号
    let profileVersion:Float = 1.0;
    //跟描述文件同在
    var uniqueId:String?
    //目录下所有文件
    var files:[TGFileBaseModel] = []
    
    //**用户配置属性
    ///缩略图文件位置(相对于文件夹的位置)
    var thumnailRelativePath:String?
    ///观看模式
    enum WatchModel:Int,HandyJSONEnum {
    case defaultIntellect //默认智能
    case file //以文件形式显示
    case album //相册
    case comic //漫画
    case musicHall //音乐馆
    case cinema //电影院
    case eBook //电子书
    case threeDModel //3D模型
    case web //网页
    }
    
    var watchModel:WatchModel = .defaultIntellect //给用户设置
    var guessWatchModel:WatchModel = .file //智能判断
    //每个分类文件的数量
    var numberOfFilesPerCategoryDict:[TGFileType:Int] = [:]

    
    enum SortType:Int,HandyJSONEnum {
    case createTime = 0 //创建时间降序
    case fileName = 10 //文件名
    case custom  = 20 //自定义的顺序
    }
    ///是否是降序
    var isDescendingOrder:Bool = false
    ///排序方式
    var sortType:SortType = .fileName{
        didSet{
            //重新排序
            self.updateFilesSort()
        }
    }
    //是否需要手势解锁密码
    var isNeedGesturePassword:Bool = false;
    //是否允许导出
    var allowExport:Bool = true;
    //音乐是否显示频谱
    var audioIsShowSpectrum:Bool = false;
    
    //***音乐相关配置
    enum MusicalPlayModel:Int,HandyJSONEnum {
    case sequential
    case random
    case singleCirculation
    
    }
    ///音乐播放模式
    var musicalPlayModel:MusicalPlayModel = .sequential
    
    //***end
    
    
    //**漫画相关临时属性--不需要保存到本地的属性
    //下一章
    var forwarkFolder:TGFolderModel?
    //上一章
    var backwarkFolder:TGFolderModel?
    //漫画类型的子文件夹
    var subfoldersOfComicType:[TGFolderModel]?
    
    
    //**end
    
    //对内部文件进行排序
    func updateFilesSort() -> Void {
        if self.sortType == .createTime {
            //根据创建日期
            self.files =  self.files.sorted { item1, item2 in
                if self.isDescendingOrder == true {
                    //降序
                    return item1.createDate > item2.createDate
                }else{
                    return item1.createDate < item2.createDate
                }
                
            }
           
        }else if self.sortType == .fileName {
            //根据文件名 升序
            self.files =  self.files.sorted { item1, item2 in
                if self.isDescendingOrder == true {
                    //降序
                    if String.isPurnInt(string: item1.getFileName()) && String.isPurnInt(string: item2.getFileName()) {
                        //纯数字--用数字进行比较
                        let tempInt1:Int = Int(item1.getFileName()) ?? 0;
                        let tempInt2:Int = Int(item2.getFileName()) ?? 0;
                        return tempInt1 > tempInt2;
                    }
                    return item1.fileNameAndSuffix > item2.fileNameAndSuffix
                }else{
                    if String.isPurnInt(string: item1.getFileName()) && String.isPurnInt(string: item2.getFileName()) {
                        //纯数字--用数字进行比较
                        let tempInt1:Int = Int(item1.getFileName()) ?? 0;
                        let tempInt2:Int = Int(item2.getFileName()) ?? 0;
                        return tempInt1 < tempInt2;
                    }
                    return item1.fileNameAndSuffix < item2.fileNameAndSuffix
                }
                
            }
            
        }else if self.sortType == .custom {
            //自定义的序号--升序
            self.initSortIndex()
            self.files =  self.files.sorted { item1, item2 in
                if self.isDescendingOrder == true {
                    //降序
                    return item1.sortIndex > item2.sortIndex
                }else{
                    //升序
                    return item1.sortIndex < item2.sortIndex
                }
                
            }
            
        }
    }
    //从新给每个文件设置序号
    func initSortIndex() -> Void {
        var isUnSetting:Bool = true;
        for item in self.files {
            if item.sortIndex != 0 {
                isUnSetting = false;
                break;
            }
        }
        if isUnSetting  == false{
            //已经设置过一次序号了 自定义排序无需全部赋值序号
            return
        }
        for index in 0..<self.files.count {
            let temp = self.files[index];
            temp.sortIndex = index;
        }
    }
    
  fileprivate  override init(relativePath:String?){
        super.init(relativePath:relativePath);
        self.fileType = .folder;
        self.status = .completed;
        //创建文件夹
        self.createLocalFolder()
        //创建描述文件
        self.syncProfileFile()
    }
    
    init(relativePath:String?,isNeedCreat:Bool) {
        super.init(relativePath: relativePath)
        self.fileType = .folder;
        if isNeedCreat {
            //创建文件夹
            self.createLocalFolder()
        }
        
        //创建描述文件
        self.syncProfileFile()
    }
    
    public required  init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
//        fatalError("init(from:) has not been implemented")
    }
    // MARK: HandyJSON
    public override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        ///忽略某个属性
        mapper >>> self.loadsBlock
        mapper >>> self.numberOfFilesPerCategoryDict
        mapper >>> self.backwarkFolder
        mapper >>> self.forwarkFolder
        mapper >>> self.subfoldersOfComicType
        
//        mapper >>> self.delegete
//        mapper <<<
//            self.delegete <-- TransformOf<(TGFolderDelegete), String>(fromJSON: { rawString in
//                return nil
//            }, toJSON: { temp in
//                return nil
//            })
//                LLog(TAG: TAG(self), "ddd2");
        
        /*
        mapper <<<
            self.files <-- TransformOf<[TGFileBaseModel],[Dictionary<String,Any>]>(fromJSON: { (tempArry) -> [TGFileBaseModel] in
//            if rawString == nil {
//                return [];
//            }
            
//            let tempArry = TGGlobal.getArrayFromJSONString(jsonString: rawString!);
            var temps:[TGFileBaseModel] = [];
            if tempArry == nil {
                LLog(TAG: TAG(self), "file is empty.!");
                return temps;
            }
                LLog(TAG: TAG(self), "tempArry=\(tempArry!)");
            for item in tempArry! {
                let dict:[String:Any] = item as! [String : Any];
                let fileType:Int? = dict["fileType"] as? Int;
                if fileType != nil && TGFileBaseModel.TGFileType.folder.rawValue == fileType {
                    //是文件夹
                    LLog(TAG: TAG(self), "是文件夹");
                    let jsonStr:String = TGGlobal.getJSONStringFrom(obj: dict);
                    let tempModel:TGFolderModel = TGFolderModel.deserialize(from: jsonStr)!;
                    temps.append(tempModel);
                }else{
                    //是文件
                    let jsonStr:String = TGGlobal.getJSONStringFrom(obj: dict);
                    let tempModel:TGFileModel = TGFileModel.deserialize(from: jsonStr)!;
                    LLog(TAG: TAG(self), "文件路径:\(tempModel.path ?? "")");
                    temps.append(tempModel);
                }
            }
            return temps
        },toJSON: { temps in
            return temps?.toJSON()
        })
        */
        
        /*
        mapper.specify(property: &files){(rawString) -> [TGFileBaseModel] in
            var temps:[TGFileBaseModel] = [];
//            var tempJsonString = rawString.replacingOccurrences(of: "\n", with: "")
//            tempJsonString = tempJsonString.replacingOccurrences(of: "\t", with: "")
//            tempJsonString = tempJsonString.replacingOccurrences(of: "\\\"", with: "")
            let tempArry = TGGlobal.getArrayFromJSONString(jsonString: rawString);
            if tempArry != nil{
                for item in tempArry! {
                    let dict:[String:Any] = item as! [String : Any];
                    let fileType:Int? = dict["fileType"] as? Int;
                    if fileType != nil && TGFileBaseModel.TGFileType.folder.rawValue == fileType {
                        //是文件夹
                        LLog(TAG: TAG(self), "是文件夹");
                        let jsonStr:String = TGGlobal.getJSONStringFrom(obj: dict);
                        let tempModel:TGFolderModel = TGFolderModel.deserialize(from: jsonStr)!;
                        temps.append(tempModel);
                    }else{
                        //是文件
                        let jsonStr:String = TGGlobal.getJSONStringFrom(obj: dict);
                        let tempModel:TGFileModel = TGFileModel.deserialize(from: jsonStr)!;
                        LLog(TAG: TAG(self), "文件路径:\(tempModel.path ?? "")");
                        temps.append(tempModel);
                    }
                }
            }else{
                LLog(TAG: TAG(self), "获取json数组失败.!!");
            }
            return temps;
        }
        */
        
        
                
        }
    
    func getProfileUrl() -> URL {
        let url:URL = self.getUrl().appendingPathComponent(TGFolderModel.profileNameAndSuff)
        return url;
    }
    
    
    
    
    
    // MARK: 描述文件相关
    ///创建本地文件夹
    func createLocalFolder() -> Void {
        if self.relativePath == nil {
            LLog(TAG: TAG(self), "path is nil !!");
            return;
        }
        
        let _ = TGFileUtil.createFolder(folderPath: self.getUrl().path)
        
        //更新文件的创建时间
        let attributes:Dictionary? = try? FileManager.default.attributesOfItem(atPath: self.getUrl().path)
        if attributes != nil {
            let creationDate:Date? = attributes![FileAttributeKey.creationDate] as? Date;
            if creationDate != nil {
                self.createDate = creationDate!;
            }
        }
        if self.jugementIsApplicationSupportFile() == true {
            //是成品区的--默认不允许到处
            self.allowExport = false;
        }
    }
    ///是否仍然存在
    func isLocalExist() -> Bool {
      return TGFileUtil.jugeFileIsExist(filePath: self.getUrl().path)
    }
    
    ///创建本地描述文件
    func syncProfileFile(){
        //先判断此文件夹是否存在
        if self.isLocalExist() == false {
            LLog(TAG: TAG(self), "local folder isn't exist.!");
            return;
        }
        
        if TGFileUtil.jugeFileIsExist(filePath: getProfileUrl().path) == false {
            //没有---创建
            self.createProfileFile()
        }else{
            //已有--加载描述文件
//            LLog(TAG: TAG(self), "timeCumpute name=\(self.getFileName())");
            self.requestLoadProfileToCache()
//            LLog(TAG: TAG(self), "timeCumpute2 name=\(self.getFileName())");
            //更新描述文件-保持和本地一致
//            self.requestSyncFiles()
        }
        
    }
    
    //创建配置文件
    func createProfileFile() -> Void {
        //给配置文件打上唯一标识--用于在成品区判断文件是否存在
        self.uniqueId = "ios"+String(Date.fetchCurrentSeconds())+self.getFileName()
        files.removeAll();//清空
        if relativePath == nil {
            LLog(TAG: TAG(self), "Not find this folder path.!!");
            return
        }

        let temps = TGFileUtil.getContentsOfFolder(folderPath:self.getUrl().path)
        for item in temps {
            if item.isEmpty == true {
                LLog(TAG: TAG(self), "this file name is empty.!");
                continue
            }
         let _ = self.addFileBy(fileName: item,oldFilesDicts: [:])
        }
        
        //同步到本地
        self.syncProfileToLocal()
        
    }
    //更新配置文件
    //将本地配置文件+子文件很多时 加载进来耗时1.2秒在读取json文件的时候
    func requestLoadProfileToCache() -> Void {
        if TGFileUtil.jugeFileIsExist(filePath: getProfileUrl().path) == false {
            LLog(TAG: TAG(self), "Not find profile file.!!");
            return
        }
        
        do {
            let jsonStr:String? = try String.init(contentsOf: self.getProfileUrl())
            if jsonStr == nil {
                LLog(TAG: TAG(self), "Not find Profile data.!");
            }
//            LLog(TAG: TAG(self), "将要读取json文件");
            let temp:TGFolderModel? = TGFolderModel.deserialize(from: jsonStr)
            if temp == nil {
                LLog(TAG: TAG(self), "json to model failture.!!");
                return
            }
            //相对路径无需更新过来
//            LLog(TAG: TAG(self), "已转模型");
            //同步用户交互相关属性到类中
            self.thumnailRelativePath = temp!.thumnailRelativePath;
            self.sortType = temp!.sortType;
            self.isDescendingOrder = temp!.isDescendingOrder;
            self.isNeedGesturePassword = temp!.isNeedGesturePassword;
            self.allowExport = temp!.allowExport;
            self.audioIsShowSpectrum = temp!.audioIsShowSpectrum
            self.sortIndex = temp!.sortIndex;
            self.watchModel = temp!.watchModel;
            self.guessWatchModel = temp!.guessWatchModel;
            self.musicalPlayModel = temp!.musicalPlayModel;
            self.uniqueId = temp!.uniqueId;
            var temps:[TGFileBaseModel] = [];
            self.files = temps;
//            LLog(TAG: TAG(self), "json 装载完成");
            //temp!.files;
            //单独解析files
            let folder:[String:Any]? = TGGlobal.getDictionaryFromJSONString(jsonString: jsonStr!);
            if folder == nil {
                LLog(TAG: TAG(self), "folder is nil!!");
                return;
            }
            let files0:[[String:Any]]? = folder!["files"] as? [[String : Any]];
            if files0 == nil {
                LLog(TAG: TAG(self), "files0 is nil.!!");
                return;
            }
            
            for item in files0! {
                let type:Int = item["fileType"] as! Int
                let fileType:TGFileType = TGFileType.init(rawValue: type) ?? .unknow;
                if fileType == .folder {
                    //是文件夹
                    let tempModel:TGFolderModel = TGFolderModel.deserialize(from: item)!;
                    //将内部子文件清空--在展示时从新加载
                    tempModel.files = [];
                    temps.append(tempModel);
                }else{
                    //是文件
                    let tempModel:TGFileModel = TGFileModel.deserialize(from: item)!;
//                    LLog(TAG: TAG(self), "是文件:\(tempModel.self.getUrl().path ?? "")");
                    temps.append(tempModel);
                }

            }
            self.files = temps;
        } catch let e {
            LLog(TAG: TAG(self), "load json str error :\(e)");
            return;
        }
        
    }
    // TODO: 装载子文件
    enum LoadStatus:Int,HandyJSONEnum {
    case unknow
    case loadIng
    case finished
    case failture
    }
    typealias LoadBlock = (_ status:LoadStatus,_ file:TGFileBaseModel?) -> Void
    var loadsBlock:[LoadBlock] = []
    var currentSyncFilesStep:Int = 0
    func requestAsyncLoadFiles(_ completion:@escaping LoadBlock) -> Void {
        currentSyncFilesStep += 1;
        if self.relativePath == nil {
            LLog(TAG: TAG(self), "path is nil. !!");
            completion(.failture,nil)
            return
        }
        let tempStep = currentSyncFilesStep
        DispatchQueue.global().async {
            objc_sync_enter(self)
            self.requestAsyncLoadFiles2(tempStep) { status, file in
                DispatchQueue.main.async {
                    //主线程回调
                    completion(status,file)
                }
            };
            objc_sync_exit(self)
        }
    }
    
   fileprivate func requestAsyncLoadFiles2(_ tempStep:Int,_ completion:@escaping LoadBlock) -> Void {
       
        //重新加载当前所有文件
        var filesDict:[String:TGFileBaseModel] = [:] //保存一份原始文件记录
        for item in self.files {
            filesDict[item.fileNameAndSuffix] = item;
        }
        self.files.removeAll();//清空重新加载
       self.cleanCategoryDict()
        let temps = TGFileUtil.getContentsOfFolder(folderPath: self.getUrl().path)
        for item in temps {
            if item.isEmpty == true {
                LLog(TAG: TAG(self), "this file name is empty.!");
                continue
            }
            //是新增的文件
          let temp2 =  self.addFileBy(fileName: item,oldFilesDicts: filesDict)
            
            if temp2 != nil {
                //添加猜想类型
                let count = getNumberOfPerCategory(temp2!.fileType)
                setNumberOfPerCategory(temp2!.fileType, count + 1)
            }
            if tempStep != self.currentSyncFilesStep {
                //已经有新的同步开始了--放弃本次同步重新同步
                self.loadsBlock.append(completion)
                return;
            }
            //回调之前中断的出去
            for item in self.loadsBlock {
                item(.loadIng,temp2)
            }
            //本次回调
            completion(.loadIng,temp2)
        }
       //设置文件夹的猜想类型
       self.setWatchModelByCategoryDict()
        //根据当前模式-重新排序一下
        self.updateFilesSort()
        
        //描述文件改动---同步到本地
        self.syncProfileToLocal()
        //回调之前中断的出去
        self.loadsBlock.removeAll { temp in
            //回调且移除
            temp(.finished,nil)
            return true;
        }
        //回调本次
        completion(.finished,nil)
    }
    
    
    // TODO: 同步装载
    func requestSyncFiles() -> Void {
        if self.relativePath == nil {
            LLog(TAG: TAG(self), "path is nil. !!");
            return
        }
        //重新加载当前所有文件
        var filesDict:[String:TGFileBaseModel] = [:] //保存一份原始文件记录
        for item in self.files {
            filesDict[item.fileNameAndSuffix] = item;
        }
        //清零
        self.cleanCategoryDict()
        self.files.removeAll();//清空重新加载
        let temps = TGFileUtil.getContentsOfFolder(folderPath: self.getUrl().path)
        for item in temps {
            if item.isEmpty == true {
                LLog(TAG: TAG(self), "this file name is empty.!");
                continue
            }
            
        //是新增的文件
          let temp2 =  self.addFileBy(fileName: item,oldFilesDicts: filesDict)
            if temp2 != nil {
                //添加猜想类型
                addOneForCategory(temp2!.fileType)
            }
            
        }
        
        //只要图片数大于文件数就是漫画
       let _ = self.setWatchModelByCategoryDict()
        
        //根据当前模式-重新排序一下
        self.updateFilesSort()
        //描述文件改动---同步到本地
        self.syncProfileToLocal()
    }
    
    //同步描述文件到本地
    func syncProfileToLocal() -> Void {
//        var jsonDict = self.toJSON()
//        jsonDict!.removeValue(forKey: "delegete")
//        LLog(TAG: TAG(self), "jsonDict=\(jsonDict)");
//        let str = TGGlobal.getJSONStringFrom(obj: jsonDict);
//        LLog(TAG: TAG(self), "str==\(str)");
//        self.delegete = nil;//目前Handjson不能有代理属性否则序列化失败
        let jsonStr:String? = self.toJSONString();
        if jsonStr == nil {
            LLog(TAG: TAG(self), "jsonStr is nil.!!");
            return
        }
//        LLog(TAG: TAG(self), "json=\(String(describing: jsonStr))");
        let data:Data? = jsonStr!.data(using: String.Encoding.utf8);
        if data == nil {
            LLog(TAG: TAG(self), "data is nil.!!");
            return
        }
        //生成配置文件
        let filePath = self.getUrl().appendingPathComponent(TGFolderModel.profileNameAndSuff)
      let result =  TGFileUtil.saveFile(data: data!, filePath: filePath.path)
        if result == false {
            LLog(TAG: TAG(self), "save profile file failture.!!");
            return;
        }
//        LLog(TAG: TAG(self), "同步到本地成功.!!");
    }
    
    // MARK: 操作
    
    ///根据文件路径添加文件
    func addFileBy(fileName:String,oldFilesDicts:[String:TGFileBaseModel]) -> TGFileBaseModel? {
        
        //忽略隐藏文件.开头的
        if fileName.hasPrefix(".") {
//            LLog(TAG: TAG(self), "hidden file isn't need add.!");
            return nil;
        }
        //忽略配置文件
        if fileName == TGFolderModel.profileNameAndSuff {
            LLog(TAG: TAG(self), "profile isn't need add.!");
            return nil;
        }
        
        if fileName == TGFolderModel.coverNameAndSuff {
            self.thumnailRelativePath = fileName;
//            self.syncProfileToLocal()
            return nil;
        }
        if fileName.contains("Swift集合”正在存储文稿") {
            //系统缓存文件忽略
            LLog(TAG: TAG(self), "system cache file ignore.!");
            return nil;
        }
        if fileName.contains("By Swift Demo")  == true{
            //使用系统预览view会自动生成的
            LLog(TAG: TAG(self), "system cache file2 ignore.!");
            return nil;
        }
        if TGFolderModel.rubshFiles.contains(fileName) == true{
            //垃圾文件不显示
            return nil;
        }
        
        //忽略封面文件
        if thumnailRelativePath != nil {
            let thumnailUrl:URL? = URL.init(string: self.thumnailRelativePath!)
            if thumnailUrl != nil && fileName == thumnailUrl!.lastPathComponent {
                LLog(TAG: TAG(self), "thumnail isn't need add.!");
                return nil;
            }
        }
        
        
        let relativeTempPath:String = self.relativePath!.appendingPathComponent2(fileName);
        let tempPath:String = self.getUrl().appendingPathComponent(fileName).path;
        //self.getUrl()!.appendingPathComponent(fileName).path;
        var temp:TGFileBaseModel
        if TGFileUtil.jugeIsDirectory(tempPath) == true {
            //是文件夹
             temp = TGFolderModel.init(relativePath: relativeTempPath,isNeedCreat: true)
            let old2:TGFileBaseModel? = oldFilesDicts[temp.fileNameAndSuffix];
            if old2 != nil {
                //将排序号复制过来
                temp.sortIndex = old2!.sortIndex
            }
            files.append(temp);
        }else{
            //是文件
             temp = TGFileModel.init(relativePath: relativeTempPath);
            let old2:TGFileBaseModel? = oldFilesDicts[temp.fileNameAndSuffix];
            if old2 != nil {
                //将排序号复制过来
                temp.sortIndex = old2!.sortIndex
            }
            files.append(temp);
        }
        return temp;
    }
    
    ///改名
    func renameFile(_ nameText:String) -> (msg:String,isSuccess:Bool) {
        let srcPath:String = self.getUrl().path;
        let destingStr0 = srcPath.removeLastComponent2()
        if destingStr0 ==  nil{
            LLog(TAG: TAG(self), "can't create desting path.!!");
//            SVProgressHUD.showMessageAuto("生成目地路径失败!")
            
            return ("生成目地路径失败!",false)
        }
       
        let destingUrl:String =  destingStr0!  + "/" + nameText //+ self.getFileSuffix();
        LLog(TAG: TAG(self), "will move src=\(srcPath) dest=\(destingUrl)");
      let temp =  TGFileUtil.moveFile(srcPath: srcPath, toPath: destingUrl)
        if temp.result == false {
//            SVProgressHUD.showMessageAuto("移动失败:desting:\(destingUrl)")
            return ("移动失败:error:\(temp.msg)",false)
        }
        //修改当前model的相对路径
        let newRelativePath = self.relativePath!.removeLastComponent2()! + "/" + nameText //+ self.getFileSuffix();
        self.relativePath = newRelativePath;
        //重新同步内部文件
        self.requestSyncFiles()
        DispatchQueue.main.async {
            //通知所有文件夹界面更新本地缓存文件
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: TGFileManager.kFileDidChangedNotification), object: nil)
            for block in self.updateBlocks.values {
                if block != nil {
                    block!(.name,nil)
                }
            }
        }
        
        return ("",true)
    }
    
    ///移动到制定位置
    func moveFileTo(_ otherFolder:TGFolderModel) -> (msg:String,isSuccess:Bool) {
        let srcPath:String = self.getUrl().path;
        
        let destingUrl:String = otherFolder.getUrl().appendingPathComponent(self.fileNameAndSuffix).path;
      let temp =  TGFileUtil.moveFile(srcPath: srcPath, toPath: destingUrl)
        if temp.result == false {
//            SVProgressHUD.showMessageAuto("移动失败:desting:\(destingUrl)")
            return ("移动失败:error:\(temp.msg)",false)
        }
        //修改当前model的相对路径
        self.relativePath = otherFolder.relativePath?.appendingPathComponent2(self.fileNameAndSuffix)
        //重新同步内部文件
        self.requestSyncFiles()
        //移动到的文件夹也同步一下
        otherFolder.requestSyncFiles()
        DispatchQueue.main.async {
            //通知所有文件夹界面更新本地缓存文件
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: TGFileManager.kFileDidChangedNotification), object: nil)
        }
        return ("",true)
    }
    
    ///替换封面
    func replaceThumnail(img:UIImage?) -> Void {
        //删除之前的封面
        if self.thumnailRelativePath != nil {
            let url = self.getUrl().appendingPathComponent(self.thumnailRelativePath!)
         let _  = TGFileUtil.deleteFileOrFolder(srcPath: url.path)
            self.thumnailRelativePath = nil
            self.syncProfileToLocal()//同步到本地
        }
        if img == nil {
            //清空封面
            LLog(TAG: TAG(self), "clean thumnail.!");
            return
        }
        //重新保存
        let data = img!.jpegData(compressionQuality: 0.8)
        let fileName:String = TGFolderModel.coverNameAndSuff;
      let isSuccess = TGFileUtil.saveFile(data: data!, filePath: self.getUrl().appendingPathComponent(fileName).path)
        if isSuccess == false {
            LLog(TAG: TAG(self), "replaceThumnail failture.!!");
            return;
        }
        self.thumnailRelativePath = fileName;
        self.syncProfileToLocal()//同步到本地
        
        //通知代理更新UI
//        self.delegete?.updateUIDidChange(type: .cover)
        for block in self.updateBlocks.values {
            if block != nil {
                block!(.cover,nil)
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: TGFolderModel.kNotiChangeCoverOfFolder), object: self.getUrl().path)
    }
    
    override func toDelete(_ completion:@escaping (_ msg: String, _ isSuccess: Bool) -> Void) {
                //将所有的电子书文件名字记录--用来删除
                for item in self.files {
                    if item.fileSubType == .eBook {
                        let file:TGFileModel = item as! TGFileModel;
                        //删除epub缓存文件
                        file.toDeleteEbookConfigFile()
                    }
                }

                //删除本文件夹
                 super.toDelete(completion)
    }
    //是否需要同步一下文件夹再进行删除
    func toDelete(_ isNeedSynchronize:Bool, _ completion:@escaping (_ msg: String, _ isSuccess: Bool) -> Void){
        if isNeedSynchronize == false {
            super.toDelete(completion)
        }else{
            //需要同步一下文件夹
            self.requestAsyncLoadFiles { status, file in
                if status == .finished {
                     super.toDelete(completion)
                }else if status == .failture{
                    //同步失败--也会删除本文件夹
                     super.toDelete(completion)
                }
            }
        }
       
    }
    // MARK: 类型相关
    func cleanCategoryDict() -> Void {
        //清零
        self.numberOfFilesPerCategoryDict.removeAll()
//        for key in self.numberOfFilesPerCategoryDict.keys {
//            self.numberOfFilesPerCategoryDict[key] = 0
//        }
    }
    func fetchCategoryDict() -> [TGFileType:Int] {
        var dict = self.numberOfFilesPerCategoryDict;
        let blackList:[TGFileType]=[TGFileType.folder]
        dict = dict.filter { item in
            //过滤掉黑名单
            if blackList.contains(item.key){return false}
            return true
        }
        return dict
    }
    //各类型个数
    func setNumberOfPerCategory(_ fileType:TGFileType,_ number:Int) -> Void {
        self.numberOfFilesPerCategoryDict[fileType] = number;
    }
    func getNumberOfPerCategory(_ fileType:TGFileType) -> Int {
        let temp:Int = self.numberOfFilesPerCategoryDict[fileType] ?? 0
       return temp
    }
    func addOneForCategory(_ fileType:TGFileType) -> Void {
        let temp:Int = self.numberOfFilesPerCategoryDict[fileType] ?? 0
        self.numberOfFilesPerCategoryDict[fileType] = temp + 1;
    }
  fileprivate func setWatchModelByCategoryDict(){
//      var dict = self.fetchCategoryDict();
      let imgCount:Int = getNumberOfPerCategory(.image)
      let audioCount:Int = getNumberOfPerCategory(.audio)
      let videoCount:Int = getNumberOfPerCategory(.video)
      let eBookCount:Int = getNumberOfPerCategory(.articles)
      let objCount:Int = getNumberOfPerCategory(.obj)
      let htmlCount:Int = getNumberOfPerCategory(.html)
      var otherFileCount:Int = getNumberOfPerCategory(.unknow)
      otherFileCount += getNumberOfPerCategory(.pdf)
      otherFileCount += getNumberOfPerCategory(.lyric)
      otherFileCount += getNumberOfPerCategory(.zip)
      otherFileCount += getNumberOfPerCategory(.rar)
      
      if objCount > 0 {
          self.guessWatchModel = .threeDModel
      }else if htmlCount > 0{
          self.guessWatchModel = .web;
      }else if imgCount > 0 && imgCount > audioCount
            && imgCount > videoCount
            && imgCount > eBookCount
            && imgCount > otherFileCount
        {
            self.guessWatchModel = .comic
        }else if audioCount > 0
            && audioCount > imgCount
            && audioCount > videoCount
            && audioCount > eBookCount
            && audioCount >= otherFileCount
        {
            self.guessWatchModel = .musicHall
        }else if videoCount > 0 && videoCount > imgCount
            && videoCount > audioCount
            && videoCount > eBookCount
            && videoCount > otherFileCount {
            self.guessWatchModel = .cinema
        }else if eBookCount > 0
                    && eBookCount > imgCount
                    && eBookCount > audioCount
                    && eBookCount > videoCount
                    && eBookCount >= otherFileCount
        {
            self.guessWatchModel = .eBook
        }else{
            self.guessWatchModel = .file;
        }
    }
    
    // MARK: 观看模式
    ///获取观看模式
    func getWatchModelName() -> String {
        return TGFolderModel.fetchWatchModelNameBy(self.watchModel)
    }
    class func fetchWatchModelNameBy(_ temp:WatchModel) -> String {
        switch temp {
        case .album:
            return LocalString("Album");
        case .comic:
            return LocalString("Comic");
        case .defaultIntellect:
            return LocalString("Intellect");
        case .file:
            return LocalString("File browsing");
        case .musicHall:
            return LocalString("Music Hall");
        case .cinema:
            return LocalString("Cinema")
        case .eBook:
            return LocalString("e-book")
        case .threeDModel:
            return "3D".localized
        case .web:
            return "web".localized
        }
    }
    
    class func fetchGuessFileTypeName(_ temp:WatchModel) ->String{
        switch temp {
        case .album:
            return LocalString("Picture");
        case .comic:
            return LocalString("Picture");
        case .defaultIntellect:
            return LocalString("File");
        case .file:
            return LocalString("File");
        case .musicHall:
            return LocalString("Audio");
        case .cinema:
            return LocalString("Video")
        case .eBook:
            return LocalString("e-book")
        case .threeDModel:
            return "3D".localized
        case .web:
            return "web".localized
        }
    }
    ///猜测观看模式---优化时间
    func jugementFolderContentType() -> WatchModel {
        //由于同步json比较费时间--此处判断使用系统的属性
        if self.watchModel == .file {
            //是用户手动设置的文件系统模式
            LLog(TAG: TAG(self), "user setting file system.!");
            return .file;
        }
        self.cleanCategoryDict()
        //从新遍历所有文件
        let temps = TGFileUtil.getContentsOfFolder(folderPath: self.getUrl().path)
        var tempIndex:Int = 0;
        for item in temps {
            if item.isEmpty == true {
                LLog(TAG: TAG(self), "this file name is empty.!");
                continue
            }
            let tempPath = self.getUrl().path.appendingPathComponent2(item);
            if TGFileUtil.jugeIsDirectory(tempPath) {
                //目录不需要获取mime
                continue
            }
            //隐藏文件不需要获取
            if item.hasPrefix(".") {
                // item.hasPrefix(".TG")
                continue
            }
            if item.hasPrefix("TGCoverOfFolder") {
                //是
                continue
            }
            //是新增的文件
            let suffix:String? = TGFileUtil.getFileSuffix(path: item)
            var mime:String? = "";
            //TGFileUtil.mimeTypeForFile(atPath: self.getUrl().path.appendingPathComponent2(item))
            let semaphore = DispatchSemaphore(value: 0);
            TGFileUtil.fetchMimeType(tempPath) { result in
                mime = result as? String;
//                LLog(TAG: TAG(self), "发送");
                semaphore.signal()
            }
//            LLog(TAG: TAG(self), "等待");
            semaphore.wait()
//            LLog(TAG: TAG(self), "又开始");
            if item == TGFolderModel.coverNameAndSuff || item == TGFolderModel.profileNameAndSuff || item.hasPrefix(TGFolderModel.musicPackagePrefix) {
                //封面、配置文件、音乐包不参与计算
                continue
            }else if suffix == ".obj"{
                //obj文件
                addOneForCategory(.obj)
            }else if suffix == ".html"{
                addOneForCategory(.html)
            }else if suffix == nil || mime == nil {
                //无后缀文件不参与计算
                continue
            }
            else if suffix! == ".lrc" {
                //歌词文件不用计入
                addOneForCategory(.lyric)
                continue
            }else if mime?.contains("image") == true {
                addOneForCategory(.image)
            }else if mime?.contains("audio") == true{
                addOneForCategory(.audio)
            }else if mime?.contains("video") == true{
                addOneForCategory(.video)
            }else if mime?.contains("text/plain") == true || mime?.contains("application/epub+zip") == true
            {
                //电子书
                addOneForCategory(.articles)
            }else if suffix == nil || mime == nil{
                //文件夹不参与计算
            }else{
                addOneForCategory(.unknow)
            }
            
            tempIndex += 1;
            if tempIndex > 30 {
                //最多查看50个文件 判断类型
                break
            }
        }
        
        //只要图片数大于文件数就是漫画
        self.setWatchModelByCategoryDict()
        return self.guessWatchModel
    }
    
    ///改变观看模式
    func changeFolderType(_ temp:WatchModel,_ completion:@escaping (_ isFinished:Bool) -> Void ) -> Void {
        //先把模式改了
        self.watchModel = temp;
        self.requestAsyncLoadFiles { status, file in
            if status == .finished{
                self.syncProfileToLocal()
                
                switch temp {
                case .file:
                    //普通文件方式--无需处理
                    completion(true);
                    break;
                case .musicHall:
//                    self.restartCreateMusicalHall { result, msg in
//                        completion(result)
//                    }
                    completion(true);
                    break;
                default:
                    completion(true);
                    break
                }
            }
        }
    }
    
    // MARK: 其它
    func fetchThumnailUrl() -> URL? {
        //直接找本地是否存在此文件
        let url0 = self.getUrl().appendingPathComponent(TGFolderModel.coverNameAndSuff)
        if TGFileUtil.jugeFileIsExist(filePath: url0.path) == true {
            return url0;
        }
        if self.thumnailRelativePath == nil {
            return nil;
        }
        let url = self.getUrl().appendingPathComponent(self.thumnailRelativePath!)
        if TGFileUtil.jugeFileIsExist(filePath: url.path) == false {
            LLog(TAG: TAG(self), "thumnail is deleted !!");
            self.thumnailRelativePath = nil;
            return nil
        }
        return url;
//      return  URL.init(string: self.path!)
    }
    
    //获取所有子文件夹
func fetchAllComicSubFolder() -> [TGFolderModel] {
    if subfoldersOfComicType != nil {
        //已经获取过一次了 无需重复获取
        return subfoldersOfComicType!
    }
        var tempDatas:[TGFolderModel] = []
        for item in self.files {
            if item.fileType == .folder {
                let temp:TGFolderModel = item as! TGFolderModel;
                //且必须是漫画文件夹
                if temp.jugementFolderContentType() == .comic {
                    tempDatas.append(temp)
                }
            }
        }
    self.subfoldersOfComicType = tempDatas;
        return tempDatas;
    }
    
    
    // TODO: 漫画相关
    /*
    //从父级获取某个文件夹的上一话的文件夹
    func fetchComicUpperLevelBackwarkFolder() -> TGFolderModel? {
        if self.backwarkFolder != nil {
            //已经查找过一次了 使用之前的
            return self.backwarkFolder
        }
        let fatherFolder = self.fetchFatherFolder()
        if fatherFolder == nil {
            LLog(TAG: TAG(self), "Not find fatherFolder.!!");
            return nil
        }
        let backwardFolder:TGFolderModel?
        var currentIndex:Int = -1;
        let subFolders:[TGFolderModel] = fatherFolder!.fetchAllComicSubFolder();
        for index in 0..<subFolders.count {
            let temp = subFolders[index];
            if temp.fileNameAndSuffix == self.fileNameAndSuffix {
                currentIndex = index;
                break;
            }
        }
        if currentIndex < 1{
            return nil
        }
        backwardFolder = subFolders[currentIndex - 1];
        self.backwarkFolder = backwardFolder;
        return backwardFolder;
    }*/
    //此时self一定是父文件夹 获取上一话文件夹
    func fetchComicBackwarkFolderBy(_ subItem:TGFolderModel) -> TGFolderModel? {
        if subItem.backwarkFolder != nil {
            //已经查过一次了无需重新查找
            return subItem.backwarkFolder
        }
        let backwardFolder:TGFolderModel?
        var currentIndex:Int = -1;
        let subFolders:[TGFolderModel] = self.fetchAllComicSubFolder();
        for index in 0..<subFolders.count {
            let temp = subFolders[index];
            if temp.fileNameAndSuffix == subItem.fileNameAndSuffix {
                currentIndex = index;
                break;
            }
        }
        if currentIndex < 1{
            return nil
        }
        backwardFolder = subFolders[currentIndex - 1];
        subItem.backwarkFolder = backwardFolder;
        return backwardFolder;
    }
    
    /*
    //从父级文件夹获取下一话的文件夹
    func fetchComicUpperLevelForwarkFolder() -> TGFolderModel? {
        if self.forwarkFolder != nil {
            //已经查找过一次了 使用之前的
            return self.forwarkFolder;
        }
        let fatherFolder = self.fetchFatherFolder()
        if fatherFolder == nil {
            LLog(TAG: TAG(self), "Not find fatherFolder.!!");
            return nil
        }
        let forwardFolder:TGFolderModel?
        var currentIndex:Int = -1;
        let subFolders:[TGFolderModel] = fatherFolder!.fetchAllComicSubFolder();
        for index in 0..<subFolders.count {
            let temp = subFolders[index];
            if temp.fileType == .folder &&  temp.fileNameAndSuffix == self.fileNameAndSuffix {
                currentIndex = index;
                break;
            }
        }
        if currentIndex < 0 || currentIndex >= (subFolders.count - 1) {
            return nil
        }
        forwardFolder = subFolders[currentIndex + 1];
        self.forwarkFolder = forwardFolder;
        return forwardFolder;
    }*/
    
    //此时self一定是父文件夹 获取下一话文件夹
    func fetchComicForwarkFolderBy(_ subItem:TGFolderModel) -> TGFolderModel?{
        if subItem.forwarkFolder != nil {
            //已经查过一次了无需重新查找
            return subItem.forwarkFolder
        }
        let forwardFolder:TGFolderModel?
        var currentIndex:Int = -1;
        let subFolders:[TGFolderModel] = self.fetchAllComicSubFolder();
        for index in 0..<subFolders.count {
            let temp = subFolders[index];
            if temp.fileType == .folder &&  temp.fileNameAndSuffix == subItem.fileNameAndSuffix {
                currentIndex = index;
                break;
            }
        }
        if currentIndex < 0 || currentIndex >= (subFolders.count - 1) {
            return nil
        }
        forwardFolder = subFolders[currentIndex + 1];
        subItem.forwarkFolder = forwardFolder;
        return forwardFolder;
    }
    
    
    func getSortNameStr() -> String{
        var name = "unknow"
        switch self.sortType {
        case .createTime:
            name = "Creation time".localized
            break
        case .fileName:
            name = "File name".localized
            break
        case .custom:
            name = "Custom number".localized
            break
//        default:
//            break
        }
        return name;
    }
    //获取所有文件的文件名
    func getFilesName() -> [String] {
        var oldFileNames:[String] = [];
        for item in self.files {
            oldFileNames.append(item.fileNameAndSuffix)
        }
        return oldFileNames;
    }
   
    
    // TODO: 发布相关
    
    func checkIsCanRelease(_ completion:@escaping (_ isCan:Bool,_ msg:String) -> Void) {
        
        DispatchQueue.global().async {
            self.syncCountTheNumberTypesOfFiles();
            let dict = self.fetchCategoryDict();
            var maxType:TGFileType = .unknow;
            var maxCount:Int = 0;
            var identifiableCount:Int = 0
            for item in dict {
                if item.key != .unknow {
                    identifiableCount += 1;
                }
                if item.value >  maxCount{
                    maxType = item.key
                    maxCount = item.value
                }
            }
            
            DispatchQueue.main.async {
                if maxType == .unknow && identifiableCount == 0{
                    //全是不能识别的文件不能发布
                    completion(false,"Text files cannot be published without support".localized)
                    return;
                }
                completion(true,"");
            }
        }
    }
    
    //同步计算
    func syncCountTheNumberTypesOfFiles() {
        //同步一下文件
        self.requestSyncFiles()
        for item in self.files {
            if item.fileType == .folder{
                //文件夹--继续计算
                let temp:TGFolderModel = item as! TGFolderModel
                temp.syncCountTheNumberTypesOfFiles();
                //将子文件夹各项数据追加进来
                for item2 in temp.numberOfFilesPerCategoryDict {
                    let tempValue = getNumberOfPerCategory(item2.key) + temp.getNumberOfPerCategory(item2.key)
                    setNumberOfPerCategory(item2.key, tempValue)
                }
            }
        }
        //只要图片数大于文件数就是漫画
       let _ = self.setWatchModelByCategoryDict()
    }
    
    
    
    // MARK: 压缩相关
    func fetchCompressZip() -> TGFileModel? {
        self.fetchCompressZip(TGFolderModel.passwordForCompressOrDepress)
    }
    
    func fetchCompressZip(_ password:String?) -> TGFileModel? {
        let path0 = self.getUrl().path.removeLastComponent2()
        if path0 == nil {
            LLog(TAG: TAG(self), "path is error.!!");
            return nil
        }
       let zipPath1 = path0!  + "/" + self.getFileName() + ".zip";
        if TGFileUtil.jugeFileIsExist(filePath: zipPath1) == false {
            //不存在--压缩
            let result =  SSZipArchive.createZipFile(atPath: zipPath1, withContentsOfDirectory: self.getUrl().path, keepParentDirectory:true ,withPassword: password);
            if result == false {
                LLog(TAG: TAG(self), "compress zip failtue.!!");
                return nil
            }
        }
        //文件已经存在
        let reletivePath:String = self.relativePath!.removeLastComponent2()!  + "/" + self.getFileName() + ".zip";
        let zipFile = TGFileModel.init(relativePath: reletivePath)
        return zipFile
    }
    
    //删除已压缩的zip文件
    func deleteCompressedZipFile() -> Void {
        let path0 = self.getUrl().path.removeLastComponent2()
        if path0 == nil {
            LLog(TAG: TAG(self), "path is error.!!");
            return
        }
       let zipPath1 = path0!  + "/" + self.getFileName() + ".zip";
        if TGFileUtil.jugeFileIsExist(filePath: zipPath1) == true {
            //存在删除
            //文件已经存在
            let reletivePath:String = self.relativePath!.removeLastComponent2()!  + "/" + self.getFileName() + ".zip";
            let zipFile = TGFileModel.init(relativePath: reletivePath)
            let _ =  zipFile.toDelete { msg, isSuccess in
                
            }
        }
    }
    
}


/*
var newFileNames:[String] = [];
//增加的文件添加进来-删除的文件去除
let temps = TGFileUtil.getContentsOfFolder(folderPath: self.getUrl().path)
for item in temps {
    newFileNames.append(item)
}
//移除已删除的文件
self.files = self.files.filter { item in
    //更新一下所有子文件的相对路径
    item.relativePath = self.relativePath! + "/" + item.fileNameAndSuffix;
    
    if newFileNames.contains(item.fileNameAndSuffix) == false {
        //此文件已经被删除了
        return false
    }
    return true
}
//增加新增的文件
let oldFileNames:[String] = getFilesName()

for item in temps {
    if item.isEmpty == true {
        LLog(TAG: TAG(self), "this file name is empty.!");
        continue
    }
    if oldFileNames.contains(item) == true {
        //非新增文件--更新一下子文件的相对路径
        continue
    }
    //是新增的文件
    LLog(TAG: TAG(self), "新增文件:\(item)");
    self.addFileBy(fileName: item)
}
*/
