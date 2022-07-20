//
//  SettingHeaderCell.swift
//  SettingsScreenImpl
//
//  Created by Mor on 14/07/2022.
//

import Foundation
import UIKit
import TedoooCombine

class SettingHeaderCell: UITableViewCell {
    
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
    var bag = CombineBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = CombineBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgAvatar.layer.cornerRadius = 22
        imgAvatar.kf.indicatorType = .activity
    }
}

class AccountHeaderCell: UITableViewCell {
    
    @IBOutlet weak var loaderAvatar: UIActivityIndicatorView!
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var btnEdit: UILabel!
    @IBOutlet weak var lblName: UILabel!
    
    var bag = CombineBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgAvatar.layer.cornerRadius = 44
        imgAvatar.kf.indicatorType = .activity
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = CombineBag()
    }
    
}
