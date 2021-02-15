//
//  PHAsset+Extensions.swift
//  YPImagePicker
//
//  Created by Maksym Ivanyk on 15.02.2021.
//  Copyright © 2021 Yummypets. All rights reserved.
//

import Photos

extension PHAsset {
    func getVideoExtension() -> String? {
        let assetResources = PHAssetResource.assetResources(for: self)
        
        if let resource = assetResources.first {
            if (resource.originalFilename.uppercased().hasSuffix("MOV")) {
                return "mov"
            } else if (resource.originalFilename.uppercased().hasSuffix("MP4")) {
                return "mp4"
            } else if (resource.originalFilename.uppercased().hasSuffix("WEBM")) {
                return "webm"
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}
