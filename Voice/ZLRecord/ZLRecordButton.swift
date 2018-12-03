//
//  ZLRecordButton.swift
//  Voice
//
//  Created by Tyoung on 2018/11/30.
//  Copyright © 2018年 Jeffery. All rights reserved.
//

import UIKit
import AVFoundation
protocol ZLRecordButtonProtocol: NSObjectProtocol{
    //return the recode voice data
    func recordFinishRecordVoice(didFinishRecode voiceData: NSData)
    
    //start record
    func recordStartRecordVoice(sender senderA: UIButton,event eventA:UIEvent)
    
    //finish record
    func recordFinishRecordVoice()
    
    //is recoding  recordTime:the duration of record
    func recordIsRecordingVoice(_ recordTime:Int)
    
    //cancle record
    func recordMayCancelRecordVoice(sender _: UIButton,event _:UIEvent)
    
}
class ZLRecordButton: UIButton {

    var voiceData: NSData?
    weak var delegate: ZLRecordButtonProtocol?
    
    fileprivate var docmentFilePath: String?
    fileprivate var recorder: AVAudioRecorder?
    fileprivate var playTime: Int = 0
    fileprivate var playTimer: Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.orange
        self.setImage(UIImage.init(named: "ButtonMic7"), for:UIControl.State.normal)
        recordBtnAddTarget()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func recordBtnAddTarget() {
        self.addTarget(self, action: #selector(recordBeginRecordVoice(_:_:)), for: .touchDown)
        self.addTarget(self, action: #selector(recordMayCancelRecordVoice(sender:event:)), for: .touchDragInside)
        self.addTarget(self, action: #selector(recordMayCancelRecordVoice(sender:event:)), for: .touchDragOutside)
        
        self.addTarget(self, action: #selector(recordFinishRecordVoice(_:)), for: .touchUpInside)
        self.addTarget(self, action: #selector(recordFinishRecordVoice(_:)), for: .touchCancel)
        self.addTarget(self, action: #selector(recordFinishRecordVoice(_:)), for: .touchUpOutside)
    }
    
    
    func cancledRecord() {
        print("recordCanceled")
        if (playTimer != nil) {
            recorder?.stop()
            recorder?.deleteRecording()
            playTimer?.invalidate()
            playTimer = nil
        }
    }
    
    func didBeginRecord() {
        print("didBeginRecord")
        playTime = 0
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
        } catch let err{
            print("set type fail:\(err.localizedDescription)")
            return
        }
        //set session
        do {
            try audioSession.setActive(true)
        } catch let err {
            print("inital fail:\(err.localizedDescription)")
            return
        }
        
        //Compressed audio
        let recordSetting: [String : Any] = [AVEncoderAudioQualityKey:NSNumber(integerLiteral: AVAudioQuality.max.rawValue),AVFormatIDKey:NSNumber(integerLiteral: Int(kAudioFormatMPEG4AAC)),AVNumberOfChannelsKey:1,AVLinearPCMBitDepthKey:8,AVSampleRateKey:NSNumber(integerLiteral: 44100)]
        
        let docments = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last
        docmentFilePath = docments! + "/123.caf" //Set storage address
        do {
            let url = NSURL.fileURL(withPath: docmentFilePath!)
            recorder = try AVAudioRecorder(url: url, settings: recordSetting)
            recorder?.delegate = self
            recorder!.prepareToRecord()
            recorder?.isMeteringEnabled = true
            recorder?.record()
        } catch let err {
            print("record fail:\(err.localizedDescription)")
        }
       
        if playTimer == nil {
            playTimer = Timer.init(timeInterval: 1, target: self, selector: #selector(countVoiceTime), userInfo: nil, repeats: true)
        }
        RunLoop.main.add(playTimer!, forMode: RunLoop.Mode.default)
//        playTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countVoiceTime), userInfo: nil, repeats: true)
    }
    
      //=================================================================
      //=================================================================
      //=================================================================
    
    //begin Record Voice
    @objc func recordBeginRecordVoice(_ sender: UIButton,_ event:UIEvent){
         print("recordBegin")
        guard delegate != nil else {
            return
        }
        delegate?.recordStartRecordVoice(sender: sender, event: event)
    }
  
    //finish Record Voice
    @objc func recordFinishRecordVoice(_ sender: UIButton?){
        print("recordFinish-----1")
        recorder?.stop()
        delegate?.recordFinishRecordVoice()
        playTimer?.invalidate()
        playTimer = nil
    }
    
    //cancle Record Voice
    @objc func recordMayCancelRecordVoice(sender senderBtn: UIButton,event eventBtn:UIEvent){
        print("recordMayCancel")
      
        delegate?.recordMayCancelRecordVoice(sender: senderBtn, event: eventBtn)
        
    }
   
    @objc private func countVoiceTime(){
        playTime = playTime + 1
        self.delegate?.recordIsRecordingVoice(playTime)
        if playTime >= 60 {
            recordFinishRecordVoice(self)
        }
        print(playTime)
    }
    
}

extension ZLRecordButton: AVAudioRecorderDelegate{
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        let url = NSURL.fileURL(withPath: docmentFilePath!)
        do{
            let audioData = try  NSData(contentsOfFile: url.path, options: [])
            delegate?.recordFinishRecordVoice(didFinishRecode: audioData)
        } catch let err{
            print("record fail:\(err.localizedDescription)")
        }
    }
}
