//
//  ZLSlideView.swift
//  Voice
//
//  Created by Jeffery on 2018/11/30.
//  Copyright © 2018年 Jeffery. All rights reserved.
//

import UIKit
protocol ZLSlideViewProtocol: NSObjectProtocol{
    func cancelRecordVoice()
}
class ZLSlideView: UIView {
    
    weak var delegate : ZLSlideViewProtocol?
    
    lazy var showLabel : UILabel = {
        let label = UILabel.init(frame: self.bounds)
        label.text = "滑动来取消"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.init(red: 20/255.0, green: 20/255.0, blue: 20/255.0, alpha: 1)
        label.textAlignment = NSTextAlignment.center
//        label.backgroundColor = UIColor.init(displayP3Red: 200/255.0, green: 200/255.0, blue: 200/255.0, alpha: 1)
       
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
    
    func changeStatus() {
        showLabel.text = "取消"
        showLabel.isUserInteractionEnabled = true
        showLabel.textColor = UIColor.blue
        arrowImageView.isHidden = true
        
        let tap : UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action:#selector(canelRecord))
        showLabel.addGestureRecognizer(tap)
    }
    
    @objc func canelRecord() {
        guard let delegate = delegate else {return}
        delegate.cancelRecordVoice()
    }
}

extension UIImage{
    
    /// 更改图片颜色
    public func imageWithTintColor(color : UIColor) -> UIImage{
        UIGraphicsBeginImageContext(self.size)
        color.setFill()
        let bounds = CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height)
        UIRectFill(bounds)
        self.draw(in: bounds, blendMode: CGBlendMode.destinationIn, alpha: 1.0)
        
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintedImage!
    }
}
