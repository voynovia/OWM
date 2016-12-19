//
//  ViewController.swift
//  OWM
//
//  Created by Igor Voynov on 11.12.16.
//  Copyright © 2016 Igor Voynov. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var weather = OpenWeatherMap()
    
    var imageView: UIImageView!
    var header: UIView!
    var foreground: UIScrollView!
    var hourly: Hourly!
    var days: UIView!
    var currentView: UIView!
    
    var townLabel: UILabel!
    var tempLabel: UILabel!
    var detailLabel: UILabel!
    var currentLine: CurrentLine!
    
    var partHeight: CGFloat!
    var halfPartHeight: CGFloat!
    var quarterPartHeight: CGFloat!
    
    var fontSizeTemp: CGFloat!
    var fontSizeCity: CGFloat!
    var fontSizeText: CGFloat!
    var fontSizeHour: CGFloat!
    
    var idLocation: Int?
    var country: String!
    
    func setSize() {
        let parts = 7
        self.partHeight = view.frame.height / CGFloat(parts)
        self.halfPartHeight = self.partHeight / 2
        self.quarterPartHeight = self.partHeight / 4
        
        fontSizeTemp = round(partHeight * 4 / 3)
        fontSizeCity = round(halfPartHeight * 3 / 4)
        fontSizeText = round(quarterPartHeight * 2 / 3)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weather.delegate = self
        
        let bgImage = UIImageView(image: #imageLiteral(resourceName: "backgroundImage"))
        bgImage.frame = self.view.bounds
        bgImage.contentMode = UIViewContentMode.scaleAspectFit
        self.view.addSubview(bgImage)
        self.view.backgroundColor = UIColor.clear
        
        setUIProgramaticaly()
        
        if let id = idLocation {
            DispatchQueue.background(background: {
                self.weather.get(id: id)
            })
            
            updateCurrentInfo()
            updateForecastInfo()
            updateForecastDailyInfo()
        }
    }
    
    func setUIProgramaticaly() {
     
        setSize()
                
        // Заголовок
        // ------------------------------------------------------------------
        
        header = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.midY))
        townLabel = UILabel(frame: CGRect(x: 0, y: halfPartHeight, width: view.frame.width, height: halfPartHeight))
        header.addSubview(townLabel)
        detailLabel = UILabel(frame: CGRect(x: 0, y: partHeight, width: view.frame.width, height: quarterPartHeight))
        header.addSubview(detailLabel)
        tempLabel = UILabel(frame: CGRect(x: 0, y: partHeight + halfPartHeight, width: view.frame.width, height: partHeight))
        header.addSubview(tempLabel)
        view.addSubview(header)
        
        // Плавающая часть
        // ------------------------------------------------------------------
        
        foreground = UIScrollView(frame: view.bounds)
        var heightForeground: CGFloat = 0.0 // счетчик по оси Y
        
        foreground.backgroundColor = UIColor.clear
        foreground.autoresizingMask = UIViewAutoresizing.flexibleHeight
        foreground.showsVerticalScrollIndicator = false
        
        currentLine = CurrentLine(frame: CGRect(x: 0, y: view.bounds.midY-quarterPartHeight, width: view.bounds.width, height: quarterPartHeight))
        foreground.addSubview(currentLine)
        heightForeground+=view.bounds.midY
        
        hourly = Hourly(frame: CGRect(x: 0, y: heightForeground, width: view.bounds.width, height: partHeight))
        foreground.addSubview(hourly)
        heightForeground+=hourly.frame.height
        
        days = Days(frame: CGRect(x: 0, y: heightForeground, width: view.bounds.width, height: quarterPartHeight*10))
        foreground.addSubview(days)
        heightForeground+=days.frame.height
        
        currentView = UIView(frame: CGRect(x: 0, y: heightForeground, width: view.bounds.width, height: quarterPartHeight * 6))
        foreground.addSubview(currentView)
        heightForeground+=currentView.frame.height
        
        foreground.contentSize = CGSize(width: view.bounds.width, height: heightForeground+quarterPartHeight)

        view.addSubview(foreground)
        foreground.delegate = self
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

extension DetailViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = foreground.contentSize.height - foreground.bounds.height
        let percentageScroll = foreground.contentOffset.y / offset
        foreground.bounces = (percentageScroll < 0.9)
        
        // расстояние до скрываемого элемента
        let length = view.bounds.midY - tempLabel.frame.maxY
        
        // Скрываем температуру и текущий день
        if foreground.contentOffset.y > 0 && foreground.contentOffset.y < length {
            let perc = foreground.contentOffset.y / length
            tempLabel.alpha = abs(perc-1)
            currentLine.alpha = abs(perc-1)
        } else if foreground.contentOffset.y > length {
            tempLabel.alpha = 0
            currentLine.alpha = 0
        }
    }
    
}
