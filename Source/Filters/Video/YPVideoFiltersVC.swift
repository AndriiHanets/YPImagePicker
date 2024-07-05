//
//  VideoFiltersVC.swift
//  YPImagePicker
//
//  Created by Nik Kov || nik-kov.com on 18.04.2018.
//  Copyright © 2018 Yummypets. All rights reserved.
//

import UIKit
import Photos
import Stevia

public final class YPVideoFiltersVC: BaseViewController, IsMediaFilterVC {
    
    /// Designated initializer
    public class func initWith(configuration: YPVideoEditorConfiguration) -> YPVideoFiltersVC {
        let vc = YPVideoFiltersVC()
        
        vc.configuration = configuration
        vc.inputVideo = configuration.video
        
        return vc
    }
    
    // MARK: - Public vars
    
    public var configuration: YPVideoEditorConfiguration!
    
    public var inputVideo: YPMediaVideo!
    public var inputAsset: AVAsset { return AVAsset(url: inputVideo.url) }
    public var didSave: ((YPMediaItem) -> Void)?
    public var didCancel: (() -> Void)?
    
    // MARK: - Private vars
    
    private var playbackTimeCheckerTimer: Timer?
    private var imageGenerator: AVAssetImageGenerator?
    
    private let trimmerContainerView: UIView = {
        let v = UIView()
        return v
    }()
    private let trimmerView: TrimmerView = {
        let v = TrimmerView()
        
        v.maskColor = YPConfig.colors.filterBackgroundColor
        v.mainColor = YPConfig.colors.trimmerMainColor
        v.handleColor = YPConfig.colors.trimmerHandleColor
        v.positionBarColor = YPConfig.colors.positionLineColor
        v.maxDuration = YPConfig.video.trimmerMaxDuration
        v.minDuration = YPConfig.video.trimmerMinDuration
        return v
    }()
    private let coverThumbSelectorView: ThumbSelectorView = {
        let v = ThumbSelectorView()
        v.thumbBorderColor = YPConfig.colors.coverSelectorBorderColor
        v.isHidden = true
        return v
    }()
    private let bottomMenuStackView: UIStackView = {
        let v = UIStackView()
        v.axis = .horizontal
        v.distribution = .fillEqually
        return v
    }()
    private let trimBottomItem: YPMenuItem = {
        let v = YPMenuItem()
        v.textLabel.text = YPConfig.wordings.trim
        v.button.addTarget(self, action: #selector(selectTrim), for: .touchUpInside)
        return v
    }()
    private let coverBottomItem: YPMenuItem = {
        let v = YPMenuItem()
        v.textLabel.text = YPConfig.wordings.cover
        v.button.addTarget(self, action: #selector(selectCover), for: .touchUpInside)
        return v
    }()
    private let videoView: YPVideoView = {
        let v = YPVideoView()
        return v
    }()
    private let coverImageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        v.isHidden = true
        return v
    }()
    
    var activeScreen: YPVideoEditorScreen!
    
    // MARK: - Live cycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupPages()
        view.backgroundColor = YPConfig.colors.filterBackgroundColor
        setupNavigationBar()
        
        // Remove the default and add a notification to repeat playback from the start
        videoView.removeReachEndObserver()
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(itemDidFinishPlaying(_:)),
                         name: .AVPlayerItemDidPlayToEndTime,
                         object: nil)
        
        // Set initial video cover
        imageGenerator = AVAssetImageGenerator(asset: self.inputAsset)
        imageGenerator?.appliesPreferredTrackTransform = true
        imageGenerator?.requestedTimeToleranceAfter = CMTime.zero
        imageGenerator?.requestedTimeToleranceBefore = CMTime.zero
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        trimmerView.asset = inputAsset
        trimmerView.delegate = self
        
        coverThumbSelectorView.delegate = self
        coverThumbSelectorView.asset = inputAsset
        
        if inputAsset.duration.seconds < configuration.video.thumbnailTime.seconds {
            coverThumbSelectorView.setInitialPosition(time: .zero)
        } else {
            coverThumbSelectorView.setInitialPosition(time: configuration.video.thumbnailTime)
        }
        
        videoView.loadVideo(inputVideo)
        videoView.pause()
        
