//
//  TGSqlBase.swift
//  SwiftFrameworkDemo
//
//  Created by luo luo on 2021/11/28.
//  Copyright © 2021 GL. All rights reserved.
//

import Foundation
import GRDB
import HandyJSON

open class TGSqlBase: Record,HandyJSON {
    open class func allVersionSqls() -> [String:[String]]{
        return [:];
    }
    
    public required override init() {
        super.init()
    }


   


    required public init(row: Row) {
        super.init(row: row)
    }
    
    //json转模型时
//   public var descriptioN:String?
//   public func mapping(mapper: HelpingMapper) {
//            // specify 'cat_id' field in json map to 'id' property in object
//            mapper <<<
//                self.descriptioN <-- "description"
//
//    
//        }
}
