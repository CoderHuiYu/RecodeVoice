//
//  ZLLockAnimationView.swift
//  Voice
//
//  Created by 余辉 on 2018/12/3.
//  Copyright © 2018年 Tyoung. All rights reserved.
//

import UIKit
let kCATranslationY = "transform.translation.y"
let kCATransformScale = "transform.scale"

let kStartY : CGFloat = 10.0
class ZLLockAnimationView: UIView {

    lazy  var  lockHead : UIImageView  = {
        let width = frame.size.width
        let lockHead = UIImageView.init(frame: CGRect.init(x: (width - 11.5)/2, y: kStartY, width: 11.5, height: 9))
        lockHead.image = UIImage.init(named: "ic_ptt_lock_shackle")
        lockHead.layer.add(animationPosition(0, 2, 0.8), forKey: kCATranslationY)
        
        return lockHead
    }()
    
    lazy var  lockBody : UIImageView = {
        let width = frame.size.width
        let lockBody = UIImageView.init(frame: CGRect.init(x: (width - 11.5)/2, y: kStartY+7, width: 11.9, height: 9.5))
        lockBody.image = UIImage.init(named: "ic_ptt_lock_body")
        lockBody.layer.add(animationPosition(2, 1, 0.8), forKey: kCATranslationY)
        
        return lockBody
    }()
    
    lazy var arrowImageView : UIImageView = {
          let width = frame.size.width
        let arrowImageView = UIImageView.init(frame: CGRect.init(x: (width - 11.5)/2, y: kStartY+7+9+7, width: 11.5, height: 9))
        arrowImageView.image = UIImage.init(named: "ic_ptt_lock_arrow")
        arrowImageView.layer.add(animationPosition(2, 0, 0.8), forKey: kCATranslationY)
        return arrowImageView
    }()
    
    func animationPosition(_ fromValue : Any,_ toValue : Any,_ duration : CFTimeInterval) -> CABasicAnimation {
        let basicAnimtion: CASpringAnimation = CASpringAnimation.init(keyPath: kCATranslationY)
        basicAnimtion.repeatCount = 10000
        basicAnimtion.duration = duration
        basicAnimtion.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        basicAnimtion.autoreverses = true
        basicAnimtion.fromValue = fromValue
        basicAnimtion.toValue = toValue
        
        return basicAnimtion
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(lockHead)
        addSubview(lockBody)
        addSubview(arrowImageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
