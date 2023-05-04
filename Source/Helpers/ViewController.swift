//
//  ViewController.swift
//  YPImagePicker
//
//  Created by Andrii Hanets on 28.04.2023.
//  Copyright © 2023 Yummypets. All rights reserved.
//

import UIKit

open class BaseViewController: UIViewController {
    var orientation: UIDeviceOrientation { UIDevice.current.orientation }
    private var savedOrientation = UIDeviceOrientation.portrait
    private(set) var shouldChangeOrientation = false
    private(set) var rotationInProgress = false
  
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        savedOrientation = orientation
        
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    // MARK: - Lifecycle
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard shouldChangeOrientation else { return }

        orientationDidChanged()
        shouldChangeOrientation = false
    }
    
    open override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        savedOrientation = orientation
        
        orientationDidChanged()
        shouldChangeOrientation = false
    }
    
    open override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        rotationInProgress = true
    }
    
    open override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        rotationInProgress = false
    }
    
    // MARK: - Override point
    func orientationDidChanged() { }
    
    
    @objc private func rotated() {
        shouldChangeOrientation = savedOrientation != orientation && view.window == nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
