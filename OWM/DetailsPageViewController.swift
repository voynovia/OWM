//
//  PageViewController.swift
//  OWM
//
//  Created by Igor Voynov on 19.12.16.
//  Copyright © 2016 Igor Voynov. All rights reserved.
//

import UIKit
import RealmSwift

class DetailsPageViewController: UIPageViewController {

    fileprivate var orderedViewControllers: [UIViewController] = [UIViewController]()
    
    weak var detailsDelegate: DetailsPageViewControllerDelegate?
    
    var idLocation: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let plist = Plist(name: "Settings") {
            let dict = plist.getMutablePlistFile()!
            dict["lastCity"] = idLocation
            do {
                try plist.addValuesToPlistFile(dict)
            } catch {
                print(error)
            }
        }
        
        let realm = try! Realm()
        for current in realm.objects(CurrentData.self) {
            let detailVC = DetailViewController()
            detailVC.idLocation = current.idWeather
            orderedViewControllers.append(detailVC)
        }
        
        let views = orderedViewControllers as! [DetailViewController]
        if let firstViewController = views.filter({$0.idLocation == idLocation}).first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
            notifyTutorialDelegateOfNewIndex()
        }
    
        detailsDelegate?.pageViewController(self, didUpdatePageCount: orderedViewControllers.count)
    }

    func scrollToViewController(index newIndex: Int) {
        if let firstViewController = viewControllers?.first,
            let currentIndex = orderedViewControllers.index(of: firstViewController) {
            let direction: UIPageViewControllerNavigationDirection = newIndex >= currentIndex ? .forward : .reverse
            let nextViewController = orderedViewControllers[newIndex]
            scrollToViewController(nextViewController, direction: direction)
        }
    }
    
    fileprivate func scrollToViewController(_ viewController: UIViewController,
                                            direction: UIPageViewControllerNavigationDirection = .forward) {
        setViewControllers([viewController],
                           direction: direction,
                           animated: true,
                           completion: { (finished) -> Void in
                            self.notifyTutorialDelegateOfNewIndex()
        })
    }
    
    fileprivate func notifyTutorialDelegateOfNewIndex() {
        if let firstViewController = viewControllers?.first,
            let index = orderedViewControllers.index(of: firstViewController) {
            detailsDelegate?.pageViewController(self, didUpdatePageIndex: index)
        }
    }
    
}

extension DetailsPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        notifyTutorialDelegateOfNewIndex()
    }
    
}

extension DetailsPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return nil
        }
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        return orderedViewControllers[nextIndex]
    }
    
}
