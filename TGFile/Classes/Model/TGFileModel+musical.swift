//
//  TGFileModel+musical.swift
//  Yeast
//
//  Created by luo luo on 2023/3/17.
//

import UIKit
import TGSPublic

public extension TGFileModel{
    
    // MARK: 音乐相关
    func fetchMusicalPackageDirectory() -> TGFolderModel? {
        let fatherFolder = self.fetchFatherFolder();
        if fatherFolder == nil {
            LLog(TAG: TAG(self), "Not find father folder.!");
            return nil
        }
        let relativePath = fatherFolder!.relativePath?.appendingPathComponent2( TGFolderModel.musicPackagePrefix + self.getFileName())
        let tempFolder = TGFolderModel.init(relativePath: relativePath, isNeedCreat: false)
        if tempFolder.isLocalExist() == false {
            return nil;
        }
        return tempFolder;
    }
    
    func fetchLrcFile() -> TGFileModel? {
        let musicalPackage = self.fetchMusicalPackageDirectory();
        if musicalPackage == nil {
            LLog(TAG: TAG(self), "Not find musical package.!");
            return nil
        }
        
        //判断歌词文件是否存在
        let url = musicalPackage!.getUrl().appendingPathComponent(self.getFileName()+".lrc")
        if TGFileUtil.jugeFileIsExist(filePath: url.path) == false {
            LLog(TAG: TAG(self), "Not find file lrc!");
            return nil
        }
        
        let tempRelativePath = musicalPackage!.relativePath?.appendingPathComponent2(self.getFileName()+".lrc")
        let temp = TGFileModel.init(relativePath: tempRelativePath)
        return temp;
    }
    
    func fetchLrcFileUrl() -> URL? {
        let musicalPackage = self.fetchMusicalPackageDirectory();
        if musicalPackage == nil {
            LLog(TAG: TAG(self), "Not find musical package.!");
            return nil
        }
        
        //判断歌词文件是否存在
        let url = musicalPackage!.getUrl().appendingPathComponent(self.getFileName()+".lrc")
        return url;
    }
    
    //获取音乐封面图
    func fetchMucscialCoverPictureFile() -> TGFileModel? {
        let musicalPackage = self.fetchMusicalPackageDirectory();
        if musicalPackage == nil {
            LLog(TAG: TAG(self), "Not find musical package.!");
            return nil
        }
        
        //判断封面文件是否存在
        let url = musicalPackage!.getUrl().appendingPathComponent(TGFileModel.coverNameAndSuffixOfMusical)
        if TGFileUtil.jugeFileIsExist(filePath: url.path) == false {
//            LLog(TAG: TAG(self), "Not find file thumnail!");
            return nil
        }
        
        let tempRelativePath = musicalPackage!.relativePath?.appendingPathComponent2(TGFileModel.coverNameAndSuffixOfMusical)
        let temp = TGFileModel.init(relativePath: tempRelativePath)
        return temp;
    }
    
    //获取音乐封面视频
    func fetchMusicalCoverVideoFile() -> TGFileModel? {
        let musicalPackage = self.fetchMusicalPackageDirectory();
        if musicalPackage == nil {
            LLog(TAG: TAG(self), "Not find musical package.!");
            return nil
        }
        musicalPackage?.requestSyncFiles();
        //判断音乐包是否有视频文件
        for item in musicalPackage!.files {
            if item.fileType == .video {
                return item as? TGFileModel
            }
        }
        /*
        let url = musicalPackage!.getUrl().appendingPathComponent(self.getFileName()+".mp4")
        if TGFileUtil.jugeFileIsExist(filePath: url.path) == false {
            LLog(TAG: TAG(self), "Not find file video!");
            return nil
        }
        
        let tempRelativePath = musicalPackage!.relativePath?.appendingPathComponent2(self.getFileName()+".mp4")
        let temp = TGFileModel.init(relativePath: tempRelativePath)
         */
        return nil;
    }
    
    
    
    func fetchBackgroundType() -> TGBackgroundType {
        let musicalPackage = self.fetchMusicalPackageDirectory();
        if musicalPackage == nil {
            LLog(TAG: TAG(self), "Not find musical package.!");
            return .none
        }
        musicalPackage?.requestSyncFiles();
        //判断音乐包是否有视频文件
        let videocount = musicalPackage?.getNumberOfPerCategory(.video)
        if videocount != nil &&  videocount! > 0 {
            return .video
        }
        
       let coverFile = musicalPackage?.fetchMucscialCoverPictureFile()
        if coverFile != nil {
            return .picture
        }
        //没有视频、没有图片显示
        return.none
    }
    
    func fetchIshowSpectrum() -> Bool {
        let musicalPackage = self.fetchMusicalPackageDirectory();
        if musicalPackage == nil {
            //没有音乐包不显示频谱
            LLog(TAG: TAG(self), "Not find musical package.!");
            return false
        }
        return musicalPackage!.audioIsShowSpectrum
    }
}
