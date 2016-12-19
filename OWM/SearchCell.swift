//
//  SearchCell.swift
//  OWM
//
//  Created by Igor Voynov on 14.12.16.
//  Copyright © 2016 Igor Voynov. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {

    @IBOutlet weak var cityLabel: UILabel! { didSet { cityLabel.textColor = UIColor.white } }
    
    var city: LocationData? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        cityLabel?.text = nil
        if let city = self.city {
            cityLabel?.text = city.name + " / " + city.country
        }
    }
    
}
