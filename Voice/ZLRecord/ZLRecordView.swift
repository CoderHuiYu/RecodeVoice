//
//  RecordView.swift
//  Voice
//
//  Created by Jeffery on 2018/11/27.
//  Copyright © 2018 Jeffery. All rights reserved.
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
let kFloatCancelRecordingOffsetX  : CGFloat = 100.0
let kFloatLockViewHeight : CGFloat  = 120.0
let kFloatLockViewWidth : CGFloat  = 40.0
@objc protocol ZLRecordViewProtocol: NSObjectProtocol{
    //return the recode voice data
    func zlRecordFinishRecordVoice(didFinishRecode voiceData: NSData)
    
    // record canceled
    @objc optional func zlRecordCanceledRecordVoice()
}

class ZLRecordView: UIView {
    
    var voiceData: NSData?
    weak var delegate: ZLRecordViewProtocol?
    var isFinished : Bool = false
    
    var trackTouchPoint : CGPoint?
    var firstTouchPoint : CGPoint?
    var isCanceling : Bool = false      //is canceling
    var timeCount : Int = 0
    
    var _voiceBtn : ZLRecordButton?
    var _shimmerView : ShimmeringView?
    var _recordBtn : UIButton?
    var _garbageView : ZLGarbageView?
    var _timeLabel : UILabel?
    var _placeholdLabel : UILabel?
    var _lockView : ZLLockView?
    var _cancleBitton : UIButton?
    
    
    var cancleBitton : UIButton {
        if _cancleBitton == nil {
            _cancleBitton = UIButton.init(frame: CGRect.init(x: 120, y: 0, width: self.frame.size.width-120-50, height: self.frame.size.height))
            _cancleBitton?.setTitle("取消", for: UIControl.State.normal)
            _cancleBitton?.setTitleColor(UIColor.blue, for: UIControl.State.normal)
        }
        return _cancleBitton!
    }
    
    
    var placeholdLabel : UILabel {
        if _placeholdLabel == nil {
           _placeholdLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 40, height: self.frame.height))
            _placeholdLabel!.backgroundColor = self.backgroundColor
        }
        return _placeholdLabel!
    }
    
    
    var shimmerView :ShimmeringView {
        if (_shimmerView == nil) {
            _shimmerView = ShimmeringView.init(frame: CGRect.init(x: 100, y: 0, width: 120, height: self.frame.size.height))
            _shimmerView!.isHidden = true
            let zlSliderView = ZLSlideView.init(frame: _shimmerView!.bounds)
            zlSliderView.delegate = self
            _shimmerView!.contentView = zlSliderView
            
            _shimmerView!.shimmerDirection = .left
            _shimmerView!.shimmerSpeed = 60
            _shimmerView!.shimmerAnimationOpacity = 0.3
            _shimmerView!.shimmerPauseDuration = 0.2
            _shimmerView!.isShimmering = true
        }
        
        return _shimmerView!
    }
    
     var voiceBtn: ZLRecordButton {
        if (_voiceBtn == nil){
            _voiceBtn = ZLRecordButton.init(frame: CGRect(x: frame.size.width-40, y: (frame.size.height - 45)/2, width: 40, height: 45))
            _voiceBtn!.delegate = self
           
        }
        return _voiceBtn!
    }
    
    var recordBtn : UIButton  {
        if (_recordBtn == nil) {
            _recordBtn = UIButton.init(frame: CGRect.init(x: 10, y: 0, width: 30, height: self.frame.height))
            let image = UIImage.init(named: "MicRecBtn")?.imageWithTintColor(color: UIColor.red)
            _recordBtn!.setImage(image, for: UIControl.State.normal)
            _recordBtn!.isHidden = true
        }
        return _recordBtn!
    }
    
    var garbageView : ZLGarbageView  {
        if (_garbageView == nil) {
            _garbageView = ZLGarbageView.init(frame: CGRect.init(x: self.recordBtn.center.x - 15/2, y: 45, width: 30, height: self.frame.height))
            _garbageView!.isHidden = true
        }
        return _garbageView!
    }
    
    var timeLabel:UILabel {
        if (_timeLabel == nil){
            _timeLabel = UILabel.init(frame: CGRect.init(x: 40, y: 0, width: 60, height: self.frame.height))
            _timeLabel!.textColor = UIColor.black
            _timeLabel!.isHidden = true
            _timeLabel?.backgroundColor = self.backgroundColor
            _timeLabel!.text = "0:00"
            _timeLabel!.font = UIFont.systemFont(ofSize: 18)
        }
        return _timeLabel!
    }
    
    var lockView : ZLLockView{
        if _lockView == nil {
            _lockView = ZLLockView.init(frame: CGRect.init(x: self.frame.size.width-kFloatLockViewWidth, y: 0, width: kFloatLockViewWidth, height: kFloatLockViewHeight))
            _lockView!.backgroundColor = UIColor.white
            _lockView!.layer.borderWidth = 1
            _lockView!.layer.borderColor = UIColor.init(red: 200/255.0, green:  200/255.0, blue:  200/255.0, alpha: 1).cgColor
            _lockView!.layer.cornerRadius = kFloatLockViewWidth / 2
            _lockView!.layer.masksToBounds = true
        }
        return _lockView!
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        backgroundColor = UIColor.init(displayP3Red: 200/255.0, green: 200/255.0, blue: 200/255.0, alpha: 1)
        addSubview(voiceBtn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    func showLockView()  {
        
        insertSubview(lockView, belowSubview: voiceBtn)
        UIView.animate(withDuration: 0.5, animations: {
            let originFrame = self.lockView.frame
            let lockViewFrame = CGRect.init(x:originFrame.origin.x, y: -originFrame.height+30, width: originFrame.size.width, height: originFrame.size.height)
            self.lockView.frame = lockViewFrame;
        }) { (finish) in
            
        }
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
    
    //recordButton‘s animation :  rotate And move
    func showRecordButtonAnimation() {
        
        let orgFrame = self.recordBtn.frame
        
        UIView.animate(withDuration: kFloatRecordImageUpTime, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            
            var frame = self.recordBtn.frame
            frame.origin.y -= (1.5 * self.recordBtn.frame.height)
            self.recordBtn.frame = frame;
            
        }) { (finish) in
            
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
                    self.timeLabel.isHidden = true
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                 self.endRecord()
            })
        }
    }
    
    //sure will cancle
    func cancled() {
        
        isCanceling = true
        voiceBtn.isCanceling = true
      
        //
        self.timeCount = 0
        self.shimmerView.isHidden = true
        self.recordBtn.layer.removeAllAnimations()
        self.garbageView.isHidden = false
        
        //notict voiceButton to stop and delete record
        voiceBtn.cancledRecord()
        
        //show animation
        showRecordButtonAnimation()
        
        //notice delegate
       
        guard let delegate = delegate else {
            return
        }
        if let res = delegate.zlRecordCanceledRecordVoice {
            res()
        }
    }
    
    //reset View contains:frame and layer animation
    func endRecord()  {
        if _lockView != nil{
            UIView.animate(withDuration: 0.2, animations: {
                let originFrame = self.lockView.frame
                let lockViewFrame = CGRect.init(x:originFrame.origin.x, y: 0, width: originFrame.size.width, height: originFrame.size.height)
                self.lockView.frame = lockViewFrame;
            }) { (finish) in
                self.lockView.removeFromSuperview()
                self._lockView = nil
            }
        }
        
        if _placeholdLabel == nil {
            placeholdLabel.removeFromSuperview()
            _placeholdLabel = nil
        }
        
        if _garbageView != nil {
             garbageView.removeFromSuperview()
            _garbageView = nil
        }
       
        if _recordBtn != nil {
            recordBtn.layer.removeAllAnimations()
            recordBtn.removeFromSuperview()
            _recordBtn = nil
        }
     
        if _shimmerView != nil {
            shimmerView.removeFromSuperview()
            let zlSliderView : ZLSlideView = self.shimmerView.contentView as! ZLSlideView
            zlSliderView.resetFrame()
            _shimmerView = nil
        }
        
        if _timeLabel != nil {
            timeLabel.removeFromSuperview()
            _timeLabel = nil
        }
        
        voiceBtn.recordBtnAddTarget()
    }
}

