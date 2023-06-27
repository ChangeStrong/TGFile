//
//  NSMutableAttributedString+Extension.swift
//  SwiftFrameworkDemo
//
//  Created by luo luo on 2022/5/28.
//  Copyright © 2022 GL. All rights reserved.
//

import Foundation
import UIKit
public extension NSMutableAttributedString{
    func addBlackShadow(lenght:Int) -> Void {
        let shadow = NSShadow.init();
                    shadow.shadowBlurRadius = 1.0
                    shadow.shadowOffset = CGSize.init(width: 1, height: 1)
                    self.addAttribute(NSAttributedString.Key.shadow, value: shadow, range: NSRange.init(location: 0, length: lenght))
    }
}
