//
//  ZLLockView.swift
//  Voice
//
//  Created by 余辉 on 2018/12/4.
//  Copyright © 2018年 Tyoung. All rights reserved.
//

import UIKit

class ZLLockView: UIView {
   
    lazy var lockAnimationView : ZLLockAnimationView = {
        
        let lockAnima = ZLLockAnimationView.init(frame: CGRect.init(x: 0, y: 0, width: kFloatLockViewWidth, height: 30))
        
        return lockAnima
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(lockAnimationView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addBoundsAnimation() {
        let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
        scaleAnim.fromValue = 0.8
        scaleAnim.toValue = 2
        scaleAnim.duration = 0.5
        scaleAnim.autoreverses = true
        scaleAnim.repeatCount = Float.infinity
        self.layer.add(scaleAnim, forKey: "scaleAnim")
    }

}