extension ZLRecordView : ZLSlideViewProtocol{
    func cancelRecordVoice() {
        cancled()
    }
}

extension ZLRecordView : ZLRecordButtonProtocol{
    
    // start record
    func recordStartRecordVoice(sender senderA: UIButton, event eventA: UIEvent) {
        //0.addSubview and hide garbageView
        addSubview(shimmerView)
        addSubview(placeholdLabel)
        addSubview(recordBtn)
       
        addSubview(garbageView)
        self.garbageView.isHidden = true
        
        //2.get the trackPoint
        let touch : UITouch = (eventA.touches(for: senderA)?.first)!
        trackTouchPoint = touch.location(in: self)
        firstTouchPoint = trackTouchPoint;
        isCanceling = false;
        voiceBtn.isCanceling = false
        //3.start execut the animation
        showSliderView()
      
        //4.delay
        voiceBtn.didBeginRecord()
        addSubview(timeLabel)
        showRecordImageViewGradient()
//        perform(#selector(prepareForRecord), with: nil, afterDelay: 1)
    }
    
    @objc func prepareForRecord()  {
        voiceBtn.didBeginRecord()
        addSubview(timeLabel)
        showRecordImageViewGradient()
    }
    
    // is recording
    func recordIsRecordingVoice(_ recordTime: Int) {
        timeCount = recordTime
        if (timeCount == 1) && (_lockView == nil) {
            showLockView()
        }
        if recordTime < 10 {
            self.timeLabel.text = "0:0" + "\(recordTime)"
        }else{
            self.timeLabel.text = "0:" + "\(recordTime)"
        }
    }
    
