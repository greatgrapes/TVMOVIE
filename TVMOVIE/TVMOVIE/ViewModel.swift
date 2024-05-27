//
//  ViewModel.swift
//  TVMOVIE
//
//  Created by beaunexMacBook on 5/24/24.
//

import Foundation
import RxSwift

class ViewModel {
    let disposeBag = DisposeBag()
    private let tvNetwork: TVNetwork
    private let movieNetwork: MovieNetwork
    
    init() {
        let provider = NetworkProvider()
        tvNetwork = provider.makeTVNetwork()
        movieNetwork = provider.makeMovieNetwork()
    }
    
    struct Input {
        let tvTrigger: Observable<Void>
        let movieTrigger: Observable<Void>
    }
    
    struct Output {
        let tvList: Observable<[TV]>
        let movieList: Observable<MovieResult>
    }
    
    func transform(input: Input) -> Output {
        
        //trigger -> 네트워크 -> Observable<T> -> VC 전달 -> VC에서 구독
        
        //tvTrigger -> Observable<Void> -> Observable<[TV]>
        //전환과정
        let tvList = input.tvTrigger.flatMapLatest { [unowned self] _ -> Observable<[TV]> in
            //Observable<TVListModel> -> Observable<[TV]>
            return self.tvNetwork.getTopRatedList().map { $0.results }
        }
        
        let movieResult = input.movieTrigger.flatMapLatest { [unowned self] _ -> Observable<MovieResult> in
            //combineLatest
            //Observable 1, 2, 3 합쳐서 하나의 Observable로 바꾸고싶다면, combineLatest
            return Observable.combineLatest(self.movieNetwork.getUpcomingList(), self.movieNetwork.getPopularList(), self.movieNetwork.getNowPlayingList()) { upcoming, popular, nowPlaying -> MovieResult in
                return MovieResult(upcoming: upcoming, popular: popular, nowPlaying: nowPlaying)
                //Observable<MovieListModel>
            }
        }
        
        
        return Output(tvList: tvList, movieList: movieResult)
    }
    
}