        super.viewDidAppear(animated)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopPlaybackTimeChecker()
        videoView.stop()
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        if configuration.isFromSelectionVC {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: YPConfig.wordings.cancel,
                                                               style: .plain,
                                                               target: self,
                                                               action: #selector(cancel))
            navigationItem.leftBarButtonItem?.setFont(font: YPConfig.fonts.leftBarButtonFont, forState: .normal)
        }
        setupRightBarButtonItem()
    }
    
    private func setupRightBarButtonItem() {
        let rightBarButtonTitle = configuration.isFromSelectionVC
            ? YPConfig.wordings.done
            : YPConfig.wordings.next
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: rightBarButtonTitle,
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(save))
        navigationItem.rightBarButtonItem?.tintColor = YPConfig.colors.tintColor
        navigationItem.rightBarButtonItem?.setFont(font: YPConfig.fonts.rightBarButtonFont, forState: .normal)
    }
    
    private func setupLayout() {
        view.sv(
            bottomMenuStackView,
            videoView,
            coverImageView,
            trimmerContainerView.sv(
                trimmerView,
                coverThumbSelectorView
            )
        )
        [trimBottomItem, coverBottomItem].forEach { bottomMenuStackView.addArrangedSubview($0) }
        
        //        trimBottomItem.leading(0).height(40)
        //        trimBottomItem.Bottom == view.safeAreaLayoutGuide.Bottom
        //        trimBottomItem.Trailing == coverBottomItem.Leading
        //        coverBottomItem.Bottom == view.safeAreaLayoutGuide.Bottom
        //        coverBottomItem.trailing(0)
        
        bottomMenuStackView.leading(0).trailing(0).height(40)
        bottomMenuStackView.Bottom == view.safeAreaLayoutGuide.Bottom
        
        //        equal(sizes: trimBottomItem, coverBottomItem)
        
        videoView.fillHorizontally().top(0)
        videoView.Bottom == trimmerContainerView.Top
        
        coverImageView.followEdges(videoView)
        
        trimmerContainerView.heightAnchor.constraint(equalToConstant: 220).isActive = true
        trimmerContainerView.fillHorizontally()
        trimmerContainerView.Top == videoView.Bottom
        trimmerContainerView.Bottom == bottomMenuStackView.Top
        
        trimmerView.centerVertically().centerHorizontally()
        trimmerView.Height == trimmerContainerView.Height * 0.5
        trimmerView.leading(30).trailing(30)
        
        coverThumbSelectorView.followEdges(trimmerView)
    }
    
    private func setupPages() {
        trimBottomItem.isHidden = true
        coverBottomItem.isHidden = true
        
        let screens = configuration.screens
        
        screens.forEach {
            switch $0 {
            case .trim:
                trimBottomItem.isHidden = false
            case .coverPicker:
                coverBottomItem.isHidden = false
            }
        }
        bottomMenuStackView.isHidden = bottomMenuStackView.arrangedSubviews.filter { !$0.isHidden }.count < 2
        
        activeScreen = configuration.startOnScreen
        updateScreenState(activeScreen)
    }
    
    // MARK: - Actions
    
    @objc private func save() {
        guard let didSave = didSave else {
            return ypLog("Don't have saveCallback")
        }
        
        navigationItem.rightBarButtonItem = YPLoaders.defaultLoader
        
        let thumbnail = coverImageView.image ?? UIImage()
        let thumbnailOrigin = inputVideo.thumbnailOrigin
        let coverTime = getCoverTimeAccordingToTrimmerBounds()
        let thumbnailTimestampMs = Int((coverTime.seconds) * 1000)
        let asset = inputVideo.asset
        
        if trimmerView.startTime == CMTime.zero && trimmerView.endTime == inputAsset.duration {
            let resultVideo = YPMediaVideo(
                thumbnail: thumbnail,
                thumbnailOrigin: thumbnailOrigin,
                thumbnailTimestampMs: thumbnailTimestampMs,
                videoURL: inputVideo.url,
                asset: asset
            )
            didSave(YPMediaItem.video(v: resultVideo))
            setupRightBarButtonItem()
        } else {
            do {
                let asset = AVURLAsset(url: inputVideo.url)
                let trimmedAsset = try asset
                    .assetByTrimming(startTime: trimmerView.startTime ?? CMTime.zero,
                                     endTime: trimmerView.endTime ?? inputAsset.duration)
                
                // Looks like file:///private/var/mobile/Containers/Data/Application
                // /FAD486B4-784D-4397-B00C-AD0EFFB45F52/tmp/8A2B410A-BD34-4E3F-8CB5-A548A946C1F1.mov
                let destinationURL = URL(fileURLWithPath: NSTemporaryDirectory())
                    .appendingUniquePathComponent(pathExtension: YPConfig.video.fileType.fileExtension)
                
                _ = trimmedAsset.export(to: destinationURL) { [weak self] session in
                    switch session.status {
                    case .completed:
                        DispatchQueue.main.async {
                            let resultVideo = YPMediaVideo(
                                thumbnail: thumbnail,
                                thumbnailOrigin: thumbnailOrigin,
                                thumbnailTimestampMs: thumbnailTimestampMs,
                                videoURL: destinationURL,
                                isTrimmed: true
                            )
                            (self?.inputVideo.url).map { try? FileManager.default.removeItem(at: $0) }
                            didSave(YPMediaItem.video(v: resultVideo))
                            self?.setupRightBarButtonItem()
                        }
                    case .failed:
                        ypLog("Export of the video failed. Reason: \(String(describing: session.error))")
                    default:
                        ypLog("Export session completed with \(session.status) status. Not handled")
                    }
                }
            } catch let error {
                ypLog("Error: \(error)")
            }
        }
    }
    
    @objc private func cancel() {
        didCancel?()
    }
    
    // MARK: - Bottom buttons
    
    @objc private func selectTrim() {
        guard configuration.screens.contains(.trim) else { return }
        
        updateScreenState(.trim)
    }
    
    @objc private func selectCover() {
        guard configuration.screens.contains(.coverPicker) else { return }
        
        updateScreenState(.coverPicker)
    }

    func updateScreenState(_ screen: YPVideoEditorScreen) {
        activeScreen = screen
        
        switch screen {
        case .trim:
            title = YPConfig.wordings.trim
            trimBottomItem.select()
            trimmerView.isHidden = false
            videoView.isHidden = false
            
            coverBottomItem.deselect()
            coverImageView.isHidden = true
            coverThumbSelectorView.isHidden = true
        case .coverPicker:
            title = YPConfig.wordings.cover
            coverBottomItem.select()
            coverImageView.isHidden = false
            coverThumbSelectorView.isHidden = false
            
            trimBottomItem.deselect()
            trimmerView.isHidden = true
            videoView.isHidden = true
            
            stopPlaybackTimeChecker()
            videoView.stop()
        }
    }
    
    // MARK: - Various Methods
    
    // Updates the bounds of the cover picker if the video is trimmed
    // TODO: Now the trimmer framework doesn't support an easy way to do this.
    // Need to rethink a flow or search other ways.
    private func updateCoverPickerBounds() {
        coverThumbSelectorView.setInitialPosition(time: getCoverTimeAccordingToTrimmerBounds())
    }
    
    func getCoverTimeAccordingToTrimmerBounds() -> CMTime {
        guard
            let startTime = trimmerView.startTime,
            let endTime = trimmerView.endTime,
            let selectedCoverTime = coverThumbSelectorView.selectedTime
        else { return .zero }
        
        if CMTimeCompare(selectedCoverTime, startTime) == -1 {
            return startTime
        }
        
        if CMTimeCompare(endTime, selectedCoverTime) == -1 {
            return endTime
        }
        
        return selectedCoverTime
    }
    
    // MARK: - Trimmer playback
    
    @objc private func itemDidFinishPlaying(_ notification: Notification) {
        if let startTime = trimmerView.startTime {
            videoView.player.seek(to: startTime)
        }
    }
    
    private func startPlaybackTimeChecker() {
        stopPlaybackTimeChecker()
        playbackTimeCheckerTimer = Timer
            .scheduledTimer(timeInterval: 0.05, target: self,
                            selector: #selector(onPlaybackTimeChecker),
                            userInfo: nil,
                            repeats: true)
    }
    
    private func stopPlaybackTimeChecker() {
        playbackTimeCheckerTimer?.invalidate()
        playbackTimeCheckerTimer = nil
    }
    
    @objc private func onPlaybackTimeChecker() {
        guard let startTime = trimmerView.startTime,
            let endTime = trimmerView.endTime else {
            return
        }
        
        let playBackTime = videoView.player.currentTime()
        trimmerView.seek(to: playBackTime)
        
        if playBackTime >= endTime {
            videoView.player.seek(to: startTime,
                                  toleranceBefore: CMTime.zero,
                                  toleranceAfter: CMTime.zero)
            trimmerView.seek(to: startTime)
        }
    }
}