    // recordMayCancel
    func recordMayCancelRecordVoice(sender senderA: UIButton, event eventA: UIEvent) {
        
        let touch = eventA.touches(for: senderA)?.first
        let curPoint = touch?.location(in: self)
        guard curPoint != nil else {
            return
        }
        let zlSliderView : ZLSlideView = self.shimmerView.contentView as! ZLSlideView
        if curPoint!.x < voiceBtn.frame.origin.x {
            zlSliderView.updateLocation(curPoint!.x - self.trackTouchPoint!.x)
        }
       
        if (firstTouchPoint!.x - trackTouchPoint!.x) > kFloatCancelRecordingOffsetX {
            senderA.cancelTracking(with: eventA)
            senderA.removeTarget(nil, action: nil, for: UIControl.Event.allEvents)
            self.cancled()
        }
        
        guard timeCount >= 1 else {
            trackTouchPoint = curPoint
            return
        }
        
        guard _lockView != nil else {
            trackTouchPoint = curPoint
            return
        }
        
        let changeY = trackTouchPoint!.y - curPoint!.y
        print(changeY)
        if changeY > 0{
            var originFrame = self.lockView.frame
            originFrame.origin.y -= changeY
            originFrame.size.height -= changeY
            if originFrame.size.height > kFloatLockViewWidth + 5 {
                lockView.frame = originFrame;
               
            }else {
                //lock animation
                senderA.removeTarget(nil, action: nil, for: UIControl.Event.allEvents)
                shimmerView.isShimmering = false
                zlSliderView.changeStatus()
                originFrame.size = CGSize.init(width: kFloatLockViewWidth, height: kFloatLockViewWidth)
                lockView.frame = originFrame;
                lockView.addBoundsAnimation()
            }
        }else{
            var originFrame = self.lockView.frame
            originFrame.origin.y -= changeY
            originFrame.size.height -= changeY
            if originFrame.size.height <= kFloatLockViewHeight {
                self.lockView.frame = originFrame;
            }
        }
        
        trackTouchPoint = curPoint
    }
    
    //finish Record
    func recordFinishRecordVoice() {
        guard isCanceling == false else {
            return
        }
        print("recordFinish-----2")
        endRecord()
        isFinished = true
    }
    
    //finish record && return the data
    func recordFinishRecordVoice(didFinishRecode voiceData: NSData){
        if isFinished && (isCanceling == false) && (timeCount >= 1) {
            isFinished = false
            timeCount = 0
            self.delegate?.zlRecordFinishRecordVoice(didFinishRecode: voiceData)
        }
       
    }
}

