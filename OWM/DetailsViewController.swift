//
//  DetailsViewController.swift
//  OWM
//
//  Created by Igor Voynov on 19.12.16.
//  Copyright © 2016 Igor Voynov. All rights reserved.
//

import UIKit

protocol DetailsPageViewControllerDelegate: class {
    
    func pageViewController(_ pageViewController: DetailsPageViewController,
                            didUpdatePageCount count: Int)
    
    func pageViewController(_ pageViewController: DetailsPageViewController,
                            didUpdatePageIndex index: Int)
    
}

class DetailsViewController: UIViewController {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var footer: Footer!

    var idLocation: Int?
    
    var detailsPageViewController: DetailsPageViewController? {
        didSet {
            detailsPageViewController?.detailsDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        
        // add back button
        let xOffset = footer.bounds.width / 16
        let backButton = UIButton(frame: CGRect(x: footer.bounds.width-xOffset*2, y: 0, width: xOffset, height: footer.bounds.height))
        backButton.setTitle("⇋", for: .normal)
        backButton.titleLabel?.font  = UIFont.systemFont(ofSize: 24, weight: UIFontWeightLight)
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.addTarget(self, action: #selector(self.backButtonAction(_:)), for: .touchUpInside)
        footer.addSubview(backButton)
        
        pageControl.addTarget(self, action: #selector(self.didChangePageControlValue), for: .valueChanged)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailsPageViewController = segue.destination as? DetailsPageViewController {
            self.detailsPageViewController = detailsPageViewController
            detailsPageViewController.idLocation = idLocation
        }
    }
    
    func didChangePageControlValue() {
        detailsPageViewController?.scrollToViewController(index: pageControl.currentPage)
    }
    
    func backButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension DetailsViewController: DetailsPageViewControllerDelegate {
    internal func pageViewController(_ pageViewController: DetailsPageViewController, didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }
    
    internal func pageViewController(_ pageViewController: DetailsPageViewController, didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
    }
}
