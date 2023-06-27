//
//  TGFileManager.swift
//  SwiftFrameworkDemo
//
//  Created by luo luo on 2022/4/15.
//  Copyright © 2022 GL. All rights reserved.
//

import UIKit
import RxSwift

public class TGFileManager: NSObject {
    public static let kFileDidChangedNotification:String = "kFileDidChangedNotification";
    public static let kFileOfLrcDidMoveNotification:String = "kFileOfLrcDidMoveNotification";
    // MARK: 公有属性
    var legalMimeTypes:[String] = ["image/png","image/jpeg"];
    static let instance = TGFileManager()
    override init() {
        super.init()
//        createHomeFolder()
    }
    //仓库
    public lazy var homeFolder: TGFolderModel = {
        let temp = TGFolderModel.init(relativePath: kRepositoryBasePath,isNeedCreat: true)
        temp.sortType = .createTime
        temp.isDescendingOrder = true;
        //固定观看模式为文件
        temp.changeFolderType(.file,{ (result) in
        })
        return temp
    }()
    
    //作品文件夹
    public lazy var productsFolder: TGFolderModel = {
        let temp = TGFolderModel.init(relativePath: kProductBasePath,isNeedCreat: true)
        temp.sortType = .createTime
        temp.isDescendingOrder = true;
        //固定观看模式为文件
        temp.changeFolderType(.file,{ (result) in
        })
        return temp
    }()
    
    //epub小说解压文件夹
    lazy var ePubDecompressFolder: TGFolderModel = {
        let temp = TGFolderModel.init(relativePath: "Library/Application Support/TGEpubDecompress",isNeedCreat: true)
        //固定观看模式为文件
        temp.changeFolderType(.file,{ (result) in
        })
        return temp
    }()
    
    /*
    //删除epub电子书的缓存文件--根据名字
    func toDeleteEpubDecompressFilesBy(_ names:[String]) -> Void {
        
        let tempFolder = self.ePubDecompressFolder;
        tempFolder.requestAsyncLoadFiles { status, file in
            if status == .finished {
                //删除
                var tempFiles:[TGFileBaseModel] = [];
                for item in tempFolder.files {
                    if names.contains(item.getFileName()) == true {
                        tempFiles.append(item);
                        
                    }
                }
                //循环找出需要删除的解压文件夹
                for item in tempFiles {
                    item.toDelete { msg, isSuccess in
                        
                    }
                }
                
            }
        }
    }
    */
    
   //判断在成品区是否已经存在某个文件
    public func jugementDirectoryIsEixstInProductsBy(_ uniqueId:String,_ completion:@escaping ((_ isExist:Bool,_ folder:TGFolderModel?)->Void)) -> Void {
        self.productsFolder.requestAsyncLoadFiles { status, file in
            if status == .finished {
                var tempIsExsit:Bool = false
                var tempFolder:TGFolderModel?
                for item in self.productsFolder.files {
                    if item is TGFolderModel {
                        let temp = item as! TGFolderModel
                        if  temp.uniqueId == uniqueId {
                            tempIsExsit = true;
                            tempFolder = temp;
                            break;
                        }
                    }
                }
                completion(tempIsExsit,tempFolder);
                
            }else if status == .failture{
                completion(false,nil);
            }
        }
       
    }
    
    public func fetchAllCacheSize() -> UInt64 {
        let libraryDir = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).map(\.path)[0]
        let filepath = URL(fileURLWithPath: libraryDir).appendingPathComponent("/Preferences/\(Bundle.main.bundleIdentifier ?? "").plist").path
        var fileSize: UInt64 = 0
        do {
            fileSize = UInt64((try FileManager.default.attributesOfItem(atPath: filepath)[FileAttributeKey.size] as? NSNumber)?.int64Value ?? 0)
        } catch let e {
        }
        let size:UInt64 = TGFileUtil.fetchSize(url: self.ePubDecompressFolder.getUrl())
        fileSize += size;
        return fileSize;
    }
    
    public func cleanAllCacheFile() -> Void {
      let appDomain =  Bundle.main.bundleIdentifier
        if appDomain != nil {
            UserDefaults.standard.removePersistentDomain(forName: appDomain!)
        }
        self.ePubDecompressFolder.toDelete { msg, isSuccess in
            
        }
//        LSYReadModel.removeLocalRecordAll()
    }
    
}


