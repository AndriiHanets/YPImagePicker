//
//  YPWordings.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 12/03/2018.
//  Copyright © 2018 Yummypets. All rights reserved.
//

import Foundation

public struct YPWordings {
    
    public var permissionPopup = PermissionPopup()
    public var videoDurationPopup = VideoDurationPopup()

    public struct PermissionPopup {
        public var photoTitle = ypLocalized("YPImagePickerPermissionDeniedPopupPhotoTitle")
        public var cameraTitle = ypLocalized("YPImagePickerPermissionDeniedPopupCameraTitle")
        
        public var photoMessage = ypLocalized("YPImagePickerPermissionDeniedPopupPhotoMessage")
        public var cameraMessage = ypLocalized("YPImagePickerPermissionDeniedPopupCameraMessage")
        
        public var cancel = ypLocalized("YPImagePickerPermissionDeniedPopupCancel")
        public var grantPermission = ypLocalized("YPImagePickerPermissionDeniedPopupGrantPermission")
    }
    
    public struct VideoDurationPopup {
        public var title = ypLocalized("YPImagePickerVideoDurationTitle")
        public var tooShortMessage = ypLocalized("YPImagePickerVideoTooShort")
        public var tooLongMessage = ypLocalized("YPImagePickerVideoTooLong")
    }
    
    public var ok = ypLocalized("YPImagePickerOk")
    public var done = ypLocalized("YPImagePickerDone")
    public var cancel = ypLocalized("YPImagePickerCancel")
    public var save = ypLocalized("YPImagePickerSave")
    public var processing = ypLocalized("YPImagePickerProcessing")
    public var trim = ypLocalized("YPImagePickerTrim")
    public var cover = ypLocalized("YPImagePickerCover")
    public var albumsTitle = ypLocalized("YPImagePickerAlbums")
    public var libraryTitle = ypLocalized("YPImagePickerLibrary")
    public var cameraTitle = ypLocalized("YPImagePickerPhoto")
    public var videoTitle = ypLocalized("YPImagePickerVideo")
    public var next = ypLocalized("YPImagePickerNext")
    public var filter = ypLocalized("YPImagePickerFilter")
    public var crop = ypLocalized("YPImagePickerCrop")
    public var warningMaxPhotoOrVideoTotalLimit = ypLocalized("YPImagePickerWarningPhotoOrVideoTotalLimit")
    public var warningMaxPhotosOrVideosTotalLimit = ypLocalized("YPImagePickerWarningPhotosOrVideosTotalLimit")
    public var warningMaxPhotoAndVideoLimit = ypLocalized("YPImagePickerWarningPhotoOrVideoLimit")
    public var warningMaxPhotosAndVideosLimit = ypLocalized("YPImagePickerWarningPhotosOrVideosLimit")
    public var warningMaxPhotosAndVideoLimit = ypLocalized("YPImagePickerWarningPhotosOrVideoLimit")
    public var warningMaxPhotoAndVideosLimit = ypLocalized("YPImagePickerWarningPhotoOrVideosLimit")
    public var warningMaxVideoLimit = ypLocalized("YPImagePickerWarningVideoLimit")
    public var warningMaxPhotoLimit = ypLocalized("YPImagePickerWarningPhotoLimit")
    public var warningMaxVideosLimit = ypLocalized("YPImagePickerWarningVideosLimit")
    public var warningMaxPhotosLimit = ypLocalized("YPImagePickerWarningPhotosLimit")
}
