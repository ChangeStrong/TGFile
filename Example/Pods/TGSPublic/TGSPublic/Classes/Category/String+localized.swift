//
//  String+localized.swift
//  SwiftFrameworkDemo
//
//  Created by mac on 2020/7/6.
//  Copyright © 2020 GL. All rights reserved.
//

import Foundation
public extension String{
    var localized: String {
           return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
       }
       
       func localized(withComment:String) -> String {
           return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: withComment)
       }
       
       func localized(tableName: String) -> String{
           return NSLocalizedString(self, tableName: tableName, bundle: Bundle.main, value: "", comment: "")
       }
}
