//
//  ToYongViewController.swift
//  RACK
//
//  Created by Алексей Петров on 18/09/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import UIKit

class ToYongViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        var navigationArray = navigationController!.viewControllers // To get all UIViewController stack as Array
        navigationArray.remove(at: navigationArray.count - 2)
        var current: UIViewController = navigationArray.last!
        navigationArray.removeAll()
        navigationArray.append(current)// To remove previous UIViewController
        self.navigationController?.viewControllers = navigationArray
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
