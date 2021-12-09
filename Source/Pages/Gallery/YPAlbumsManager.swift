//
//  YPAlbumsManager.swift
//  YPImagePicker
//
//  Created by Sacha Durand Saint Omer on 20/07/2017.
//  Copyright © 2017 Yummypets. All rights reserved.
//

import Foundation
import Photos
import UIKit

class YPAlbumsManager {
    
    private var cachedAlbums: [YPAlbum]?
    
    func fetchAlbums() -> [YPAlbum] {
        if let cachedAlbums = cachedAlbums {
            return cachedAlbums
        }
        
        var albums = [YPAlbum]()
        let smartAlbumsResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                                        subtype: .any,
                                                                        options: nil)
        for result in [smartAlbumsResult] {
            result.enumerateObjects({ assetCollection, _, _ in
                var album = YPAlbum()
                album.title = assetCollection.localizedTitle ?? ""
                album.numberOfItems = self.mediaCountFor(collection: assetCollection)
                if album.numberOfItems > 0 {
                    let r = PHAsset.fetchKeyAssets(in: assetCollection, options: nil)
                    if let placeholerAsset = r?.firstObject {
                        self.getThumbnailForImage(asset: placeholerAsset, completion: { image in
                            album.thumbnail = image
                        })
                        print("albums: \(placeholerAsset.mediaType.rawValue)")
//                        switch YPConfig.library.mediaType {
//                        case .photo, .photoAndVideo:
//                            switch placeholerAsset.mediaType {
//                            case .image, .unknown:
//                                self.getThumbnailForImage(asset: placeholerAsset, completion: { image in
//                                    album.thumbnail = image
//                                })
//                            case .video:
//                                self.getThumbnailForVideo(asset: placeholerAsset) { image in
//                                    album.thumbnail = image
//                                }
//                            case .audio:
//                                break
//                            }
//
//                        case .video:
//                            self.getThumbnailForVideo(asset: placeholerAsset) { image in
//                                album.thumbnail = image
//                            }
//                        }
                    }
                    album.collection = assetCollection
                    
                    if YPConfig.library.mediaType == .photo {
                        if !(assetCollection.assetCollectionSubtype == .smartAlbumSlomoVideos
                            || assetCollection.assetCollectionSubtype == .smartAlbumVideos) {
                            albums.append(album)
                        }
                    } else {
                        albums.append(album)
                    }
                }
            })
        }
        
        let favouritesIndex = albums.firstIndex(where: { $0.title.lowercased() == "favourites" || $0.title.lowercased() == "favorites" })
        favouritesIndex.map {
            let album = albums[$0]
            albums.remove(at: $0);
            albums.insert(album, at: 0)
        }
        
        let recentIndex = albums.firstIndex(where: { $0.title.lowercased() == "recents" })
        recentIndex.map {
            let album = albums[$0]
            albums.remove(at: $0);
            albums.insert(album, at: 0)
        }
        
        cachedAlbums = albums
        return albums
    }
    
    func mediaCountFor(collection: PHAssetCollection) -> Int {
        let options = PHFetchOptions()
        options.predicate = YPConfig.library.mediaType.predicate()
        let result = PHAsset.fetchAssets(in: collection, options: options)
        return result.count
    }
    
    func getThumbnailForImage(asset: PHAsset, completion: @escaping ((UIImage?) -> Void)) {
        let deviceScale = UIScreen.main.scale
        let targetSize = CGSize(width: 78*deviceScale, height: 78*deviceScale)
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .opportunistic
        PHImageManager.default().requestImage(for: asset,
                                              targetSize: targetSize,
                                              contentMode: .aspectFill,
                                              options: options,
                                              resultHandler: { image, _ in
                                                completion(image)
                                              })
    }
    
    func getThumbnailForVideo(asset: PHAsset, completion: @escaping ((UIImage?) -> Void)) {
        // TODO: Change getting video and image thumb flow
        PHImageManager.default().requestAVAsset(forVideo: asset,
                                                options: nil,
                                                resultHandler: { [weak self] video, _, _ in
                                                    self?.generateVideoThumbnailFrom(asset: video, completion: completion)
                                                })
    }
    
    func generateVideoThumbnailFrom(asset: AVAsset?, completion: @escaping ((UIImage?) -> Void)) {
        guard let asset = asset else {
            print("generateVideoThumbnailFrom: nil")
            return
        }
        
        return asset.generateThumbnail(completion: completion)
    }
    
}

extension YPlibraryMediaType {
    func predicate() -> NSPredicate {
        switch self {
        case .photo:
            return NSPredicate(format: "mediaType = %d",
                               PHAssetMediaType.image.rawValue)
        case .video:
            return NSPredicate(format: "mediaType = %d",
                               PHAssetMediaType.video.rawValue)
        case .photoAndVideo:
            return NSPredicate(format: "mediaType = %d || mediaType = %d",
                               PHAssetMediaType.image.rawValue,
                               PHAssetMediaType.video.rawValue)
        }
    }
}
