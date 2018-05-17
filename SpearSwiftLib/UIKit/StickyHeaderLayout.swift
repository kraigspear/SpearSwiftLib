//
//  StickyHeaderLayout.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 1/13/18.
//  Copyright © 2018 spearware. All rights reserved.
//

import CoreGraphics
import UIKit

public class StickyHeaderLayout: UICollectionViewFlowLayout {
    private let topZIndex = 1024

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        scrollDirection = .horizontal
        minimumInteritemSpacing = 0.0
        minimumLineSpacing = 0
        sectionInset = UIEdgeInsets(top: 0, left: -headerReferenceSize.width, bottom: 0, right: 0)
    }

    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var answer = super.layoutAttributesForElements(in: rect)!

        let missingSections = NSMutableIndexSet()

        answer.filter { $0.representedElementCategory == UICollectionElementCategory.cell }
            .map { $0.indexPath.section }
            .forEach { missingSections.add($0) }

        answer.filter { $0.representedElementKind ?? "" == UICollectionElementKindSectionHeader }
            .map { $0.indexPath.section }
            .forEach { missingSections.remove($0) }

        missingSections.map { IndexPath(row: 0, section: $0) }
			.compactMap { layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: $0) }
            .forEach { answer.append($0) }

        answer.filter { $0.representedElementKind ?? "" == UICollectionElementKindSectionHeader }
            .forEach { layoutHeader($0) }

        return answer
    }

    private func layoutHeader(_ attributes: UICollectionViewLayoutAttributes) {
        guard let collectionView = self.collectionView else {
            assertionFailure()
            return
        }

        let contentOffset = collectionView.contentOffset

        let section = attributes.indexPath.section
        let numberOfItemsInSection = collectionView.numberOfItems(inSection: section)

        let firstIndexPath = IndexPath(row: 0, section: section)
        let lastIndexPath = IndexPath(row: max(0, numberOfItemsInSection - 1), section: section)

        // Forced unwrapping is used because if we are not able to get the attributes of these items
        // it is because of incorrect logic above. It is better to crash, and fix the incorrect code
        //then to proceed.
        let firstCellAttributes = layoutAttributesForItem(at: firstIndexPath)!
        let lastCellIAttributes = layoutAttributesForItem(at: lastIndexPath)!

        switch scrollDirection {
        case .vertical:

            let headerHeight = attributes.frame.height
            var origin = attributes.frame.origin

            origin.y = min(max(contentOffset.y, firstCellAttributes.frame.minY - headerHeight),
                           lastCellIAttributes.frame.maxY - headerHeight)

            attributes.zIndex = topZIndex
            attributes.frame = CGRect(origin: origin, size: attributes.frame.size)

        case .horizontal:

            let headerWidth = attributes.frame.width
            var origin = attributes.frame.origin

            origin.x = min(max(contentOffset.x, firstCellAttributes.frame.minX - headerWidth),
                           lastCellIAttributes.frame.maxX - headerWidth * 2)

            attributes.zIndex = topZIndex
            attributes.frame = CGRect(origin: origin, size: attributes.frame.size)
        }
    }

    public override func shouldInvalidateLayout(forBoundsChange _: CGRect) -> Bool {
        return true
    }
}
