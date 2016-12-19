//
//  Extensions.swift
//  OWM
//
//  Created by Igor Voynov on 15.12.16.
//  Copyright © 2016 Igor Voynov. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    
    func set(text: String, size: CGFloat, alignment: NSTextAlignment ) {
        self.textAlignment = alignment
        self.font = UIFont.systemFont(ofSize: size, weight: UIFontWeightLight)
        self.textColor = UIColor.white
        self.text = text
    }
    
}

extension String {
    func toChar(from: String) -> String? {
        let index = range(of: from)?.lowerBound
        return substring(to: index!)
    }
}

extension UIView {
    
    func drawLine(start: CGPoint, end: CGPoint, lineWidth: CGFloat = 1.0) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        path.lineWidth = lineWidth
        UIColor.white.setStroke()
        return path
    }
    
    func addLabels(name: String, value: String, fontSize: CGFloat) {
        let textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.width / 2 - 5, height: self.bounds.height))
        textLabel.set(text: name, size: fontSize, alignment: .right)
        self.addSubview(textLabel)
        
        let valueLabel = UILabel(frame: CGRect(x: self.bounds.width / 2 + 5, y: 0, width: self.bounds.width / 2 - 5, height: self.bounds.height))
        valueLabel.set(text: value, size: fontSize, alignment: .left)
        self.addSubview(valueLabel)
    }
    
}

extension DispatchQueue {
    
    static func background(delay: Double = 0.0, background: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
    
}
