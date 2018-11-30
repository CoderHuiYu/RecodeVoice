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
    lazy var recordView: RecordView = {
        let recordView = RecordView(frame: CGRect(x: 0, y: 530, width: UIScreen.main.bounds.size.width, height: 50))
        recordView.delegate = self
        return recordView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(playBtn)
        view.addSubview(recordView)
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
extension ViewController: RecordViewProtocol{
    func endConvertWithData(_ data: NSData) {
        voiceData = data
    }
    
}

