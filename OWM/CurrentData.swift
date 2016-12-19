//
//  Current.swift
//  OWM
//
//  Created by Igor Voynov on 12.12.16.
//  Copyright © 2016 Igor Voynov. All rights reserved.
//

import Foundation
import RealmSwift

class CurrentData: Object {

    dynamic var idWeather = 0
    
    // current weather
    dynamic var dt = 0
    dynamic var sunrise = 0
    dynamic var sunset = 0
    dynamic var temp = 0.0
    dynamic var tempMin = 0.0
    dynamic var tempMax = 0.0
    dynamic var humidity = 0
    dynamic var pressure = 0
    dynamic var windSpeed = 0.0
    dynamic var windDeg = 0.0
    dynamic var icon: String!
    dynamic var desc: String!
    
    override static func primaryKey() -> String? {
        return "idWeather"
    }
}
