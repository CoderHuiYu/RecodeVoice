//
//  ZLSlideView.swift
//  Voice
//
//  Created by 余辉 on 2018/11/30.
//  Copyright © 2018年 Tyoung. All rights reserved.
//

import UIKit

class ZLSlideView: UIView {

    lazy var showLabel : UILabel = {
        let label = UILabel.init(frame: self.bounds)
        label.text = "swipe to delete"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = NSTextAlignment.center
        label.backgroundColor = UIColor.clear
        return label
    }()
    
    lazy var arrowImageView : UIImageView = {
        let imgView = UIImageView.init(image: UIImage.init(named: "SlideArrow"))
        var frame = imgView.frame
        frame.origin.x = self.frame.size.width/2.0 + 65
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

    func updateLocation(_ offSetX : CGFloat) {
        var labelFrame = showLabel.frame
        labelFrame.origin.x += offSetX
        showLabel.frame = labelFrame
        
        var imgViewFrame = arrowImageView.frame
        imgViewFrame.origin.x += offSetX
        arrowImageView.frame = frame
    }
    
}
