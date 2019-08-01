//
//  MemberCell.swift
//  StandupTimer
//
//  Created by Andrej Jasso on 23/07/2019.
//  Copyright © 2019 Andrej Jasso. All rights reserved.
//

import UIKit

protocol MemberCellDelegate: class {

    func memberCell(_ memberCell: MemberCell, didPressPlayPauseOnButtonAt row: Int)
    
}

class MemberCell: UICollectionViewCell {
    
    // MARK: Constant
    
    // MARK: Variable
    
    var row: Int = 0
    weak var delegate: MemberCellDelegate?

    // MARK: - Outlet
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeSpentLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var wrapView: UIView!
    
    // MARK: - Init
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        contentView.layer.cornerRadius = 75
        contentView.layer.borderColor = UIColor.white.cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.shouldRasterize = true
        contentView.layer.rasterizationScale = UIScreen.main.scale
        contentView.clipsToBounds = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        photoImageView!.contentMode = .scaleAspectFill
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        guard let circularlayoutAttributes = layoutAttributes as? CircularCollectionViewLayoutAttributes else {
            return
        }
        self.layer.anchorPoint = circularlayoutAttributes.anchorPoint
        self.center.y += (circularlayoutAttributes.anchorPoint.y - 0.5) * self.bounds.height
    }
    
    // MARK: - Setup
    
    func setup(delegate: MemberCellDelegate, row: Int, memberState: MemberState) {
        self.row = row
        self.delegate = delegate
        memberState.delegate = self

        self.nameLabel.text = memberState.name
        self.photoImageView.image = memberState.photo
        
        if memberState.isTalking {
            wrapView.backgroundColor = .green
        } else if memberState.time > 0 {
            wrapView.backgroundColor = .lightGray
        } else {
            wrapView.backgroundColor = .white
        }
        playPauseButton.setImage(memberState.isTalking ? #imageLiteral(resourceName: "pause") : #imageLiteral(resourceName: "play"), for: .normal)
    }
    
    // MARK: - Action
    
    @IBAction func didPressPlayPauseButton(_ sender: UIButton) {
        delegate?.memberCell(self, didPressPlayPauseOnButtonAt: row)
    }
    
}

extension MemberCell: MemberStateDelegate {
    
    func didUpdateTime(time: Int) {
        if let formatedTime = String.timeDuration(seconds: Double(time), unitStyle: .brief) {
            timeSpentLabel.text = "time: \(formatedTime)"
        }
    }
    
    func didUpdateIsTalking(isTalking: Bool) {
        if isTalking {
            wrapView.backgroundColor = .green
        } else {
            wrapView.backgroundColor = .lightGray
        }
        playPauseButton.setImage(isTalking ? #imageLiteral(resourceName: "pause.png") : #imageLiteral(resourceName: "play.png"), for: .normal)
    }
    
}
