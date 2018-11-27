//
//  ViewController.swift
//  Voice
//
//  Created by Tyoung on 2018/11/27.
//  Copyright © 2018 Tyoung. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController ,AVAudioRecorderDelegate{

    var docmentFilePath: String?
    var recorder: AVAudioRecorder?
    var playTime: Int = 0
    var playTimer: Timer?
    var songData: NSData?
    var player: AVAudioPlayer?
    
    lazy var voiceBtn: UIButton = {
        let voiceBtn = UIButton()
        voiceBtn.backgroundColor = UIColor.orange
        voiceBtn.frame = CGRect(x: 0, y: 530, width: UIScreen.main.bounds.size.width, height: 50)
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
    lazy var playBtn: UIButton = {
        let playBtn = UIButton()
        playBtn.setTitle("play", for: .normal)
        playBtn.frame = CGRect(x: 0, y: 230, width: UIScreen.main.bounds.size.width, height: 50)
        playBtn.addTarget(self, action: #selector(playBtnClick(_:)), for: .touchUpInside)
        playBtn.backgroundColor = UIColor.black
        return playBtn
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(voiceBtn)
        view.addSubview(playBtn)
        // Do any additional setup after loading the view, typically from a nib.
    }
    @objc func beginRecordVoice(_ sender: UIButton){
        playTime = 0
        let audioSession = AVAudioSession.sharedInstance()
//        let error: NSError!
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
        } catch let err{
            print("设置类型失败:\(err.localizedDescription)")
            return
        }
        //设置session动作
        do {
            try audioSession.setActive(true)
        } catch let err {
            print("初始化动作失败:\(err.localizedDescription)")
            return
        }
        let recordSetting: [String : Any] = [AVEncoderAudioQualityKey:NSNumber(integerLiteral: AVAudioQuality.min.rawValue),AVEncoderBitRateKey:NSNumber(integerLiteral: 16),AVFormatIDKey:NSNumber(integerLiteral: Int(kAudioFormatLinearPCM)),AVNumberOfChannelsKey:2,AVLinearPCMBitDepthKey:8]
        let docments = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last
        docmentFilePath = docments! + "/123"
        do {
            let url = NSURL.fileURL(withPath: docmentFilePath!)
            recorder = try AVAudioRecorder(url: url, settings: recordSetting)
            recorder?.delegate = self
            recorder!.prepareToRecord()
            recorder?.isMeteringEnabled = true
            recorder?.record()
        } catch let err {
            print("录音失败:\(err.localizedDescription)")
        }
        playTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countVoiceTime), userInfo: nil, repeats: true)

    }
    func setupPlaySound(){
        let audioSession = AVAudioSession.sharedInstance()
        //        let error: NSError!
        do {
            try audioSession.setCategory(.playback, mode: .default, options: .defaultToSpeaker)
        } catch let err{
            print("设置类型失败:\(err.localizedDescription)")
            return
        }
    }
    @objc func playBtnClick(_ sender: UIButton?){
        if player != nil {
            player?.stop()
            player?.delegate = nil
            player = nil
        }
        do {
//            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: file_path!))
            player = try AVAudioPlayer.init(data: songData! as Data)
            print("歌曲长度：\(player!.duration)")
            player!.play()
        } catch let err {
            print("播放失败:\(err.localizedDescription)")
        }
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
    func endConvertWithData(_ data: NSData){
        songData = data
    }
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        let url = NSURL.fileURL(withPath: docmentFilePath!)
        do{
            let audioData = try  NSData(contentsOfFile: url.path, options: [])
            endConvertWithData(audioData)
        } catch let err{
            print("录音失败:\(err.localizedDescription)")
        }
    }
}

