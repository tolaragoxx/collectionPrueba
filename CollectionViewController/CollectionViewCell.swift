//
//  CollectionViewCell.swift
//  CollectionViewController
//
//  Created by Gonzalo on 17/03/16.
//  Copyright © 2016 doapps. All rights reserved.
//

import UIKit
import CoreData
class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var collectionImageView: UIImageView!
    func configureCellWith(university: NSManagedObject){
        if let name = university.valueForKey("name") as? String{
            self.collectionImageView.image = UIImage(named: name)
        }
        
    }
}
