//
//  RecordView.swift
//  Voice
//
//  Created by Tyoung on 2018/11/27.
//  Copyright © 2018 Tyoung. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation
import QuartzCore
let kFloatRecordImageUpTime  = 0.5
let kFloatRecordImageRotateTime = 0.17
let kFloatRecordImageDownTime = 0.5
let kFloatGarbageAnimationTime = 0.3
let kFloatGarbageBeginY  = 45.0
let kFloatCancelRecordingOffsetX  = 100.0
protocol ZLRecordViewProtocol: NSObjectProtocol{
    //return the recode voice data
    func recordFinishRecordVoice(didFinishRecode voiceData: NSData)
}

class ZLRecordView: UIView {
    
    var voiceData: NSData?
    weak var delegate: ZLRecordViewProtocol?
    
    lazy var shimmerView :ShimmeringView = {
        let shimmerView = ShimmeringView.init(frame: CGRect.init(x: 100, y: 0, width: self.frame.width-33-100, height: self.frame.size.height))
        var zlSliderView = ZLSlideView.init(frame: shimmerView.bounds)
        shimmerView.isHidden = true
        shimmerView.contentView = zlSliderView
        shimmerView.isShimmering = true
        shimmerView.shimmerSpeed = 60
        shimmerView.shimmerDirection = .left
        shimmerView.shimmerPauseDuration = 0
        shimmerView.shimmerHighlightLength = 0.29;
        return shimmerView
    }()
    
    lazy var voiceBtn: ZLRecordButton = {
       let voiceBtn = ZLRecordButton.init(frame: CGRect(x: frame.size.width-13-20, y: (frame.size.height - 45)/2, width: 26, height: 45))
        voiceBtn.delegate = self
        return voiceBtn
    }()
    
    lazy var recordBtn : UIButton = {
       let btn = UIButton.init(frame: CGRect.init(x: 10, y: 0, width: 30, height: self.frame.height))
       btn.setImage(UIImage.init(named: "MicRecBtn"), for: UIControl.State.normal)
       btn.tintColor = UIColor.red
       btn.isHidden = true
       return btn
    }()
    
    lazy var garbageView : ZLGarbageView = {
        let view = ZLGarbageView.init(frame: CGRect.init(x: self.recordBtn.center.x - 15/2, y: 45, width: 30, height: self.frame.height))
        view.isHidden = true
        return view
    }()
    
    lazy var timeLabel:UILabel = {
       let label = UILabel.init(frame: CGRect.init(x: 40, y: 0, width: 60, height: self.frame.height))
        label.textColor = UIColor.black
        label.isHidden = true
        label.text = "0:00"
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        addSubview(voiceBtn)
        addSubview(shimmerView)
        addSubview(recordBtn)
        addSubview(timeLabel)
        addSubview(garbageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showSliderView() {
        //1.shimmerview
        let frame = self.shimmerView.frame
        self.shimmerView.isHidden = false
        let orgFrame = CGRect.init(x:voiceBtn.frame.maxX, y: frame.minY, width: frame.size.width, height: frame.size.height)
        self.shimmerView.frame = orgFrame
        
        //2.recordbtn
        self.recordBtn.alpha = 1.0;
        self.recordBtn.isHidden = false
        let recordFrame = self.recordBtn.frame
        let recordOriginFrame = CGRect.init(x:voiceBtn.frame.maxX, y: frame.minY, width: recordFrame.size.width, height: recordFrame.size.height)
        self.recordBtn.frame = recordOriginFrame;
        
        //3.timelabel
        self.timeLabel.isHidden = false
        let timeLabelFrame = self.timeLabel.frame
        let timeLabelOriginFrame = CGRect.init(x:voiceBtn.frame.maxX, y: frame.minY, width: timeLabelFrame.size.width, height: timeLabelFrame.size.height)
        self.timeLabel.frame = timeLabelOriginFrame;
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.curveLinear, animations: {
            self.shimmerView.frame = frame
            self.recordBtn.frame = recordFrame
            self.timeLabel.frame = timeLabelFrame
        }, completion: nil)
        
    }
    
    //recordBtn layer animation
    func showRecordImageViewGradient() {
        let basicAnimtion: CABasicAnimation = CABasicAnimation.init(keyPath: "opacity")
        basicAnimtion.repeatCount = 10000
        basicAnimtion.duration = 1.0
        basicAnimtion.autoreverses = true
        basicAnimtion.fromValue = 1.0
        basicAnimtion.toValue = 0.1
        self.recordBtn.layer.add(basicAnimtion, forKey: "opacity")
    }
    
    //show garbageView
    func showGarbage() {
        garbageView.isHidden = false
       
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            let transFormNew = CGAffineTransform.init(rotationAngle: CGFloat(-1 * Double.pi / 2))
            self.garbageView.headerView.transform  = transFormNew
            var orgFrame = self.garbageView.frame
            orgFrame.origin.y = (self.bounds.height - orgFrame.size.height) / 2
            self.garbageView.frame = orgFrame
            
            }) { (finish) in
        }
    }
   
    //recordButton‘s animation
    func setRecordButtonAnimation() {
        
        let orgFrame = self.recordBtn.frame
        
        UIView.animate(withDuration: kFloatRecordImageUpTime, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            
            var frame = self.recordBtn.frame
            frame.origin.y -= (1.5 * self.recordBtn.frame.height)
            self.recordBtn.frame = frame;
            
        }) { (finish) in
            if finish {
                self.showGarbage()
                UIView.animate(withDuration: kFloatRecordImageRotateTime, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                    let transFormNew = CGAffineTransform.init(rotationAngle: CGFloat(-1 * Double.pi))
                    self.recordBtn.transform  = transFormNew
                    
                }) { (finish) in
                    
                    UIView.animate(withDuration: kFloatRecordImageDownTime, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                        self.recordBtn.frame = orgFrame
                        self.recordBtn.alpha = 0.1
                    }) { (finish) in
                        self.recordBtn.isHidden = true
                        self.recordBtn.transform = CGAffineTransform.identity
                        self.dismissGarbage()
                    }
                }
            }
            
        }
       
        
    }
    //dismiss Garbageview
    func dismissGarbage() {
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.garbageView.headerView.transform = CGAffineTransform.identity
            var orgFrame = self.garbageView.frame
            orgFrame.origin.y = 45
            self.garbageView.frame = orgFrame
            
        }){(finish) in
            self.garbageView.isHidden = true
            self.garbageView.frame = CGRect.init(x: self.recordBtn.center.x - 15/2, y: 45, width: 30, height: self.frame.height)
        }
    }
}

extension ZLRecordView : ZLRecordButtonProtocol{
    func recordStartRecordVoice(){
        //start execut the animation
        self.garbageView.isHidden = true
        showSliderView()
        showRecordImageViewGradient()
        
    }
    
    //recording
    func recordIsRecordingVoice(_ recordTime: Int) {
        if recordTime < 10 {
            self.timeLabel.text = "0:0" + "\(recordTime)"
        }else{
            self.timeLabel.text = "0:" + "\(recordTime)"
        }
    }
    
    func recordStopRecordVoice() {
        self.shimmerView.isHidden = true
        self.recordBtn.layer.removeAllAnimations()
        self.timeLabel.isHidden = true
        //
        self.garbageView.isHidden = false
        
        showGarbage()
        setRecordButtonAnimation()
    }
    func recordFinishRecordVoice(didFinishRecode voiceData: NSData){
        self.delegate?.recordFinishRecordVoice(didFinishRecode: voiceData)
    }
}
