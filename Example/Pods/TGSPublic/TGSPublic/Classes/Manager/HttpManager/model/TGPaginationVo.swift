//
//  TGPaginationVo.swift
//  SwiftFrameworkDemo
//
//  Created by luo luo on 2021/12/24.
//  Copyright © 2021 GL. All rights reserved.
//

import UIKit

open class TGPaginationVo: TGBaseModel {
    public var pageSize:Int=0
   public var pageNo:Int?
    public var firstResult:Int?
    public var nextPage:Int?
    public var prePage:Int?
    public var totalCount:Int?
    public var totalPage:Int?
    public var isFirstPage:Bool = false
    public var isLastPage:Bool = false
    
}
