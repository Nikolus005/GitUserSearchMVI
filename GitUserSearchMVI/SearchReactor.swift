//
//  SearchReactor.swift
//  GitUserSearchMVI
//
//  Created by Dogether on 26/04/18.
//  Copyright © 2018 Dogether. All rights reserved.
//

import ReactorKit
import RxSwift
import RxCocoa
import RxAlamofire

class SearchReactor: Reactor {
    enum Action{
        case search(String?)
    }
    
    enum Mutation{
        case searchQuery(String?)
        case setUsers([User])
        case loadingChanged
    }
    struct State{
        var query:String? = nil
        var users:[User] = []
        var isLoadingUserDetails: Bool = false
    }
    let initialState : State
    init() {
        initialState = State(query: "tom", users: [], isLoadingUserDetails: false)
    }
    func mutate(action: SearchReactor.Action) -> Observable<SearchReactor.Mutation> {
        switch action {
        case let .search(query):
            return Observable.concat([Observable.just(Mutation.searchQuery(query)),
                                       self.search(query: query)
                                        .distinctUntilChanged()
                                        .filter({ (users) -> Bool in
                                            return users.count > 0
                                        })
                                        .map{
                                            Mutation.setUsers($0)
                },
                                       Observable.just(Mutation.loadingChanged)])
        default:
            break
        }
    }
    func reduce(state: SearchReactor.State, mutation: SearchReactor.Mutation) -> SearchReactor.State {
        var newState = state
        switch mutation {
        case let .searchQuery(query):
            newState.query = query
            return newState
        case let .setUsers(users):
            newState.users.removeAll()
            newState.users = users
            newState.isLoadingUserDetails = !state.isLoadingUserDetails
            return newState
        case .loadingChanged:
            newState.isLoadingUserDetails = !state.isLoadingUserDetails
            return newState
        default:
            break
        }
    }
    private func search(query: String?) -> Observable<[User]> {
        if query != "" && query != nil{
            let request = DOHttpManager.shared.rx
                .request(.get, url(for: query)!)
            return request.validate(statusCode: 200 ..< 201)
                .data()
                .map { (data) -> [User] in
//                    guard let dict = json as? [String : Any] else { return [] }
//                    guard let item = dict["items"] as? [String : Any] else{ return [] }
                    guard let userList = UserList(JSONString: data.toString()) else { return [] }
                    return userList.userList
                }
                .do(onNext: nil, onError: { (error) in
                    if case let .some(.httpRequestFailed(response, _)) = error as? RxCocoaURLError, response.statusCode == 403 {
                        print("⚠️ GitHub API rate limit exceeded. Wait for 60 seconds and try again.")
                    }
                }, onCompleted: nil, onSubscribe: nil, onSubscribed: nil, onDispose: nil)
            .catchErrorJustReturn([])
        }else{
            return Observable.just([])
        }
        
    }
    private func url(for query: String?) -> URL? {
        guard let query = query, !query.isEmpty else { return nil }
        let url = "https://api.github.com/search/users?q=\(query)"
        print(url)
        return URL(string: url)
    }
}
extension Data
{
    func toString() -> String
    {
        return String(data: self, encoding: .utf8)!
    }
}
