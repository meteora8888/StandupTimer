//
//  ViewController.swift
//  StandupTimer
//
//  Created by Andrej Jasso on 17/07/2019.
//  Copyright © 2019 Andrej Jasso. All rights reserved.
//

import UIKit
import Foundation
import AVKit

enum Badge: String {

    case rychly = "Rychlovečka"
    case pomaly = "Slow"
    case normal = "Good Time"

}

class ViewController: UIViewController {
    
    var members = [MemberState]()
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!

    let reuseIdentifier = "MemberCell"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var timeLabel: UILabel!
    weak private var meetingTimer: Timer?
    
    var activeState: MemberState?
    
    private var timeCount = 0 {
        didSet {
            if let formatedTime = String.timeDuration(seconds: Double(timeCount), unitStyle: .brief) {
                timeLabel.text = "time: \(formatedTime)"
            }
            if let memberState = activeState, memberState.isTalking {
                memberState.time += 1
                collectionView.indexPathsForVisibleItems.forEach({indexPath in
                    guard let cell = collectionView.cellForItem(at: indexPath) as?
                        MemberCell else { return }
                    cell.setup(delegate: self, row: indexPath.row, memberState: members[indexPath.row])
                })
            }
        }
    }
    
    private func getBadges(time: Int) -> [Badge] {
        var badges = [Badge]()
        if time > 0 && time < 100 {
            badges.append(.rychly)
        } else if time > 100 && time < 600 {
            badges.append(.normal)
        } else if time > 600{
            badges.append(.rychly)
        }
        return badges
    }
    
    private lazy var isTimerValid: Bool = {
        return meetingTimer?.isValid ?? false
    }()
    
    @IBAction func clear(_ sender: Any) {
        presentAlert(title: "Vymazať data", message: "Naozaj chcete zmazať všetky data ktoré boli uložené", alertButtons: [(AlertButtonType.ok, completion: { [weak self] _ in
            guard let `self` = self else { return }
            self.clearData()
        }), (AlertButtonType.cancel, completion: nil)])
    }
    
    @IBAction func start(_ sender: Any) {
        if meetingTimer == nil {
            self.meetingTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.secondPassed), userInfo: nil, repeats: true)
            self.view.backgroundColor = .black
            self.collectionView.backgroundColor = .black
            self.tableView.backgroundColor = .black
        } else {
            presentAlert(title: "Chybička poradia operácii", message: "Timer už beží. Ak chcete timer zapnút odzačiatku treba najskor vymazať data ktore boli už zaznamenané.")
        }
    }
    
    @IBAction func done(_ sender: Any) {
        presentAlert(title: "Uložiť data?", message: "Naozaj chcete uložiť všetky data a vygenerovať štatistiku?", alertButtons: [(AlertButtonType.ok, completion: { [weak self] _ in
            guard let `self` = self else { return }
            self.createStatistic()
        }), (AlertButtonType.cancel, completion: nil)])
    }
    
    func createStatistic() {
        var result = "meeting time:\(timeLabel.text ?? "00:00") (\(timeCount)\n)"
        members.forEach({ member in
            let badges = getBadges(time: member.time)
            result.append("\(member.name): \(String.timeDuration(seconds: Double(member.time), unitStyle: .brief) ?? "00:00"))(\(member.time)), vyznamenania: \(badges.first?.rawValue ?? "Žiadne")\n")
        })
        self.meetingTimer?.invalidate()
        tableView.reloadData()
        DispatchQueue.main.async {
            self.shareOnlyText(text: result)
        }
        self.view.backgroundColor = .white
        self.collectionView.backgroundColor = .white
        self.tableView.backgroundColor = .white
    }
    
    func shareOnlyText(text: String) {
        let textShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textShare , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func clearData() {
        self.timeCount = 0
        self.meetingTimer?.invalidate()
        self.meetingTimer = nil
        self.members = MembersEnum.allCases.map{MemberState(name: $0.name, photo: $0.photo, email: $0.email)}
        collectionView.reloadData()
        self.view.backgroundColor = .white
        self.collectionView.backgroundColor = .white
        self.tableView.backgroundColor = .white
        self.activeState = nil
        tableView.reloadData()
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        
        let activityItem = audioRecorder.url
        
        let activityVC = UIActivityViewController(activityItems: [activityItem],applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        
        self.present(activityVC, animated: true, completion: nil)
        
        audioRecorder = nil
    }
    
   
    
    @objc func recordTapped() {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    @objc func secondPassed() {
        timeCount += 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
        self.members = MembersEnum.allCases.map{MemberState(name: $0.name, photo: $0.photo, email: $0.email)}
    }
    
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as? MemberCell else {
            return UICollectionViewCell()
        }
        cell.setup(delegate: self, row: indexPath.row, memberState: members[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MembersEnum.allCases.count
    }
    
}

extension ViewController: MemberCellDelegate {
    
    func memberCell(_ memberCell: MemberCell, didPressPlayPauseOnButtonAt row: Int) {
        recordTapped()
        if timeCount > 0 {
            if let activeState = activeState, activeState.name == members[row].name {
                activeState.isTalking.toggle()
            } else {
                if let activeState = activeState {
                    activeState.isTalking = false
                    activeState.delegate = nil
                }
                self.activeState = members[row]
                self.activeState?.delegate = memberCell
                self.activeState?.isTalking.toggle()
            }
        }
    }
    
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MembersEnum.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath as IndexPath) as UITableViewCell
        cell.textLabel?.text = members[indexPath.row].name
        let badges = getBadges(time: members[indexPath.row].time)
        cell.detailTextLabel?.text = "\(String.timeDuration(seconds: Double(members[indexPath.row].time), unitStyle: .brief) ?? "00:00"), vyznamenania: \((badges.first?.rawValue) ?? "Zatiaľ žiadne")"
        return cell
    }
    
}

extension ViewController: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
}
