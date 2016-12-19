//
//  CurrentLine.swift
//  Weather
//
//  Created by Igor Voynov on 13.12.16.
//  Copyright © 2016 Igor Voynov. All rights reserved.
//

import UIKit

class CurrentLine: UIView {

    func set(minTemp: String, maxTemp: String, fontSize: CGFloat) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "eeee"
        let day = formatter.string(from: Date())
        
        let xOffset = self.bounds.width / 16
        let line = UIView(frame: CGRect(x: xOffset, y: 0, width: self.bounds.width-xOffset*2, height: self.bounds.height))
        
        let dayLabel = UILabel(frame: CGRect(x: 0, y: 0, width: line.bounds.width / 2, height: line.bounds.height))
        dayLabel.set(text: day, size: fontSize, alignment: .left)
        line.addSubview(dayLabel)

        let minLabel = UILabel(frame: CGRect(x: line.bounds.width/2+xOffset, y: 0, width: line.bounds.width/2-xOffset*3, height: line.bounds.height))
        minLabel.set(text: minTemp, size: fontSize, alignment: .right)
        line.addSubview(minLabel)
        
        let maxLabel = UILabel(frame: CGRect(x: line.bounds.width-xOffset*3, y: 0, width: xOffset*3, height: line.bounds.height))
        maxLabel.set(text: maxTemp, size: fontSize, alignment: .right)
        line.addSubview(maxLabel)

        self.addSubview(line)
        
    }

}
