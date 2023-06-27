//
//  TGFileModel+Ebook.swift
//  Yeast
//
//  Created by luo luo on 2023/6/9.
//

import Foundation
extension TGFileModel{
    
    func toDeleteEbookConfigFile(){
        let tempUrl = self.getUrl().removeComponentsLastForLocal()
        let fileName = "." + self.getUrl().lastPathComponent
        let srcPath = tempUrl.appendingPathComponent(fileName).path
        if TGFileUtil.jugeFileIsExist(filePath: srcPath){
            let _ = TGFileUtil.deleteFileOrFolder(srcPath: srcPath)
        }
       
        
    }
    func toDeleteEpubCache() -> Void {
        let srcPath = TGFileManager.instance.ePubDecompressFolder.getUrl().appendingPathComponent(self.fileNameAndSuffix).path
        if TGFileUtil.jugeFileIsExist(filePath: srcPath){
            let _ = TGFileUtil.deleteFileOrFolder(srcPath: srcPath)
        }
        
    }
    
    
}
