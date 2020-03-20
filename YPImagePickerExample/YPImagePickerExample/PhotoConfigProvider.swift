//
//  PhotoConfigProvider.swift
//  YPImagePickerExample
//
//  Created by Bohdan Savych on 20.03.2020.
//  Copyright © 2020 Octopepper. All rights reserved.
//

import UIKit
import YPImagePicker

final class ImagePickerProvider {
    static func getConfiguredImagePicker(maxNumberOfItems: Int) -> YPImagePicker {
        var config = YPImagePickerConfiguration()
        config.isScrollToChangeModesEnabled = true
        config.onlySquareImagesFromCamera = false // need not square for story
        config.usesFrontCamera = false
        config.showsPhotoFilters = false
        config.showsVideoTrimmer = true
        config.shouldSaveNewPicturesToAlbum = true
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
        config.library.isSquareByDefault = true
        config.library.minWidthForItem = nil
        config.library.mediaType = YPlibraryMediaType.photoAndVideo
        config.library.defaultMultipleSelection = true
        config.library.maxNumberOfItems = maxNumberOfItems
        config.library.minNumberOfItems = 1
        config.library.numberOfItemsInRow = 4
        config.library.spacingBetweenItems = 1.0
        config.library.skipSelectionsGallery = false
        config.library.preselectedItems = []
        config.library.singleTapToDeselect = true
        
        config.video.fileType = .mp4
        config.video.recordingTimeLimit = 60.0
        config.video.libraryTimeLimit = 60.0
        config.video.trimmerMaxDuration = 60.0
        config.video.trimmerMinDuration = 3.0
        
        config.gallery.hidesRemoveButton = false
        
        return YPImagePicker(configuration: config)
    }
}
