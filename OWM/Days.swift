//
//  Days.swift
//  Weather
//
//  Created by Igor Voynov on 13.12.16.
//  Copyright © 2016 Igor Voynov. All rights reserved.
//

import UIKit

class Days: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        drawLine(start: CGPoint(x: 0, y: self.bounds.maxY), end: CGPoint(x: self.bounds.maxX, y: self.bounds.maxY)).stroke()
    }
    
}
