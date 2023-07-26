//
//  YPPermissionDeniedPopup.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 12/03/2018.
//  Copyright © 2018 Yummypets. All rights reserved.
//

import UIKit

internal struct YPPermissionDeniedPopup {
    static func buildGoToCameraSettingsAlert(cancelBlock: @escaping () -> Void) -> UIAlertController {
        let alert = UIAlertController(
            title:
                YPConfig.wordings.permissionPopup.cameraTitle,
            message: YPConfig.wordings.permissionPopup.cameraMessage,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: YPConfig.wordings.permissionPopup.cancel,
                style: .default,
                handler: { _ in
                    cancelBlock()
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: YPConfig.wordings.permissionPopup.grantPermission,
                style: .default,
                handler: { _ in
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    } else {
                        UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                    }
                }
            )
        )
        
        return alert
    }
    
    static func buildGoToPhotoSettingsAlert(cancelBlock: @escaping () -> Void) -> UIAlertController {
        let alert = UIAlertController(
            title:
                YPConfig.wordings.permissionPopup.photoTitle,
            message: YPConfig.wordings.permissionPopup.photoMessage,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: YPConfig.wordings.permissionPopup.cancel,
                style: .default,
                handler: { _ in
                    cancelBlock()
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: YPConfig.wordings.permissionPopup.grantPermission,
                style: .default,
                handler: { _ in
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    } else {
                        UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                    }
                }
            )
        )
        
        return alert
    }
}
