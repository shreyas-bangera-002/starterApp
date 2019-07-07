//
//  CollectionView.swift
//  StarterApp
//
//  Created by Shreyas Bangera on 15/06/19.
//  Copyright © 2019 Shreyas Bangera. All rights reserved.
//

import UIKit
import AnimatedCollectionViewLayout

enum LayoutAnimator {
    case none, card, parallax, zoomInOut, rotateInOut, cube, crossFade, page, snap
    
    var value: LayoutAttributesAnimator? {
        switch self {
        case .parallax:
            return ParallaxAttributesAnimator()
        case .zoomInOut:
            return ZoomInOutAttributesAnimator()
        case .rotateInOut:
            return RotateInOutAttributesAnimator()
        case .cube:
            return CubeAttributesAnimator()
        case .card:
            return LinearCardAttributesAnimator()
        case .none:
            return nil
        case .crossFade:
            return CrossFadeAttributesAnimator()
        case .page:
            return PageAttributesAnimator()
        case .snap:
            return SnapInAttributesAnimator()
        }
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
    var didScrollToIndex: ((IndexPath) -> Void)?
    var didScrollToOffset: ((CGFloat) -> Void)?
    
    convenience init(_ scrollDirection: UICollectionView.ScrollDirection,
                     animator: LayoutAnimator = .none,
                     lineSpacing: CGFloat = 0,
                     itemSpacing: CGFloat = 0,
                     widthFactor: CGFloat = 1,
                     heightFactor: CGFloat = 1,
                     width: CGFloat? = nil,
                     height: CGFloat? = nil,
                     isSquare: Bool = false,
                     isDynamic: Bool = false) {
        let layout = AnimatedCollectionViewLayout()
        layout.animator = animator.value
        if isDynamic {
            layout.itemSize = UICollectionViewFlowLayout.automaticSize
        }
        layout.scrollDirection = scrollDirection
        self.init(frame: .zero, collectionViewLayout: layout)
        dataSource = self
        delegate = self
        self.lineSpacing = lineSpacing
        self.itemSpacing = itemSpacing
        self.widthFactor = widthFactor
        self.heightFactor = heightFactor
        self.width = width
        self.height = height
        self.isSquare = isSquare
        backgroundColor = .clear
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
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
    
    func update(_ items: [List<Section,Item>]) {
        data = items
        reloadData()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        didScrollToOffset?(contentOffset.x)
        if scrollView.tag == 0 {
            let center = CGPoint(x: scrollView.contentOffset.x + scrollView.frame.width/2, y: scrollView.frame.height/2)
            if let index = self.indexPathForItem(at: center) {
                didScrollToIndex?(index)
            }
        }
    }
}

class CollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        render()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        render()
    }
    
    func render() {}
}
