//
//  SearchViewController.swift
//  GitUserSearchMVI
//
//  Created by Dogether on 27/04/18.
//  Copyright © 2018 Dogether. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

class SearchViewController: UIViewController,StoryboardView {
    var disposeBag = DisposeBag()
    
    typealias Reactor = SearchReactor
    @IBOutlet weak var lQuery: UITextField!
    @IBOutlet weak var tvTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private let cell = "cell"
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reactor = SearchReactor()
        tvTableView.register(UITableViewCell.self, forCellReuseIdentifier: cell)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func bind(reactor: SearchReactor) {
        lQuery.rx.text
        .throttle(0.3, scheduler: MainScheduler.instance)
            .filter({ (string) -> Bool in
                return string != ""
            })
            .map{Reactor.Action.search($0)}
        .bind(to: reactor.action)
        .disposed(by: disposeBag)
        
        reactor.state.map{$0.isLoadingUserDetails}
            .bind(to: activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        reactor.state.map{!($0.isLoadingUserDetails)}
            .bind(to: activityIndicator.rx.isHidden)
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.users}
            .bind(to: tvTableView.rx.items(cellIdentifier: cell)){_,user,cell in
                cell.textLabel?.text = user.name
        }
        .disposed(by: disposeBag)
    }
}
