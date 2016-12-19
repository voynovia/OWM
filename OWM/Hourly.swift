//
//  Hourly.swift
//  Weather
//
//  Created by Igor Voynov on 13.12.16.
//  Copyright © 2016 Igor Voynov. All rights reserved.
//

import UIKit

class Hourly: UIScrollView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.showsHorizontalScrollIndicator = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        drawLine(start: CGPoint(x: 0, y: 0), end: CGPoint(x: self.bounds.maxX, y: 0)).stroke()
        drawLine(start: CGPoint(x: 0, y: self.bounds.maxY), end: CGPoint(x: self.bounds.maxX, y: self.bounds.maxY)).stroke()
    }

}
