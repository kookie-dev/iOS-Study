//
//  SeekbarView.swift
//  KTV
//
//  Created by Choi Oliver on 2023/11/17.
//

import UIKit

protocol SeekbarViewDelegate: AnyObject {
    func seekbar(_ seekbar: SeekbarView, seekToPercent percent: Double)
}

class SeekbarView: UIView {
    
    @IBOutlet weak var totalPlayTimeView: UIView!
    @IBOutlet weak var playablePlayTimeView: UIView!
    @IBOutlet weak var currentPlayTimeView: UIView!
    
    @IBOutlet weak var playablePlayTimeWidth: NSLayoutConstraint!
    @IBOutlet weak var currentPlayTimeWidth: NSLayoutConstraint!
    
    private(set) var totalPlayTime: Double = 0
    private(set) var playableTime: Double = 0
    private(set) var currentPlayTime: Double = 0
    
    weak var delegate: SeekbarViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.totalPlayTimeView.layer.cornerRadius = 1
        self.playablePlayTimeView.layer.cornerRadius = 1
        self.currentPlayTimeView.layer.cornerRadius = 1
    }
    
    func setTotalPlayTime(_ totalPlayTime: Double) {
        self.totalPlayTime = totalPlayTime
        
        self.update()
    }
    
    func setPlayTime(_ playTime: Double, playableTime: Double) {
        self.currentPlayTime = playTime
        self.playableTime = playableTime
        
        self.update()
    }
    
    private func update() {
        guard self.totalPlayTime > 0 else { return }
        
        self.playablePlayTimeWidth.constant = self.widthForTime(self.playableTime)
        self.currentPlayTimeWidth.constant = self.widthForTime(self.currentPlayTime)
        
        UIView.animate(
            withDuration: 0.2,
            animations: {
                self.layoutIfNeeded()
            }
        )
    }
    
    private func widthForTime(_ time: Double) -> CGFloat {
        min(self.frame.width, self.frame.width * time / self.totalPlayTime)
    }
    
    private func widthForTouch(_ touch: UITouch) -> CGFloat {
        min(touch.location(in: self).x, self.playablePlayTimeWidth.constant)
    }
}

// MARK: - touch event handler
extension SeekbarView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        // 터치 지점 중 첫번째 (여러 손가락으로 동시 터치한 경우를 제외하기 위해)
        guard let touch = touches.first else { return }
        self.updatePlayedWidth(touch: touch)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard let touch = touches.first else { return }
        self.updatePlayedWidth(touch: touch)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard let touch = touches.first else { return }
        self.updatePlayedWidth(touch: touch)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        guard let touch = touches.first else { return }
        self.updatePlayedWidth(touch: touch)
    }
    
    private func updatePlayedWidth(touch: UITouch) {
        let xPosition = self.widthForTouch(touch)
        
        self.currentPlayTimeWidth.constant = xPosition
        
        self.delegate?.seekbar(self, seekToPercent: xPosition / self.frame.width)
    }
}
