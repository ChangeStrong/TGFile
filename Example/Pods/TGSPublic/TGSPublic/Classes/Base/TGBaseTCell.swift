//
//  TGBaseTCell.swift
//  Yeast
//
//  Created by luo luo on 2022/11/11.
//

import UIKit

open class TGBaseTCell: UITableViewCell {

    open override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    open override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        windowSizeDidChangeAction()
    }
    
    var lastStep:Int = 0;
     func windowSizeChangeAction(){
        LLog(TAG: TAG(self), "windowSizeChangeAction");
        lastStep += 1;
        let currentStep = lastStep;
        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.milliseconds(250*1)) {
            if currentStep != self.lastStep {
                LLog(TAG: TAG(self), "Discard redundant steps.!");
                return;
            }
            self.windowSizeDidChangeAction()
        }
       
    }
    //给子vc用来继承
   open func windowSizeDidChangeAction() -> Void {
       
        
    }

}
