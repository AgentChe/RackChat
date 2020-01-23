//
//  RightView.swift
//  RACK
//
//  Created by Алексей Петров on 09/09/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit
import DatingKit

class RightView: UIView {
    @IBOutlet weak var priceLongLabel: UILabel?
    @IBOutlet weak var priceNameLabel: UILabel?
    @IBOutlet weak var priceLabel: UILabel?
    @IBOutlet weak var separator: UIView?
    var productID: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func config(with priceTag: SubPriceTag) {
        priceLongLabel?.text = priceTag.nameNum
        priceNameLabel?.text = priceTag.name
        priceLabel?.text = priceTag.priceString
        productID = priceTag.id
    }
    
    func select(_ state: Bool) {
        separator?.backgroundColor = state ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 1, green: 0.4274509804, blue: 0.5647058824, alpha: 1)
        self.backgroundColor = state ? #colorLiteral(red: 1, green: 0.4274509804, blue: 0.5647058824, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        priceLongLabel?.textColor = state ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 1, green: 0.4274509804, blue: 0.5647058824, alpha: 1)
        priceNameLabel?.textColor = state ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 1, green: 0.4274509804, blue: 0.5647058824, alpha: 1)
        priceLabel?.textColor = state ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 1, green: 0.4274509804, blue: 0.5647058824, alpha: 1)
    }

}
