//
//  GalleryCollectionViewCell.swift
//  ImageGallery
//
//  Created by Ahmed Ramy on 7/21/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import UIKit

class GalleryCollectionViewCell: UICollectionViewCell {
    
    var imageURL: URL? {
        didSet
        {
            if imageURL != nil && (oldValue != imageURL)
            {
                fetchImage()
            }
        }
    }
    
    private(set) var image: UIImage? {
        get
        {
            return galleryImageView?.image
        }
        set
        {
            galleryImageView.image = newValue
        }
    }
    
    private func fetchImage()
    {
        if let url = imageURL
        {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let urlContents = try? Data(contentsOf: url)
                DispatchQueue.main.async
                {
                    if let imageData = urlContents
                    {
                        self?.image = UIImage(data: imageData)
                        print("ImageView set the data")
                    }
                }
            }
        }
    }
    
    // MARK: - storyboard
    
    @IBOutlet weak var galleryImageView: UIImageView!
    
}
