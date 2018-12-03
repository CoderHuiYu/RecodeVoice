//
//  ZLSlideView.swift
//  Voice
//
//  Created by Jeffery on 2018/11/30.
//  Copyright © 2018年 Jeffery. All rights reserved.
//

import UIKit

class ZLSlideView: UIView {
    
    lazy var showLabel : UILabel = {
        let label = UILabel.init(frame: self.bounds)
        label.text = "滑动来取消"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.init(red: 20/255.0, green: 20/255.0, blue: 20/255.0, alpha: 1)
        label.textAlignment = NSTextAlignment.center
        label.backgroundColor = UIColor.clear
        return label
    }()
    
    lazy var arrowImageView : UIImageView = {
        let imgView = UIImageView.init(image: UIImage.init(named: "SlideArrow"))
        var frame = imgView.frame
        frame.size = CGSize.init(width: 8, height: 17)
        frame.origin.x = self.frame.size.width/2.0 + 45
        frame.origin.y = (self.frame.height - frame.height)/2
        imgView.frame = frame
        return imgView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        
        addSubview(showLabel)
        addSubview(arrowImageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resetFrame() {
        showLabel.frame = CGRect.init(origin: self.bounds.origin, size: self.bounds.size)
        var frame  = CGRect.init()
        frame.size = CGSize.init(width: 8, height: 17)
        frame.origin.x = self.frame.size.width/2.0 + 45
        frame.origin.y = (self.frame.height - frame.height)/2
        arrowImageView.frame = frame
    }
    
    func updateLocation(_ offSetX : CGFloat) {
//        print("offSetX \(offSetX)")
        var labelFrame = showLabel.frame
        labelFrame.origin.x += offSetX
        showLabel.frame = labelFrame
        
        var imgViewFrame = arrowImageView.frame
        imgViewFrame.origin.x += offSetX
        arrowImageView.frame = imgViewFrame
    }
    
}
