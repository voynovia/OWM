//
//  Footer.swift
//  OWM
//
//  Created by Igor Voynov on 19.12.16.
//  Copyright © 2016 Igor Voynov. All rights reserved.
//

import UIKit

class Footer: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // add background with blur effect
        let imageView = UIImageView(image: #imageLiteral(resourceName: "footerImage"))
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = imageView.bounds
        imageView.addSubview(blurView)
        imageView.contentMode = .scaleToFill
        self.insertSubview(imageView, at: 0)
    }
    
    override func draw(_ rect: CGRect) {
        drawLine(start: CGPoint(x: 0, y: 0), end: CGPoint(x: self.bounds.maxX, y: 0)).stroke()
    }

}
