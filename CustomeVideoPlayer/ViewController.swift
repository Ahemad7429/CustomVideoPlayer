//
//  ViewController.swift
//  CustomeVideoPlayer
//
//  Created by AhemadAbbas Vagh on 04/02/19.
//  Copyright © 2019 AhemadAbbas Vagh. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var videoView: UIView!
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var videoDurationLabel: UILabel!
    var isVideoPlaying = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let url = URL(string: "https://www.quirksmode.org/html5/videos/big_buck_bunny.mp4")
        player = AVPlayer(url: url!)
        player.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new,.initial], context: nil)
        addTimeObserver()
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resize
        
        videoView.layer.addSublayer(playerLayer)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = videoView.bounds
    }
    
    func addTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQueue = DispatchQueue.main
        
        _ = player.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue, using: { [weak self] time in
            guard let currentItem = self?.player.currentItem else { return }
            self?.timeSlider.maximumValue = Float(currentItem.duration.seconds)
            self?.timeSlider.minimumValue = 0
            self?.timeSlider.value = Float(currentItem.currentTime().seconds)
            self?.currentTimeLabel.text = self?.getTimeString(from: currentItem.currentTime())
        })
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "duration", let duration = player.currentItem?.duration.seconds, duration > 0.0 {
            videoDurationLabel.text = getTimeString(from: player.currentItem!.duration)
        }
    }

    @IBAction func playButtonWasTapped(_ sender: UIButton) {
        
        if isVideoPlaying {
            player.pause()
            sender.setTitle("Play", for: .normal)
        } else {
            player.play()
            sender.setTitle("Pause", for: .normal)
        }
        
        isVideoPlaying = !isVideoPlaying
    }
    @IBAction func forwardButtonWasTapped(_ sender: UIButton) {
        guard let duration = player.currentItem?.duration else {
            return
        }
        
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = currentTime + 5.0
        
        if newTime < (CMTimeGetSeconds(duration) - 5.0) {
            let time:CMTime = CMTimeMake(value: Int64(newTime * 1000), timescale: 1000)
            player.seek(to: time)
        }
    }
    
    @IBAction func backWardButtonWasTapped(_ sender: UIButton) {
        let currentTime = CMTimeGetSeconds(player.currentTime())
        var newTime = currentTime - 5.0
        
        if newTime < 0 {
            newTime = 0
        }
        
        let time:CMTime = CMTimeMake(value: Int64(newTime * 1000), timescale: 1000)
        player.seek(to: time)
    }
    
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        player.seek(to: CMTimeMake(value: Int64(sender.value * 1000), timescale: 1000))
    }
    
    
    func getTimeString(from time: CMTime) -> String {
        let totalSeconds = CMTimeGetSeconds(time)
        let hours = Int(totalSeconds / 3600)
        let minutes = Int(totalSeconds / 60) % 60
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return String(format: "%i:%02i:%02i", arguments: [hours,minutes,seconds])
        } else {
            
            return String(format: "%02i:%02i", arguments: [minutes,seconds])
        }
    }
}

