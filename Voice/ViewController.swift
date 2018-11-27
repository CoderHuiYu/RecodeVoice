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
    var songData: NSData?

    lazy var playBtn: UIButton = {
        let playBtn = UIButton()
        playBtn.setTitle("play", for: .normal)
        playBtn.frame = CGRect(x: 0, y: 230, width: UIScreen.main.bounds.size.width, height: 50)
        playBtn.addTarget(self, action: #selector(playBtnClick(_:)), for: .touchUpInside)
        playBtn.backgroundColor = UIColor.black
        return playBtn
    }()
    lazy var recordView: RecordView = {
        let recordView = RecordView(frame: CGRect(x: 0, y: 530, width: UIScreen.main.bounds.size.width, height: 50))
        recordView.backgroundColor = UIColor.blue
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
            if songData == nil {
                return
            }
            player = try AVAudioPlayer.init(data: songData! as Data)
            print("歌曲长度：\(player!.duration)")
            player!.play()
        } catch let err {
            print("播放失败:\(err.localizedDescription)")
        }
    }
}
extension ViewController: RecordViewProtocol{
    func endConvertWithData(_ data: NSData) {
        songData = data
    }
    
}

