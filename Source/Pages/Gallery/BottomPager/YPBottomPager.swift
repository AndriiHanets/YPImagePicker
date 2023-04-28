//
//  YPBottomPager.swift
//  YPImagePicker
//
//  Created by Sacha Durand Saint Omer on 27/10/16.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import UIKit
import Stevia

protocol YPBottomPagerDelegate: AnyObject {
    func pagerScrollViewDidScroll(_ scrollView: UIScrollView)
    func pagerDidSelectController(_ vc: UIViewController)
}
open class YPBottomPager: BaseViewController, UIScrollViewDelegate {
    private var isConfigured = false
    
    weak var delegate: YPBottomPagerDelegate?
    var controllers = [UIViewController]() { didSet { reload() } }
    
    var v = YPBottomPagerView()
    
    var currentPage = 0
    
    var currentController: UIViewController {
        return controllers[currentPage]
    }
    
    override open func loadView() {
        v.scrollView.contentInsetAdjustmentBehavior = .never
        v.scrollView.delegate = self
        view = v
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !rotationInProgress else { return }
        
        delegate?.pagerScrollViewDidScroll(scrollView)
    }

    public func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                          withVelocity velocity: CGPoint,
                                          targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if !v.header.menuItems.isEmpty {
            let menuIndex = (targetContentOffset.pointee.x + v.frame.size.width) / v.frame.size.width
            let selectedIndex = Int(round(menuIndex)) - 1
            if selectedIndex != currentPage {
                selectPage(selectedIndex)
            }
        }
    }
    
    func reload() {
        let screenWidth = YPImagePickerConfiguration.screenWidth
        let viewWidth: CGFloat = screenWidth
        for (index, c) in controllers.enumerated() {
            let x: CGFloat = CGFloat(index) * viewWidth
            
            if isConfigured {
                c.view.leftConstraint?.constant = x
                c.view.topConstraint?.constant = 0
                c.view.widthConstraint?.constant = viewWidth
                c.view.heightConstraint?.constant = v.scrollView.frame.height
            } else {
                c.willMove(toParent: self)
                addChild(c)
                v.scrollView.sv(c.view)
                c.didMove(toParent: self)
                c.view.left(x)
                c.view.top(0)
                c.view.width(viewWidth)
                equal(heights: c.view, v.scrollView)
            }
        }
        
        let scrollableWidth: CGFloat = CGFloat(controllers.count) * CGFloat(viewWidth)
        v.scrollView.contentSize = CGSize(width: scrollableWidth, height: 0)
        
        // Build headers
        if !isConfigured {
            for (index, c) in controllers.enumerated() {
                let menuItem = YPMenuItem()
                menuItem.textLabel.text = c.title?.capitalized
                menuItem.button.tag = index
                menuItem.button.addTarget(self,
                                          action: #selector(tabTapped(_:)),
                                          for: .touchUpInside)
                v.header.menuItems.append(menuItem)
            }
            
            let currentMenuItem = v.header.menuItems[0]
            currentMenuItem.select()
        }
        v.header.refreshMenuItems()
        
        isConfigured = true
    }
    
    @objc
    func tabTapped(_ b: UIButton) {
        showPage(b.tag)
    }
    
    func showPage(_ page: Int, animated: Bool = true) {
        let screenWidth = YPImagePickerConfiguration.screenWidth
        let x = CGFloat(page) * screenWidth
        v.scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: animated)
        selectPage(page)
    }

    func selectPage(_ page: Int) {
        guard page != currentPage && page >= 0 && page < controllers.count else {
            return
        }
        currentPage = page
        // select menu item and deselect others
        for (i, mi) in v.header.menuItems.enumerated() {
            if i == page {
                mi.select()
            } else {
                mi.deselect()
            }
        }
        delegate?.pagerDidSelectController(controllers[page])
    }
    
    func startOnPage(_ page: Int) {
        currentPage = page
        let screenWidth = YPImagePickerConfiguration.screenWidth
        let x = CGFloat(page) * screenWidth
        v.scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: false)
        // select menut item and deselect others
        for mi in v.header.menuItems {
            mi.deselect()
        }
        let currentMenuItem = v.header.menuItems[page]
        currentMenuItem.select()
    }

    override func orientationDidChanged() {
        reload()
        resetPageOffset()
    }
    
    private func resetPageOffset() {
        let newOffset = CGFloat(currentPage) * v.scrollView.frame.width
        v.scrollView.setContentOffset(CGPoint(x: newOffset, y: 0), animated: false)
    }
    
}
