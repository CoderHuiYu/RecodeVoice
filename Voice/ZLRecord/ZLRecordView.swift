//
//  RecordView.swift
//  Voice
//
//  Created by Tyoung on 2018/11/27.
//  Copyright © 2018 Tyoung. All rights reserved.
//

import UIKit
import AVFoundation
protocol ZLRecordViewProtocol: NSObjectProtocol{
    //return the recode voice data
    func recordFinishRecordVoice(didFinishRecode voiceData: NSData)
}
/*
 UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
 label.text = @"滑动删除";
 label.font = [UIFont systemFontOfSize:16.0f];
 label.textAlignment = NSTextAlignmentCenter;
 label.backgroundColor = [UIColor clearColor];
 [self addSubview:label];
 self.textLabel = label;
 
 UIImageView *bkimageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SlideArrow"]];
 CGRect frame = bkimageView.frame;
 frame.origin.x = self.frame.size.width / 2.0 + 33;
 frame.origin.y += 5;
 [bkimageView setFrame:frame];
 [self addSubview:bkimageView];
 self.arrowImageView = bkimageView;
 */
class ZLRecordView: UIView {
    var voiceData: NSData?
    weak var delegate: ZLRecordViewProtocol?
    
    
    lazy var voiceBtn: ZLRecordButton = {
       let voiceBtn = ZLRecordButton.init(frame: CGRect(x: frame.size.width-13-20, y: (frame.size.height - 23)/2, width: 26, height: 45))
        voiceBtn.delegate = self
        return voiceBtn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        
        addSubview(voiceBtn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ZLRecordView : ZLRecordButtonProtocol{
    func recordFinishRecordVoice(didFinishRecode voiceData: NSData){
        self.delegate?.recordFinishRecordVoice(didFinishRecode: voiceData)
    }
}
