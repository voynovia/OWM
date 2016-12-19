//
//  Enums.swift
//  OWM
//
//  Created by Igor Voynov on 15.12.16.
//  Copyright © 2016 Igor Voynov. All rights reserved.
//

import Foundation

enum Duration {
    case current, forecast, forecastDaily
    
    static let forecasts = [forecast, forecastDaily]
}