// MARK: - TrimmerViewDelegate
extension YPVideoFiltersVC: TrimmerViewDelegate {
    public func positionBarStoppedMoving(_ playerTime: CMTime) {
        videoView.player.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        videoView.play()
        startPlaybackTimeChecker()
        updateCoverPickerBounds()
    }
    
    public func didChangePositionBar(_ playerTime: CMTime) {
        stopPlaybackTimeChecker()
        videoView.pause()
        videoView.player.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }
}

// MARK: - ThumbSelectorViewDelegate
extension YPVideoFiltersVC: ThumbSelectorViewDelegate {
    public func didChangeThumbPosition(_ imageTime: CMTime) {
        imageGenerator?.generateCGImagesAsynchronously(
            forTimes: [NSValue(time: imageTime)],
            completionHandler: { (_, cgImage, _, _, _) in
                guard let cgImage = cgImage else {
                    return
                }
                
                self.imageGenerator?.cancelAllCGImageGeneration()
                
                DispatchQueue.main.async {
                    let image = UIImage(cgImage: cgImage)
                    self.coverImageView.image = image
                    self.coverThumbSelectorView.setThumbImageView(with: image)
                    
                    if self.inputVideo.thumbnailOrigin == nil {
                        self.inputVideo.thumbnailOrigin = self.coverImageView.image
                    }
                }
            }
        )
    }
}
