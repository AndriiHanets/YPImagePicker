//
//  YPLibrary+LibraryChange.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 26/01/2018.
//  Copyright © 2018 Yummypets. All rights reserved.
//

import UIKit
import Photos

extension YPLibraryVC: PHPhotoLibraryChangeObserver {
    func registerForLibraryChanges() {
        PHPhotoLibrary.shared().register(self)
    }
    
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let fetchResult = self.mediaManager.fetchResult,
              let collectionChanges = changeInstance.changeDetails(for: fetchResult) else {
            ypLog("Some problems there.")
            return
        }

        DispatchQueue.main.async {
            let collectionView = self.v.collectionView
            self.mediaManager.fetchResult = collectionChanges.fetchResultAfterChanges
            
            let currentAssetIds = self.mediaManager.fetchAssets?.map { $0.localIdentifier } ?? []
            self.selectedItems.removeAll(where: { !currentAssetIds.contains($0.assetIdentifier) })
            self.delegate?.libraryViewFinishedLoading()
            collectionView.reloadData()

            self.updateAssetSelection()
            self.mediaManager.resetCachedAssets()
        }
    }

    fileprivate func updateAssetSelection() {
        // If no items selected in assetView, but there are already photos
        // after photoLibraryDidChange, than select first item in library.
        // It can be when user add photos from limited permission.
        if self.mediaManager.hasResultItems,
           selectedItems.isEmpty,
           let newAsset = self.mediaManager.getAsset(at: 0) {
            self.changeAsset(newAsset)
        }

        // If user decided to forbid all photos with limited permission
        // while using the lib we need to remove asset from assets view.
        if selectedItems.isEmpty == false,
           self.mediaManager.hasResultItems == false {
            self.v.assetZoomableView.clearAsset()
            self.selectedItems.removeAll()
            self.delegate?.libraryViewFinishedLoading()
        }
    }
}
