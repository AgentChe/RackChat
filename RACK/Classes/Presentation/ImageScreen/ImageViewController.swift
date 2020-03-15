//
//  ImageViewController.swift
//  RACK
//
//  Created by Andrey Chernyshev on 15/03/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift

final class ImageViewController: UIViewController {
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "close_menu_btn"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var url: URL!
    
    private let disposeBag = DisposeBag()
    
    init(url: URL) {
        super.init(nibName: nil, bundle: nil)
        
        self.url = url
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        addSubviews()
        addActions()
    }
    
    private func addSubviews() {
        view.addSubview(imageView)
//        view.addSubview(closeButton)
        
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
//        closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
//        closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24).isActive = true
//        closeButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
//        closeButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
    }
    
    private func addActions() {
        imageView.kf.setImage(with: url)
        
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}
