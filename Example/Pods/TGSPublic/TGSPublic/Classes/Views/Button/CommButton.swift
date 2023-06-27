//
//  CommButton.swift
//  SwiftFrameworkDemo
//
//  Created by gleeeli on 2020/6/17.
//  Copyright © 2020 GL. All rights reserved.
//

import UIKit

open class CommButton: UIButton {

    open override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
    return CGRect(x: 0, y: 0, width: self.bounds.size.height, height: self.bounds.size.height)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let size = self.bounds.size
        
        var imgRect = self.imageView!.frame
        var titleRect = self.titleLabel!.frame
        
        imgRect.origin.y = self.imageEdgeInsets.top
        imgRect.size.height = size.height -  self.imageEdgeInsets.top - self.imageEdgeInsets.bottom
        
        imgRect.origin.x = (size.width - (imgRect.size.width + titleRect.size.width)) * 0.5
        
        self.imageView?.frame = imgRect
        
        titleRect.origin.x = imgRect.origin.x + imgRect.size.width + 10
        
        self.titleLabel?.frame = titleRect
    }

}
