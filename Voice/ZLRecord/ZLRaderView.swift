//
//  ZLRaderView.swift
//  Voice
//
//  Created by 余辉 on 2018/12/4.
//  Copyright © 2018年 Tyoung. All rights reserved.
//

import UIKit

class ZLRaderView: UIView {

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = self.frame.width/2
        self.layer.masksToBounds = true
        let _ =  boundsAnimation()
        
        self.backgroundColor = UIColor.red
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func boundsAnimation() -> CABasicAnimation {
        let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
        scaleAnim.fromValue = 0.8
        scaleAnim.toValue = 1.3
        scaleAnim.duration = 0.5
        scaleAnim.autoreverses = true
        scaleAnim.repeatCount = Float.infinity
        self.layer.add(scaleAnim, forKey: "scaleAnim")
        return scaleAnim
    }
}
