//
//  TopRatedViewController.swift
//  Flicks
//
//  Created by Manuel Deschamps on 5/16/16.
//
//

import UIKit

class TopRatedViewController: MovieListViewController {

  override func loadMoviews() {
    let apiClient = MoviesDatabaseAPIClient()

    apiClient.fetchMovies(.TopRated) { [weak self] response in
      switch response {
      case .Success(let movies):
        self?.movies = movies

      case .Error(_):
        self?.visibleCollectionViewController?.errorLoadingMovies()
      }
    }
  }
}