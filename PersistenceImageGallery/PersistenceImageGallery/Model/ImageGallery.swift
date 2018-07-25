//
//  ImageGallery.swift
//  PersistenceImageGallery
//
//  Created by Ahmed Ramy on 7/24/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import Foundation

struct ImageGallery: Codable
{
    var imagesURL = [URL]()
    var scale: Float
    
    
    init?(json: Data)
    {
        if let newValue = try? JSONDecoder().decode(ImageGallery.self, from: json)
        {
            self = newValue
        }
        else
        {
            return nil
        }
    }
    
    var json: Data?
    {
        return try? JSONEncoder().encode(self)
    }
    
    init(imagesURL: [URL], scale: Float) {
        self.imagesURL = imagesURL
        self.scale = scale
    }
}
