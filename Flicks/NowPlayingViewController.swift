//
//  NowPlaingViewController.swift
//  Flicks
//
//  Created by Manuel Deschamps on 5/16/16.
//
//

import UIKit

class NowPlayingViewController: MovieListViewController {

  override func loadMovies() {
    let apiClient = MoviesDatabaseAPIClient()

    apiClient.fetchMovies(.NowPlaying) { [weak self] response in
      switch response {
      case .Success(let movies):
        self?.movies = movies

      case .Error(_):
        self?.showErrorMessage()
      }
    }
  }
}