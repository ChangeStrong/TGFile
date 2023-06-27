//
//  TGFileModel.swift
//  SwiftFrameworkDemo
//
//  Created by luo luo on 2022/4/15.
//  Copyright © 2022 GL. All rights reserved.
//

import UIKit
import SwiftUI
import HandyJSON
import TGSPublic


public class TGFileModel: TGFileBaseModel {
    //音乐封面
    static let coverNameAndSuffixOfMusical:String = "TGCoverOfMusical.jpeg";
    
    var mimeType:String?
    //根据音乐包内的文件--判断当前显示类型
    enum TGBackgroundType:Int,HandyJSONEnum {
    case none = 0
    case video
    case picture
    }
    
    override init(relativePath:String?){
        super.init(relativePath:relativePath);
            self.relativePath = relativePath;
        if relativePath == nil {
            LLog(TAG: TAG(self), "path is nil.!!");
            return
        }
        if TGFileUtil.jugeFileIsExist(filePath: self.getUrl().path) == false {
            LLog(TAG: TAG(self), "Not find this file.!!");
            return;
        }
//        let suffix:String? = TGFileUtil.getFileSuffix(path: self.getUrl().path)
//        let mime:String? = TGFileUtil.mimeTypeForFile(atPath: self.getUrl().path)
        self.status = .identifyingFileType;
        //此处需要等待mime类型获取完成--才能继续执行
        if Thread.current == Thread.main {
            LLog(TAG: TAG(self), "This file can be optimized for sub-thread loading");
        }
        //信号量初始化为0 第一次调用wait当前线程就得等待
        let semaphore = DispatchSemaphore(value: 0);
        TGFileUtil.fetchMimeType(self.getUrl().path) { result in
//            LLog(TAG: TAG(self), "filemime=\(result)");
            self.updateFileType(result as! String)
            self.status = .completed;
            //在子线程中 开始父线程
//            LLog(TAG: "semaphore", "开始父线程");
            semaphore.signal()
        }
            //暂停父线程
//            LLog(TAG: "semaphore", "暂停父线程");
            semaphore.wait()
//         LLog(TAG: TAG(self), "父线程继续执行");
    }
    
    
    
    func updateFileType(_ mime:String){
        let suffix:String? = TGFileUtil.getFileSuffix(path: self.getUrl().path)
        mimeType = mime;
//        LLog(TAG: TAG(self), "mimeType=\(mimeType)");
        if mimeType?.contains("image") == true {
            fileType = .image;
            //获取图片的宽高
            let img =  UIImage.init(contentsOfFile: self.getUrl().path)
            if img != nil {
                self.width = Float.init(img!.size.width);
                self.height = Float.init(img!.size.height);
            }else{
                LLog(TAG: TAG(self), "load image failture.!!");
            }
            
        }else if mimeType?.contains("audio") == true {
            fileType = .audio
        }else if mimeType?.contains("video") == true{
            fileType = .video
        }else if suffix == ".obj"{
            fileType = .obj
        }else if suffix == ".html"{
            fileType = .html
        }else if suffix == ".txt" && mimeType?.contains("text/plain") == true{
            //电子书
            fileType = .articles
            fileSubType = .eBook
        }else if suffix == ".epub" && mimeType?.contains("application/epub+zip") == true{
            //epub电子书
            fileType = .articles
            fileSubType = .eBook
        }else if mimeType?.contains("x-zip-compressed") == true || mimeType?.contains("application/zip") == true
        {
            fileType = .zip;
        }else if mimeType?.contains("x-rar-compressed") == true || suffix == ".rar" || suffix == ".RAR"{
            //application/octet-stream 此mimie也可能是rar文件
            fileType = .rar
        }else if mimeType?.contains("application/pdf") == true{
            fileType = .pdf;
        }
        else if suffix != nil && suffix! == ".lrc" {
            fileType = .lyric
        }else{
            fileType = .unknow
        }
    }
    
    public required  init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
//        fatalError("init(from:) has not been implemented")
    }
    
    
    

    // MARK: 操作
    
    //改名
    func renameFile(_ nameText:String) -> (msg:String,isSuccess:Bool) {
        let srcPath:String = self.getUrl().path;
        let destingStr0 = srcPath.removeLastComponent2()
        if destingStr0 ==  nil{
            LLog(TAG: TAG(self), "can't create desting path.!!");
//            SVProgressHUD.showMessageAuto("生成目地路径失败!")
            
            return ("生成目地路径失败!",false)
        }
        let destingUrl:String = destingStr0!  + "/" + nameText + "." + self.getFileSuffix();
      let temp =  TGFileUtil.moveFile(srcPath: srcPath, toPath: destingUrl)
        if temp.result == false {
//            SVProgressHUD.showMessageAuto("移动失败:desting:\(destingUrl)")
            return ("移动失败:error:\(temp.msg)",false)
        }
        //修改当前model的相对路径
        let newRelativePath = self.relativePath!.removeLastComponent2()! + "/" + nameText + "." + self.getFileSuffix();
        self.relativePath = newRelativePath;
        //改名成功
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: TGFileManager.kFileDidChangedNotification), object: nil)
            //通知
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
        
        
        //移动到的文件夹也同步一下
        otherFolder.requestSyncFiles()
        DispatchQueue.main.async {
            //通知所有文件夹界面更新本地缓存文件
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: TGFileManager.kFileDidChangedNotification), object: nil)
        }
        
        return ("",true)
    }
    
    ///移动文件并改名
    func moveFileAndModifyName(_ otherFolder:TGFolderModel,_ nameAndSuffix:String) -> (msg:String,isSuccess:Bool) {
        let srcPath:String = self.getUrl().path;
        
        let destingUrl:String = otherFolder.getUrl().appendingPathComponent(nameAndSuffix).path;
      let temp =  TGFileUtil.moveFile(srcPath: srcPath, toPath: destingUrl)
        if temp.result == false {
            return ("移动失败:error:\(temp.msg)",false)
        }
        //修改当前model的相对路径
        self.relativePath = otherFolder.relativePath?.appendingPathComponent2(nameAndSuffix)
        //移动到的文件夹也同步一下
        otherFolder.requestSyncFiles()
        DispatchQueue.main.async {
            //通知所有文件夹界面更新本地缓存文件
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: TGFileManager.kFileDidChangedNotification), object: nil)
        }
        return ("",true)
    }
    override func toDelete(_ completion:@escaping (_ msg: String, _ isSuccess: Bool) -> Void) {
       
        //判断是否是电子书--电子书删除对应解压文件
        if self.fileType == .articles && self.fileSubType == .eBook {
            self.toDeleteEbookConfigFile() //删除配置文件
            self.toDeleteEpubCache() //删除Epub文件
            super.toDelete(completion)
        }else if self.fileType == .audio{
            //音乐文件--移除对应的音乐包
            let musicalPackage = self.fetchMusicalPackageDirectory();
            musicalPackage?.toDelete({ msg, isSuccess in
                //回调出去
                super.toDelete(completion)
            })
        }else{
            
            super.toDelete(completion)
        }
        
         
    }
    
    
    
    
}
