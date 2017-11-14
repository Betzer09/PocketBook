//
//  AnaylsisPageViewController.swift
//  PocketBook
//
//  Created by Michael Meyers on 11/9/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

class AnaylsisPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    let pageControl = UIPageControl()
    
    lazy var orderedViewControllers: [UIViewController] = {
        return [
            UIStoryboard(name: "Analysis", bundle: nil).instantiateViewController(withIdentifier: Keys.pieCharVCIdentifier),
            UIStoryboard(name: "Analysis", bundle: nil).instantiateViewController(withIdentifier: Keys.budgetLineGraphVCIdentifier),
            UIStoryboard(name: "Analysis", bundle: nil).instantiateViewController(withIdentifier: Keys.plannedExpensesGraphVCIdentifer)
        ]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        if let firstVC = orderedViewControllers.first {
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in self.view.subviews {
            if view is UIScrollView {
                view.frame = UIScreen.main.bounds
            } else if view is UIPageControl {
                view.backgroundColor = UIColor.clear
            }
        }
    }
    
    // MARK: - PageView DataSource
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let pageContentViewController = pageViewController.viewControllers?.first,
            let currentPage = orderedViewControllers.index(of: pageContentViewController) else {return}
        self.pageControl.currentPage = currentPage
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {return nil}
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else { return orderedViewControllers.last }
        guard previousIndex < orderedViewControllers.count else { return nil }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else { return orderedViewControllers.first }
        
        guard orderedViewControllersCount > nextIndex else { return nil}
        
        return orderedViewControllers[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = orderedViewControllers.first,
            let firstViewControllerIndex = orderedViewControllers.index(of: firstViewController) else {return 0}
        return firstViewControllerIndex
    }
}
