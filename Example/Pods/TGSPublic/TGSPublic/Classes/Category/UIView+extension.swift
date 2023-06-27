//
//  UIView+extension.swift
//  SwiftFrameworkDemo
//
//  Created by luo luo on 2021/12/4.
//  Copyright © 2021 GL. All rights reserved.
//

import Foundation
import UIKit

public extension UIView{
    //添加毛玻璃效果
     func addBlurView(style effctStyle: UIBlurEffect.Style) -> UIView {
        let blurEffect = UIBlurEffect(style: effctStyle)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.frame = self.bounds
         self.addSubview(visualEffectView)
         self.sendSubviewToBack(visualEffectView)
        visualEffectView.snp.makeConstraints { (make) in
            make.edges.equalTo(self).offset(0)
        }
        return visualEffectView
    }
    
   
    
}

public extension UIView{
    var x:CGFloat{
        set{
            self.frame = CGRect.init(x: newValue, y: self.y, width: self.width, height: self.height);
        }
        get{
            return self.frame.origin.x;
        }
    }
    
    var y:CGFloat{
        set{
            self.frame = CGRect.init(x: self.x, y: newValue, width: self.width, height: self.height);
        }
        get{
            return self.frame.origin.y;
        }
    }
    
    var width:CGFloat{
        set{
            self.frame = CGRect.init(x: self.x, y: self.y, width: newValue, height: self.height);
        }
        get{
            return self.frame.size.width;
        }
    }
    
    var height:CGFloat{
        set{
            self.frame = CGRect.init(x: self.x, y: self.y, width: self.width, height: newValue);
        }
        get{
            return self.frame.size.height;
        }
    }
    
    var viewController: UIViewController? {
            var next = superview
        while (next != nil) {
                let nextResponder = next!.next
            if nextResponder == nil {
                return nil
            }
                if nextResponder is UIViewController {
                    return nextResponder as? UIViewController
                }
                next = next!.superview
            }
            return nil
        }
    
}
