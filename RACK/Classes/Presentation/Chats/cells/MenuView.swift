//
//  MenuView.swift
//  FAWN
//
//  Created by Алексей Петров on 10/04/2019.
//  Copyright © 2019 Алексей Петров. All rights reserved.
//

import UIKit

class MenuView: UIView {
    
    @IBOutlet weak var collectionView: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "GIFCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "GIFCollectionViewCell")
    }
    

}


extension MenuView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GIFCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "GIFCollectionViewCell", for: indexPath) as! GIFCollectionViewCell
        return cell
    }
    
    
}
