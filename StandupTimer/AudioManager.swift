//
//  AudioManager.swift
//  manforyou_iOS
//
//  Created by Maroš Novák on 16/08/2018.
//  Copyright © 2018 GoodRequest. All rights reserved.
//

import AVFoundation

enum Sound {
    
    case start
    case halfTime
    case almostUp
    case timeUp
    
    var url: URL {
        var fileName: String?
        switch self {
        case .start:
            fileName = "TV.wav"
        case .halfTime:
            fileName = "ding.wav"
        case .almostUp:
            fileName = "tribal.wav"
        case .timeUp:
            fileName = "beep.wav"
        }
        let path = Bundle.main.path(forResource: fileName, ofType: nil)!
        return URL(fileURLWithPath: path)
    }
    
}

final class AudioManager {
    
    private var ringtonePlayer: AVAudioPlayer?
    private var soundPlayer: AVAudioPlayer?
    
    public static let shared = AudioManager()
    
    func playSound(event: Sound) {
        do {
            stopRinging()
            self.soundPlayer = try AVAudioPlayer(contentsOf: event.url)
            self.soundPlayer?.numberOfLoops = 0
            self.soundPlayer?.play()
        } catch {
            print("Couldn't load ringtone sound")
        }
    }
    
    func ring(event: Sound) {
        do {
            stopRinging()
            self.ringtonePlayer = try AVAudioPlayer(contentsOf: event.url)
            ringtonePlayer?.setVolume(AVAudioSession.sharedInstance().outputVolume, fadeDuration: 10.0)
            self.ringtonePlayer?.play()
        } catch {
            print("Couldn't load ringtone sound")
        }
    }
    
    func stopRinging() {
        self.ringtonePlayer?.stop()
    }
    
}
