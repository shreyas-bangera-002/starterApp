//
//  CollectionView.swift
//  StarterApp
//
//  Created by Shreyas Bangera on 15/06/19.
//  Copyright © 2019 Shreyas Bangera. All rights reserved.
//

import UIKit

class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            
            layoutAttribute.frame.origin.x = leftMargin
            
            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }
        
        return attributes
    }
}

class CollectionView<Section,Item>: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private var data = [List<Section,Item>]()
    var lineSpacing: CGFloat = 0
    var itemSpacing: CGFloat = 0
    var width: CGFloat?
    var height: CGFloat?
    var widthFactor: CGFloat!
    var heightFactor: CGFloat!
    var isSquare = false
    var didSelect: ((CollectionView<Section,Item>, IndexPath, Item) -> Void)?
    var didDeSelect: ((CollectionView<Section,Item>, IndexPath, Item) -> Void)?
    var configureCell: ((CollectionView<Section,Item>, IndexPath, Item) -> UICollectionViewCell)?
    
    convenience init(_ scrollDirection: UICollectionView.ScrollDirection,
                     lineSpacing: CGFloat = 0,
                     itemSpacing: CGFloat = 0,
                     widthFactor: CGFloat = 1,
                     heightFactor: CGFloat = 1,
                     width: CGFloat? = nil,
                     height: CGFloat? = nil,
                     isSquare: Bool = false,
                     isDynamic: Bool = false) {
        let flowLayout = UICollectionViewFlowLayout()
        if isDynamic {
            flowLayout.itemSize = UICollectionViewFlowLayout.automaticSize
        }
        flowLayout.scrollDirection = scrollDirection
        self.init(frame: .zero, collectionViewLayout: flowLayout)
        dataSource = self
        delegate = self
        self.lineSpacing = lineSpacing
        self.itemSpacing = itemSpacing
        self.widthFactor = widthFactor
        self.heightFactor = heightFactor
        self.width = width
        self.height = height
        self.isSquare = isSquare
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data[section].items?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = data[indexPath.section].items?[indexPath.row],
            let cell = configureCell?(self, indexPath, item) else {
            return UICollectionViewCell()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return itemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return lineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = width ?? widthFactor * collectionView.bounds.size.width
        let cellHeight = isSquare ? cellWidth : (height ?? heightFactor * collectionView.bounds.size.height)
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = data[indexPath.section].items?[indexPath.row] else { return }
        didSelect?(self, indexPath, item)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let item = data[indexPath.section].items?[indexPath.row] else { return }
        didDeSelect?(self, indexPath, item)
    }
    
    func updateItems(_ items: [List<Section,Item>]) {
        data = items
        reloadData()
    }
}

class CollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        render()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        render()
    }
    
    func render() {}
}
