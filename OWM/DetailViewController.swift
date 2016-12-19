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
        
        let bottomOffset = halfPartHeight + quarterPartHeight
        foreground.contentSize = CGSize(width: view.bounds.width, height: heightForeground + bottomOffset)

        view.addSubview(foreground)
        foreground.delegate = self
        
        // Подвал
        // ------------------------------------------------------------------
        let footer = UIView(frame: CGRect(x: 0, y: view.bounds.height-halfPartHeight, width: view.bounds.width, height: halfPartHeight))
        
        let imageView = UIImageView(image: #imageLiteral(resourceName: "footerImage"))
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = imageView.bounds
        imageView.addSubview(blurView)
        imageView.contentMode = .scaleToFill
        footer.addSubview(imageView)
        
        let xOffset = footer.bounds.width / 16
        let citiesButton = UIButton(frame: CGRect(x: footer.bounds.width-xOffset*2, y: 0, width: xOffset, height: footer.bounds.height))
        citiesButton.setTitle("⇋", for: .normal)
        citiesButton.titleLabel?.font  = UIFont.systemFont(ofSize: 24, weight: UIFontWeightLight)
        citiesButton.setTitleColor(UIColor.white, for: .normal)
        footer.addSubview(citiesButton)
        citiesButton.addTarget(self, action: #selector(self.citiesButtonAction(_:)), for: .touchUpInside)
        
        view.addSubview(footer)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func citiesButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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
