//
//  TGBaseNavigationVC.swift
//  SwiftFrameworkDemo
//
//  Created by luo luo on 2022/2/9.
//  Copyright © 2022 GL. All rights reserved.
//

import UIKit

open class TGBaseNavigationVC: UINavigationController {
//   weak var tabbarVC:TGPostTabbarVC?
    open override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
   
    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if children.count >= 1 {
            //隐藏tabbar
            viewController.hidesBottomBarWhenPushed = true
//            self.tabbarVC?.customTabbarView.isHidden = true;
//            LLog(TAG: TAG(self), "隐藏");
        }else{
            //最上层的显示
//            self.tabbarVC?.customTabbarView.isHidden = false;
//            LLog(TAG: TAG(self), "显示");
        }
        super.pushViewController(viewController, animated: animated)
//        LLog(TAG: TAG(self), "push=\(children.count)");
        
    }
    
    //屏幕旋转
    open override var shouldAutorotate: Bool{
        if self.topViewController != nil {
            return self.topViewController!.shouldAutorotate
        }
        return false;
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if self.topViewController != nil {
            return self.topViewController!.preferredInterfaceOrientationForPresentation
        }
        return .portrait
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        if self.topViewController != nil {
            return self.topViewController!.supportedInterfaceOrientations
        }
        return .portrait;
    }
    
    /*
    override func popViewController(animated: Bool) -> UIViewController? {
        
        let vc = super.popViewController(animated: animated)
        LLog(TAG: TAG(self), "popViewController=\(children.count)");
        if children.count > 1 {
            //隐藏tabbar
            self.tabbarVC?.customTabbarView.isHidden = true;
            LLog(TAG: TAG(self), "隐藏");
        }else{
            //最上层的显示
            self.tabbarVC?.customTabbarView.isHidden = false;
            LLog(TAG: TAG(self), "显示");
        }
        return vc;
        
    }
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        self.tabbarVC?.customTabbarView.isHidden = false;
      return  super.popToRootViewController(animated: animated)
    }*/
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
