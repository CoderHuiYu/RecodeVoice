//
//  ZLGarbageView.swift
//  Voice
//
//  Created by Jeffery on 2018/11/30.
//  Copyright © 2018年 Jeffery. All rights reserved.
//

import UIKit

class ZLGarbageView: UIView {

    lazy var bodyView : UIImageView = {
       let imgView  = UIImageView.init(image: UIImage.init(named: "BucketBodyTemplate"))
        var frame = imgView.frame
        frame.origin.y = (self.frame.height - 15)/2
        imgView.frame = frame
        return imgView
    }()
    
    lazy var headerView : UIImageView = {
        let imgView  = UIImageView.init(image: UIImage.init(named: "BucketLidTemplate"))
        var frame = imgView.frame
        frame.origin.y = (self.frame.height - 15)/2
        imgView.frame = frame
        
        setViewFixedAnchorPoint(CGPoint.init(x: 0, y: 1), imgView)
        return imgView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(headerView)
        addSubview(bodyView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViewFixedAnchorPoint(_ anchorPoint : CGPoint,_ view : UIView)  {
        var newPoint = CGPoint.init(x: view.bounds.size.width * anchorPoint.x, y: view.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPoint.init(x: view.bounds.size.width * view.layer.anchorPoint.x, y: view.bounds.size.height * view.layer.anchorPoint.y)
        
        newPoint = __CGPointApplyAffineTransform(newPoint, view.transform)
        oldPoint = __CGPointApplyAffineTransform(oldPoint, view.transform)
        
        var position = view.layer.position
        position.x -= oldPoint.x
        position.x += newPoint.x
        
        position.y -= oldPoint.y
        position.y += newPoint.y
        
        view.layer.position = position
        view.layer.anchorPoint = anchorPoint
    }
    
    
}
