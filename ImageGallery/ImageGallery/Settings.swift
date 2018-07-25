//
//  Settings.swift
//  ImageGallery
//
//  Created by Ahmed Ramy on 7/21/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import UIKit

struct Settings
{
    struct DefaultValues
    {
        struct ScrollViewsValues
        {
            static let minimumZoomScale: CGFloat = 0.1
            static let maximumZoomScale: CGFloat = 5.0
            static let defaultZoomScale: CGFloat = 1.0
            
        }
        
        struct TableViewValues
        {
            static let cellSize = CGSize(width: 80, height: 80)
            static let textSize: CGFloat = 60.0
        }
        
        struct CollectionViewValues
        {
            static let defaultScalingForCells: CGFloat = 1.0
        }
    }
}
