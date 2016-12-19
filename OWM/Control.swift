//
//  Control.swift
//  OWM
//
//  Created by Igor Voynov on 15.12.16.
//  Copyright © 2016 Igor Voynov. All rights reserved.
//

import UIKit

class Control: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        drawLine(start: CGPoint(x: 0, y: 0), end: CGPoint(x: self.bounds.maxX, y: 0)).stroke()
    }

}
