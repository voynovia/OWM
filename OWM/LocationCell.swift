//
//  TableViewCell.swift
//  OWM
//
//  Created by Igor Voynov on 14.12.16.
//  Copyright © 2016 Igor Voynov. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel! { didSet { timeLabel.textColor = UIColor.white } }
    @IBOutlet weak var cityLabel: UILabel! { didSet { cityLabel.textColor = UIColor.white } }
    @IBOutlet weak var tempLabel: UILabel! { didSet { tempLabel.textColor = UIColor.white } }
    
    var location: CityViewModel? {
        didSet {
            updateUI()
        }
    }
    
    fileprivate func updateUI() {
        timeLabel?.text = nil
        cityLabel?.text = nil
        tempLabel?.text = nil
        
        if let location = self.location {
            timeLabel?.text = location.time
            cityLabel?.text = location.name
            tempLabel?.text = String(Int(location.temp))
        }
        
    }
    
}
