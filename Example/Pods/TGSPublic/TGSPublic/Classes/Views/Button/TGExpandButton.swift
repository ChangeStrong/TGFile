//
//  TGExpandButton.swift
//  SwiftFrameworkDemo
//
//  Created by luo luo on 2021/12/2.
//  Copyright © 2021 GL. All rights reserved.
//

import UIKit

open class TGExpandButton: UIButton {

    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var temPbounds = self.bounds
        temPbounds = temPbounds.inset(by: UIEdgeInsets.init(top: -20, left: -20, bottom: -20, right: -20))
        return temPbounds.contains(point)
    }

}
