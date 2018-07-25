//
//  GalleryCollectionViewController.swift
//  ImageGallery
//
//  Created by Ahmed Ramy on 7/21/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import UIKit


class GalleryCollectionViewController: UICollectionViewController, UICollectionViewDragDelegate, UICollectionViewDropDelegate, UICollectionViewDelegateFlowLayout
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        collectionView?.dropDelegate = self
        collectionView?.dragDelegate = self
        collectionView?.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(scaleCells(_:))))
        collectionView?.register(UINib(nibName: "GalleryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "GalleryCollectionViewCell")
    }
    
    private var galleryURLs = [URL]()
    {
        didSet
        {
            collectionView?.reloadData()
        }
    }
    
    @IBOutlet weak var hintLabel: UILabel!
    
    //MARK:- Pinch Gesture
    var scalingForCells: CGFloat = Settings.DefaultValues.CollectionViewValues.defaultScalingForCells
    
    @objc func scaleCells(_ recognizer: UIPinchGestureRecognizer)
    {
        switch recognizer.state
        {
        case .changed, .ended:
            scalingForCells *= recognizer.scale
            recognizer.scale = 1
            updateLayout()
        default:
            return
        }
    }
    
    
    
    // MARK: - Navigation

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let cell = sender as? GalleryCollectionViewCell
        {
            return cell.imageURL != nil
        }
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        guard let vc = segue.destination as? ImageArtViewController else { return }
        if let cell = sender as? GalleryCollectionViewCell
        {
            vc.imageURL = cell.imageURL
        }
        
    }
    

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if galleryURLs.count > 0
        {
            hintLabel.isHidden = true
        }
        else
        {
            hintLabel.isHidden = false 
        }
        return galleryURLs.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCollectionViewCell", for: indexPath) as! GalleryCollectionViewCell
        // Configure the cell
        cell.imageURL = galleryURLs[indexPath.item]
        
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        performSegue(withIdentifier: "goToImageArt", sender: self.collectionView?.cellForItem(at: indexPath))
    }
    
    //MARK:- Drag Drop Functions
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool
    {
        return session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItem(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem]
    {
        return dragItem(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal
    {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator)
    {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items
        {
            if let sourceIndexPath = item.sourceIndexPath
            {
                if let url = item.dragItem.localObject as? URL
                {
                    collectionView.performBatchUpdates({
                        galleryURLs.remove(at: sourceIndexPath.item)
                        galleryURLs.insert(url, at: destinationIndexPath.item)
                    })
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
            }
            else
            {
                let placeholderContext = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "GalleryBufferingCell"))
                item.dragItem.itemProvider.loadObject(ofClass: NSURL.self) { (provider, error) in
                    DispatchQueue.main.async
                    {
                        if let url = provider as? URL
                        {
                            placeholderContext.commitInsertion(dataSourceUpdates:
                            { (insertionIndexPath) in
                                self.galleryURLs.insert(url.imageURL, at: insertionIndexPath.item)
                            })
                        }
                        else
                        {
                            placeholderContext.deletePlaceholder()
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func dragItem(at indexPath: IndexPath) -> [UIDragItem]
    {
        if let galleryImageURL = (collectionView?.cellForItem(at: indexPath) as? GalleryCollectionViewCell)?.imageURL
        {
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: galleryImageURL as NSItemProviderWriting))
            dragItem.localObject = dragItem
            return [dragItem]
        }
        return []
    }

    //MARK:- Layout Functions
    
    fileprivate func updateLayout()
    {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let cellWidth = 250 * scalingForCells
        
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
}
