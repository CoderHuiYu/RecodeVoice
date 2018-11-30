//
//  RecordView.swift
//  Voice
//
//  Created by Tyoung on 2018/11/27.
//  Copyright © 2018 Tyoung. All rights reserved.
//

import UIKit
import AVFoundation

class RecordView: UIView {
    var voiceData: NSData?
    weak var delegate: RecordViewProtocol?
    
    fileprivate var docmentFilePath: String?
    fileprivate var recorder: AVAudioRecorder?
    fileprivate var playTime: Int = 0
    fileprivate var playTimer: Timer?
    
    lazy var voiceBtn: UIButton = {
       let voiceBtn = UIButton()
        voiceBtn.backgroundColor = UIColor.orange
        voiceBtn.setTitle("Hold To Talk", for: .normal)
        voiceBtn.setTitle("Release To Send", for: .highlighted)
        voiceBtn.addTarget(self, action: #selector(beginRecordVoice(_:)), for: .touchDown)
        voiceBtn.addTarget(self, action: #selector(endRecordVoice(_:)), for: .touchUpInside)
        voiceBtn.addTarget(self, action: #selector(cancelRecordVoice(_:)), for: .touchUpOutside)
        voiceBtn.addTarget(self, action: #selector(cancelRecordVoice(_:)), for: .touchCancel)
        voiceBtn.addTarget(self, action: #selector(RemindDragExit(_:)), for: .touchDragExit)
        voiceBtn.addTarget(self, action: #selector(RemindDragEnter(_:)), for: .touchDragEnter)
        return voiceBtn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        self.voiceBtn.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        self.addSubview(self.voiceBtn)
    }
    @objc func beginRecordVoice(_ sender: UIButton){
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
    @objc func endRecordVoice(_ sender: UIButton?){
        recorder?.stop()
        playTimer?.invalidate()
        playTimer = nil
    }
    @objc func cancelRecordVoice(_ sender: UIButton){
        if (playTimer != nil) {
            recorder?.stop()
            recorder?.deleteRecording()
            playTimer?.invalidate()
            playTimer = nil
        }
        print("cancel")
    }
    @objc func RemindDragExit(_ sender: UIButton){
        print("release to change")
    }
    @objc func RemindDragEnter(_ sender: UIButton){
        print("Slide up to cancel")
    }
    @objc func countVoiceTime(){
        playTime = playTime + 1
        if playTime >= 60 {
            endRecordVoice(nil)
        }
        print(playTime)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension RecordView: AVAudioRecorderDelegate{
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        let url = NSURL.fileURL(withPath: docmentFilePath!)
        do{
            let audioData = try  NSData(contentsOfFile: url.path, options: [])
            delegate?.endConvertWithData(audioData)
        } catch let err{
            print("record fail:\(err.localizedDescription)")
        }
    }
}
protocol RecordViewProtocol: NSObjectProtocol{
    func endConvertWithData(_ data: NSData)
}
