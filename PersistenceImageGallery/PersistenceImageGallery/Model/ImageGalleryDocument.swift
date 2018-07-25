//
//  ImageGalleryDocument.swift
//  PersistenceImageGallery
//
//  Created by Ahmed Ramy on 7/24/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import UIKit

class ImageGalleryDocument: UIDocument
{
    var imageGallery: ImageGallery?
    var thumbnail: UIImage?

    
    override func contents(forType typeName: String) throws -> Any {
        return imageGallery?.json ?? Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws
    {
        if let json = contents as? Data
        {
            imageGallery = ImageGallery(json: json)
        }
    }
    
    override func fileAttributesToWrite(to url: URL, for saveOperation: UIDocumentSaveOperation) throws -> [AnyHashable : Any] {
        var attributes = try super.fileAttributesToWrite(to: url, for: saveOperation)
        if let thumbnail = self.thumbnail {
            attributes[URLResourceKey.thumbnailDictionaryKey] = [URLThumbnailDictionaryItem.NSThumbnail1024x1024SizeKey:thumbnail]
        }
        return attributes
    }

}
