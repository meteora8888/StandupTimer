//
//  Member.swift
//  StandupTimer
//
//  Created by Andrej Jasso on 21/07/2019.
//  Copyright © 2019 Andrej Jasso. All rights reserved.
//

import Foundation
import UIKit

enum MembersEnum: CaseIterable {
    
    case Palo
    case Bohus
    case Juraj
    case Lenka
    case Andrej
    case Marek
    case Dominik
    case Maros
    
    var photo: UIImage {
        switch self {
        case .Andrej:
            return #imageLiteral(resourceName: "andrej.jpg")
        case .Palo:
            return #imageLiteral(resourceName: "palo.jpg")
        case .Bohus:
            return #imageLiteral(resourceName: "bohus.jpg")
        case .Juraj:
            return #imageLiteral(resourceName: "juraj.png")
        case .Lenka:
            return #imageLiteral(resourceName: "lenka.jpg")
        case .Marek:
            return #imageLiteral(resourceName: "marek.png")
        case .Dominik:
            return #imageLiteral(resourceName: "domink.png")
        case .Maros:
            return #imageLiteral(resourceName: "maros.jpg")
        }
    }
    
    var name: String {
        switch self {
        case .Andrej:
            return "Andrej Jaššo"
        case .Palo:
            return "Pavol Kmet"
        case .Bohus:
            return "Bohuslav Kvočka"
        case .Juraj:
            return "Juraj Macák"
        case .Lenka:
            return "Lenka Janošová"
        case .Marek:
            return "Marek Špálek"
        case .Dominik:
            return "Dominik Petho"
        case .Maros:
            return "Maroš Novák"
        }
    }
    
    var email: String {
        switch self {
        case .Andrej:
            return "Andrej.Jaššo@goodrequest.com"
        case .Palo:
            return "Pavol.Kmet@goodrequest.com"
        case .Bohus:
            return "Bohuslav.Kvočka@goodrequest.com"
        case .Juraj:
            return "Juraj.Macák@goodrequest.com"
        case .Lenka:
            return "Lenka.Janošová@goodrequest.com"
        case .Marek:
            return "Marek.Špálek@goodrequest.com"
        case .Dominik:
            return "Dominik.Petho@goodrequest.com"
        case .Maros:
            return "Maroš.Novák@goodrequest.com"
        }
    }
    
}

protocol MemberStateDelegate: class {
    
    func didUpdateTime(time: Int)
    func didUpdateIsTalking(isTalking: Bool)
    
}

class MemberState {
    
    static private let audioManager = AudioManager()
    static private let totalTime = 60 * 7
    static private var halfTime = totalTime / 2
    static private var almostUpTime = totalTime - (60 * 1)
    
    var name: String
    var photo: UIImage?
    var email: String
    
    var time: Int = 0 {
        didSet {
            delegate?.didUpdateTime(time: time)
            switch time {
            case 1:
                MemberState.audioManager.playSound(event: .start)
            case MemberState.halfTime:
                MemberState.audioManager.playSound(event: .halfTime)
            case MemberState.almostUpTime:
                MemberState.audioManager.playSound(event: .almostUp)
            case MemberState.totalTime:
                MemberState.audioManager.playSound(event: .timeUp)
            default: break
            }
        }
    }
    
    var isTalking = false {
        didSet {
            delegate?.didUpdateIsTalking(isTalking: isTalking)
        }
    }
    
    init(name: String, photo: UIImage, email: String) {
        self.name = name
        self.photo = photo
        self.email = email
    }
    
    weak var delegate: MemberStateDelegate?
    
}
