//
//  ViewController.swift
//  ImageGallery
//
//  Created by Ahmed Ramy on 7/20/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import UIKit

class ImageArtViewController: UIViewController, UIScrollViewDelegate
{

    // MARK: - Storyboard
    
    @IBOutlet weak var scrollView: UIScrollView!
    {
        didSet
        {
            scrollView.minimumZoomScale = Settings.DefaultValues.ScrollViewsValues.minimumZoomScale
            scrollView.maximumZoomScale = Settings.DefaultValues.ScrollViewsValues.maximumZoomScale
            scrollView.delegate = self
            scrollView.addSubview(imageView)
        }
    }
    
    @IBOutlet weak var scrollViewWidth: NSLayoutConstraint!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if imageView.image == nil
        {
            fetchImage()
        }
    }
    
    fileprivate func fetchImage()
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
    
    var imageView = UIImageView()
    
    var imageURL: URL?
    {
        didSet
        {
            image = nil
            if view.window == nil
            {
                fetchImage()
            }
        }
    }
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView?
    {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView)
    {
        scrollViewWidth.constant = scrollView.contentSize.width
        scrollViewHeight.constant = scrollView.contentSize.height
    }
    
    private(set) var image: UIImage?
    {
        get
        {
            return imageView.image
        }
        
        set
        {
            scrollView?.zoomScale = Settings.DefaultValues.ScrollViewsValues.defaultZoomScale
            imageView.image = newValue
            let size = newValue?.size ?? CGSize.zero
            imageView.frame = CGRect(origin: CGPoint.zero, size: size)
            scrollView?.contentSize = size
            scrollViewWidth?.constant = size.width
            scrollViewHeight?.constant = size.height
        }
    }
    
    
    
}

