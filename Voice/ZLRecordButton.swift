//
//  ZLRecordButton.swift
//  Voice
//
//  Created by 余辉 on 2018/11/30.
//  Copyright © 2018年 Tyoung. All rights reserved.
//

import UIKit
import AVFoundation
protocol ZLRecordButtonProtocol: NSObjectProtocol{
    //return the recode voice data
    func recordFinishRecordVoice(didFinishRecode voiceData: NSData)
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
        self.setTitle("Hold To Talk", for: .normal)
        self.setTitle("Release To Send", for: .highlighted)
        self.addTarget(self, action: #selector(recordBeginRecordVoice(_:)), for: .touchDown)
        self.addTarget(self, action: #selector(recordEndRecordVoice(_:)), for: .touchUpInside)
        self.addTarget(self, action: #selector(recordCancelRecordVoice(_:)), for: .touchUpOutside)
        self.addTarget(self, action: #selector(recordCancelRecordVoice(_:)), for: .touchCancel)
        self.addTarget(self, action: #selector(recordRemindDragExit(_:)), for: .touchDragExit)
        self.addTarget(self, action: #selector(recordRemindDragEnter(_:)), for: .touchDragEnter)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //begin Record Voice
    @objc func recordBeginRecordVoice(_ sender: UIButton){
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
        playTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countVoiceTime), userInfo: nil, repeats: true)
    }
    
    //end Record Voice
    @objc func recordEndRecordVoice(_ sender: UIButton?){
        recorder?.stop()
        playTimer?.invalidate()
        playTimer = nil
    }
    
    //cancle Record Voice
    @objc func recordCancelRecordVoice(_ sender: UIButton){
        if (playTimer != nil) {
            recorder?.stop()
            recorder?.deleteRecording()
            playTimer?.invalidate()
            playTimer = nil
        }
        print("cancel")
    }
    
    //exit
    @objc func recordRemindDragExit(_ sender: UIButton){
        print("release to change")
    }
    
    //Slide up to cancel
    @objc func recordRemindDragEnter(_ sender: UIButton){
        print("Slide up to cancel")
    }
    
    @objc private func countVoiceTime(){
        playTime = playTime + 1
        if playTime >= 60 {
            recordEndRecordVoice (nil)
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
