//
//  ExampleViewController.swift
//  YPImagePickerExample
//
//  Created by Sacha DSO on 17/03/2017.
//  Copyright © 2017 Octopepper. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Photos

class ExampleViewController: UIViewController {
    var selectedItems = [YPMediaItem]()

    lazy var selectedImageV : UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0,
                                                  y: 0,
                                                  width: UIScreen.main.bounds.width,
                                                  height: UIScreen.main.bounds.height * 0.45))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    lazy var pickButton : UIButton = {
        let button = UIButton(frame: CGRect(x: 0,
                                            y: 0,
                                            width: 100,
                                            height: 100))
        button.setTitle("Pick", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(showPicker), for: .touchUpInside)
        return button
    }()

    lazy var resultsButton : UIButton = {
        let button = UIButton(frame: CGRect(x: 0,
                                            y: UIScreen.main.bounds.height - 100,
                                            width: UIScreen.main.bounds.width,
                                            height: 100))
        button.setTitle("Show selected", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(showResults), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        view.addSubview(selectedImageV)
        view.addSubview(pickButton)
        pickButton.center = view.center
        view.addSubview(resultsButton)
    }

    @objc
    func showResults() {
        if !selectedItems.isEmpty {
            let gallery = YPSelectionsGalleryVC(items: selectedItems) { g, _ in
                g.dismiss(animated: true, completion: nil)
            }
            let navC = UINavigationController(rootViewController: gallery)
            self.present(navC, animated: true, completion: nil)
        } else {
            print("No items selected yet.")
        }
    }

    // MARK: - Configuration
    @objc
    func showPicker() {
        var config = YPImagePickerConfiguration()
        config.isScrollToChangeModesEnabled = true
        config.onlySquareImagesFromCamera = false // need not square for story
        config.usesFrontCamera = false
        config.showsPhotoFilters = false
        config.showsVideoTrimmer = true
        config.shouldSaveNewPicturesToAlbum = false
        config.startOnScreen = YPPickerScreen.library
        config.screens = [.library, .photo, .video]
        config.showsCrop = .none
        config.targetImageSize = YPImageSize.original
        config.overlayView = UIView()
        config.hidesStatusBar = false
        config.hidesBottomBar = false
        config.preferredStatusBarStyle = UIStatusBarStyle.default
        config.maxCameraZoomFactor = 1.0
        
        config.library.options = nil
        config.library.onlySquare = false
        config.library.isSquareByDefault = false
        config.library.minWidthForItem = nil
        config.library.mediaType = .photoAndVideo
        config.library.defaultMultipleSelection = true
        config.library.maxNumberOfItems = 3
        config.library.minNumberOfItems = 1
        config.library.numberOfItemsInRow = 4
        config.library.spacingBetweenItems = 1.0
        config.library.skipSelectionsGallery = true
        config.library.preselectedItems = []
        config.library.singleTapToDeselect = true
        config.library.preSelectItemOnMultipleSelection = false
        
        config.video.compression = AVAssetExportPresetPassthrough
        config.video.fileType = .mov
        
        config.video.recordingTimeLimit = 100
        config.video.libraryTimeLimit = 100
        config.video.trimmerMaxDuration = 100
        config.video.trimmerMinDuration = 0
        config.video.minimumTimeLimit = 0
  
        config.gallery.hidesRemoveButton = false
        
        let picker = YPImagePicker(configuration: config)
        
        picker.didFinishPicking { [weak picker] items, cancelled in

            if cancelled {
                print("Picker was canceled")
                picker?.dismiss(animated: true, completion: nil)
                return
            }
            _ = items.map { print("🧀 \($0)") }

            self.selectedItems = items
            if let firstItem = items.first {
                switch firstItem {
                case .photo(let photo):
                    self.selectedImageV.image = photo.image
                    picker?.dismiss(animated: true, completion: nil)
                case .video(let video):
                    self.selectedImageV.image = video.thumbnail

                    let assetURL = video.url
                    let playerVC = AVPlayerViewController()
                    let player = AVPlayer(playerItem: AVPlayerItem(url:assetURL))
                    playerVC.player = player

                    picker?.dismiss(animated: true, completion: { [weak self] in
                        self?.present(playerVC, animated: true, completion: nil)
                        print("😀 \(String(describing: self?.resolutionForLocalVideo(url: assetURL)!))")
                    })
                }
            }
        }

        present(picker, animated: true, completion: nil)
    }
}

// Support methods
extension ExampleViewController {
    /* Gives a resolution for the video by URL */
    func resolutionForLocalVideo(url: URL) -> CGSize? {
        guard let track = AVURLAsset(url: url).tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
}

// YPImagePickerDelegate
extension ExampleViewController: YPImagePickerDelegate {
    func imagePickerHasNoItemsInLibrary(_ picker: YPImagePicker) {
        // PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
    }

    func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
        return true // indexPath.row != 2
    }
}

