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
    
    fileprivate var player: AVAudioPlayer?
    var voiceData: NSData?
    lazy var lockView : ZLLockAnimationView = {
        let l = ZLLockAnimationView.init(frame: CGRect.init(x: 0, y: 100, width: 400, height: 100))
//        l.backgroundColor = UIColor.red
        return l
    }()
    
    
    lazy var playBtn: UIButton = {
        let playBtn = UIButton()
        playBtn.setTitle("play", for: .normal)
        playBtn.frame = CGRect(x: (UIScreen.main.bounds.size.width-60)/2, y: 230, width: 60, height: 60)
        playBtn.layer.cornerRadius = 30
        playBtn.layer.masksToBounds = true
        playBtn.addTarget(self, action: #selector(playBtnClick(_:)), for: .touchUpInside)
        playBtn.setImage(UIImage.init(named: "play_higlight"), for:UIControl.State.highlighted)
        playBtn.setImage(UIImage.init(named: "play"), for:UIControl.State.normal)
        return playBtn
    }()
    
    lazy var recordView: ZLRecordView = {
        let recordView = ZLRecordView(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height - 50-30, width: UIScreen.main.bounds.size.width, height: 50))
        recordView.delegate = self
        return recordView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1)
        view.addSubview(playBtn)
        view.addSubview(recordView)
//        view.addSubview(lockView)
    }
    
    @objc func playBtnClick(_ sender: UIButton?){
        if player != nil {
            player?.stop()
            player?.delegate = nil
            player = nil
        }
        do {
            if voiceData == nil {
                return
            }
            player = try AVAudioPlayer.init(data: voiceData! as Data)
            print("voiceData：\(player!.duration)")
            player!.play()
        } catch let err {
            print("play fail:\(err.localizedDescription)")
        }
    }
}
extension ViewController: ZLRecordViewProtocol{
    func zlRecordFinishRecordVoice(didFinishRecode voiceData: NSData) {
         print("----已经成功的接受数据---")
         self.voiceData = voiceData
    }
}

