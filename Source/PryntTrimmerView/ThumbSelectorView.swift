//
//  ThumbSelectorView.swift
//  Pods
//
//  Created by Henry on 06/04/2017.
//
//

import UIKit
import AVFoundation

/// A delegate to be notified of when the thumb position has changed. Useful to link an instance of the ThumbSelectorView to a
/// video preview like an `AVPlayer`.
public protocol ThumbSelectorViewDelegate: AnyObject {
    func didChangeThumbPosition(_ imageTime: CMTime)
}

/// A view to select a specific time of an `AVAsset`. It is composed of an asset preview within a scroll view, and a thumb view
/// to select a precise time of the video. Set the `asset` property to load the video, and use the `selectedTime` property to
// retrieve the exact frame of the asset that was selected.
public class ThumbSelectorView: AVAssetTimeSelector {

    public var thumbBorderColor: UIColor = .white {
        didSet {
            thumbView.layer.borderColor = thumbBorderColor.cgColor
        }
    }

    private let thumbView = UIImageView()
    private let dimmingView = UIView()

    private var leftThumbConstraint: NSLayoutConstraint?
    private var currentThumbConstraint: CGFloat = 0

    public weak var delegate: ThumbSelectorViewDelegate?

    // MARK: - View & constraints configurations

    override func setupSubviews() {
        super.setupSubviews()
        setupDimmingView()
        setupThumbView()
    }
    
    func setInitialPosition(time: CMTime) {
        let position = getPosition(from: time)
        
        delegate?.didChangeThumbPosition(time)
        leftThumbConstraint?.constant = position ?? .zero
    }
    
    func setThumbImageView(with image: UIImage) {
        thumbView.image = image
    }

    private func setupDimmingView() {

        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.isUserInteractionEnabled = false
        dimmingView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        addSubview(dimmingView)
        dimmingView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        dimmingView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        dimmingView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        dimmingView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    private func setupThumbView() {

        thumbView.translatesAutoresizingMaskIntoConstraints = false
        thumbView.layer.borderWidth = 2.0
        thumbView.layer.borderColor = thumbBorderColor.cgColor
        thumbView.isUserInteractionEnabled = true
        thumbView.contentMode = .scaleAspectFill
        thumbView.clipsToBounds = true
        addSubview(thumbView)

        leftThumbConstraint = thumbView.leftAnchor.constraint(equalTo: leftAnchor)
        leftThumbConstraint?.isActive = true
        thumbView.widthAnchor.constraint(equalTo: thumbView.heightAnchor).isActive = true
        thumbView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        thumbView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ThumbSelectorView.handlePanGesture(_:)))
        thumbView.addGestureRecognizer(panGestureRecognizer)
    }

    // MARK: - Gesture handling

    @objc func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let superView = gestureRecognizer.view?.superview else { return }

        switch gestureRecognizer.state {

        case .began:
            currentThumbConstraint = leftThumbConstraint!.constant
            updateSelectedTime()
        case .changed:

            let translation = gestureRecognizer.translation(in: superView)
            updateThumbConstraint(with: translation)
            layoutIfNeeded()
            updateSelectedTime()

        case .cancelled, .ended, .failed:
            updateSelectedTime()
        default: break
        }
    }

    private func updateThumbConstraint(with translation: CGPoint) {
        let maxConstraint = frame.width - thumbView.frame.width
        let newConstraint = min(max(0, currentThumbConstraint + translation.x), maxConstraint)
        leftThumbConstraint?.constant = newConstraint
    }

    // MARK: - Thumbnail Generation

    override func assetDidChange(newAsset: AVAsset?) {
        leftThumbConstraint?.constant = 0
        super.assetDidChange(newAsset: newAsset)
    }

    // MARK: - Time & Position Equivalence

    override var durationSize: CGFloat {
        return assetPreview.contentSize.width - thumbView.frame.width
    }

    /// The currently selected time of the asset.
    public var selectedTime: CMTime? {
        let thumbPosition = thumbView.center.x + assetPreview.contentOffset.x - (thumbView.frame.width / 2)
        return getTime(from: thumbPosition)
    }

    private func updateSelectedTime() {
        if let selectedTime = selectedTime {
            delegate?.didChangeThumbPosition(selectedTime)
        }
    }

    // MARK: - UIScrollViewDelegate

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateSelectedTime()
    }
}
