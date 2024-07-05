//
//  YPVideoEditorConfiguration.swift
//  YPImagePicker
//
//  Created by Andrii Hanets on 04.07.2024.
//  Copyright © 2024 Yummypets. All rights reserved.
//

import Foundation

public enum YPVideoEditorScreen {
    case trim
    case coverPicker
}

public struct YPVideoEditorConfiguration {
    
    public var video: YPMediaVideo
    public var isFromSelectionVC: Bool
    public var startOnScreen: YPVideoEditorScreen
    public var screens: [YPVideoEditorScreen]
    
    public init(
        video: YPMediaVideo,
        isFromSelectionVC: Bool,
        screens: [YPVideoEditorScreen]? = nil,
        startOnScreen: YPVideoEditorScreen? = nil
    ) {
        self.video = video
        self.isFromSelectionVC = isFromSelectionVC
        self.screens = screens ?? [.trim, .coverPicker]
        self.startOnScreen = startOnScreen ?? screens?.first ?? .trim
    }
    
}
