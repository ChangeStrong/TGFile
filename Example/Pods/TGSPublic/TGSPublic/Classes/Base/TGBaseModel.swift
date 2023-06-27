//
//  TGBaseModel.swift
//  SwiftFrameworkDemo
//
//  Created by luo luo on 2021/11/28.
//  Copyright © 2021 GL. All rights reserved.
//

import UIKit
import HandyJSON

open class TGBaseModel: NSObject,HandyJSON,Codable {
    required public override init() {}
    
    //json转模型时
   public var descriptioN:String?
    open func mapping(mapper: HelpingMapper) {
            // specify 'cat_id' field in json map to 'id' property in object
            mapper <<<
                self.descriptioN <-- "description"

    
        }
   
}

/*
 //转对象
 let object = BasicTypes.deserialize(from: jsonString)
 
 //转json
 print(object.toJSON()!) // serialize to dictionary
 print(object.toJSONString()!) // serialize to JSON string
 print(object.toJSONString(prettyPrint: true)!) // serialize to pretty JSON string
 
 func mapping(mapper: HelpingMapper) {
         // specify 'cat_id' field in json map to 'id' property in object
         mapper <<<
             self.id <-- "cat_id"

         // specify 'parent' field in json parse as following to 'parent' property in object
         mapper <<<
             self.parent <-- TransformOf<(String, String), String>(fromJSON: { (rawString) -> (String, String)? in
                 if let parentNames = rawString?.characters.split(separator: "/").map(String.init) {
                     return (parentNames[0], parentNames[1])
                 }
                 return nil
             }, toJSON: { (tuple) -> String? in
                 if let _tuple = tuple {
                     return "\(_tuple.0)/\(_tuple.1)"
                 }
                 return nil
             })

         // specify 'friend.name' path field in json map to 'friendName' property
         mapper <<<
             self.friendName <-- "friend.name"
     }
 
 
 //自定义解析某个属性
 
 
 
 //支持枚举
 enum TGFileType:Int,HandyJSONEnum {
 case unknow = 0
 }
 
 //支持Date
 override func mapping(mapper: HelpingMapper) {
     super.mapping(mapper: mapper)
         mapper <<<
             createDate <-- CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss:SSS")
     }
 
 //忽略属性
 override static func ignoredProperties() -> [String] {
         return ["owner"]
     }
 
 
 //自定义解析某个属性
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


