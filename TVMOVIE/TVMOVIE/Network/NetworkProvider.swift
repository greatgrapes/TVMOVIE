//
//  NetworkProvider.swift
//  TVMOVIE
//
//  Created by beaunexMacBook on 5/24/24.
//

import Foundation

final class NetworkProvider {
    private let endpoint: String
    
    init() {
        self.endpoint = "https://api.themoviedb.org/3"
    }
    
    func makeTVNetwork() -> TVNetwork {
        let network = Network<TVListModel>(endpoint)
        return TVNetwork(network: network)
    }
    
    func makeMovieNetwork() -> MovieNetwork {
        let network = Network<MovieListModel>(endpoint)
        return MovieNetwork(network: network)
    }
    
    
}
