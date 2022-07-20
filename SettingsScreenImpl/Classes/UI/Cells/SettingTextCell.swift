//
//  SettingBooleanCell.swift
//  SettingsScreenImpl
//
//  Created by Mor on 14/07/2022.
//

import Foundation
import UIKit
import Combine
import TedoooCombine

class SettingBooleanCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var mainSwitch: UISwitch!
    @IBOutlet weak var imgSetting: UIImageView!
    @IBOutlet weak var lblDescription: UILabel!
    
    var bag = CombineBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = CombineBag()
    }
    
}

class SettingTextCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imgSetting: UIImageView!
    @IBOutlet weak var viewSeparator: UIView!
    
    var bag = CombineBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = CombineBag()
    }
}
