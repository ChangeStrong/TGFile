//
//  TGFolerModel+musical.swift
//  Yeast
//
//  Created by luo luo on 2022/7/16.
//

import Foundation
import TGSPublic

extension TGFolderModel{
    ///判断是否是音乐包
    func jugementIsMusicalPackage() -> Bool {
        if self.fileNameAndSuffix.hasPrefix(TGFolderModel.musicPackagePrefix) {
            return true
        }
        return false
    }
    
    
    func getMusicalPlayModelName() -> String {
        switch self.musicalPlayModel {
        case .sequential:
            return "Sequential".localized;
        case .singleCirculation:
            return "Single tune".localized;
        case .random:
            return "Random".localized;
        }
    }
    
    //根据歌名找到歌词文件
    func fetchLrcFileBySongName(_ name:String) -> TGFileModel? {
        var temp:TGFileModel?
        for item in self.files {
            if item.fileType == .lyric && item.getFileName() == name {
                temp = item as? TGFileModel;
                break;
            }
        }
        return temp;
    }
    
    //获取音乐封面图
    func fetchMucscialCoverPictureFile() -> TGFileModel? {
        //判断封面文件是否存在
        let url = self.getUrl().appendingPathComponent(TGFileModel.coverNameAndSuffixOfMusical)
        if TGFileUtil.jugeFileIsExist(filePath: url.path) == false {
//            LLog(TAG: TAG(self), "Not find file thumnail!");
            return nil
        }
        
        let tempRelativePath = self.relativePath?.appendingPathComponent2(TGFileModel.coverNameAndSuffixOfMusical)
        let temp = TGFileModel.init(relativePath: tempRelativePath)
        return temp;
    }
    
    // MARK: 操作
    //重新创建音乐馆
    func  restartCreateMusicalHall(_ completion:@escaping (_ isSuccess:Bool,_ msg:String) -> Void){
        //先同步一下本地文件到内存
//        self.requestSyncFiles()
        self.requestAsyncLoadFiles { status, file in
            if status == .finished {
                self.createMusicalPackage()
                completion(true,"")
            }else if status == .failture{
                completion(false,"load failture.!")
            }
        }
        
//        self.requestSyncFiles()
    }
    
   fileprivate func createMusicalPackage() -> Void {
        //音乐文件夹--找出所有音乐文件--生成每个音乐的隐藏文件夹
        var audioFiles:[TGFileBaseModel] = []
        var lyricFiles:[TGFileBaseModel] = [];
        var lyricFileNames:[String] = [];
        for item in self.files {
            if item.fileType == .audio {
                audioFiles.append(item)
            }else if item.fileType == .lyric {
                lyricFiles.append(item)
                
            }
            
        }
        //创建隐藏的音乐包
        for item in audioFiles {
            //文件夹名 = 前缀+文件名
            let tempRelativePath:String = self.relativePath!.appendingPathComponent2(TGFolderModel.musicPackagePrefix + item.getFileName())
            let tempFolder:TGFolderModel = TGFolderModel.init(relativePath: tempRelativePath,isNeedCreat: true)
        }
        
        //移动所有歌词文件
        for item in lyricFiles {
            let lrcDirectoryPath:String = self.getUrl().appendingPathComponent(TGFolderModel.musicPackagePrefix + item.getFileName()).path
            if TGFileUtil.jugeFileIsExist(filePath: lrcDirectoryPath) == false{
                //没有此歌的隐藏文件夹
                LLog(TAG: TAG(self), "Not find this dirctory.!");
                continue
            }
            lyricFileNames.append(item.fileNameAndSuffix)
            let lrc:TGFileModel = item as! TGFileModel;
            let newPath:String = lrcDirectoryPath.appendingPathComponent2(item.fileNameAndSuffix)
            let _ = TGFileUtil.moveFile(srcPath: lrc.getUrl().path, toPath: newPath)
            
        }
        //重新加载所有files
        self.files.removeAll { item in
            if lyricFileNames.contains(item.fileNameAndSuffix) == true{
                //已经被移动的文件
                  return true;
            }
            return false;
        }
    }
}
