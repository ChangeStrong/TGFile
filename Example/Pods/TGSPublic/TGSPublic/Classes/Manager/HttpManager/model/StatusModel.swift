//
//  StatusModel.swift
//  ComicChatSwift
//
//  Created by luo luo on 2020/4/21.
//  Copyright © 2020 GL. All rights reserved.
//

import UIKit
import HandyJSON
//通用接数据模型
open class StatusModel<T:Any>: TGBaseModel {
   public var code:Int32?
    public  var data:T?
    public var message:String?
    //内部测试
    public var datas:T?
}
