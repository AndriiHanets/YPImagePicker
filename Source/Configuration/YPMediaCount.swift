//
//  YPMediaCount.swift
//  YPImagePicker
//
//  Created by Andrii Hanets on 21.10.2024.
//  Copyright © 2024 Yummypets. All rights reserved.
//

import Foundation

public enum YPMediaCount {
    case image(count: Int)
    case video(count: Int)
    case imageOrVideo(imageCount: Int, videoCount: Int)
    case imageAndVideo(count: Int)
}
