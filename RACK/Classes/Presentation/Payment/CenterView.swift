//
//  CenterView.swift
//  RACK
//
//  Created by Алексей Петров on 09/09/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit

class CenterView: UIView {
    @IBOutlet weak var headerLabel: UILabel?
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var subnameLabel: UILabel?
    @IBOutlet weak var priceLabel: UILabel?
    @IBOutlet weak var separator: UIView?
    var productID: String?
    
    override func awakeFromNib() {

    }
    
    func config(with priceTag: CentralPriceTag) {
        headerLabel?.text = priceTag.headerString
        nameLabel?.text = priceTag.name
        subnameLabel?.text = priceTag.subname
        priceLabel?.text = priceTag.priseString
        productID = priceTag.id
    }
    
    func select(_ state: Bool) {
        separator?.backgroundColor = state ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 1, green: 0.4274509804, blue: 0.5647058824, alpha: 1)
        self.backgroundColor = state ? #colorLiteral(red: 1, green: 0.4274509804, blue: 0.5647058824, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        headerLabel?.textColor = state ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 1, green: 0.4274509804, blue: 0.5647058824, alpha: 1)
        subnameLabel?.textColor = state ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 1, green: 0.4274509804, blue: 0.5647058824, alpha: 1)
        nameLabel?.textColor = state ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 1, green: 0.4274509804, blue: 0.5647058824, alpha: 1)
        priceLabel?.textColor = state ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 1, green: 0.4274509804, blue: 0.5647058824, alpha: 1)
    }
}
