//
//  MoviesDatabaseAPIClient.swift
//  Flicks
//
//  Created by Manuel Deschamps on 5/17/16.
//
//

import Foundation
import UIKit

enum MoviesList {
  case NowPlaying
  case TopRated
}

extension MoviesList {
  var path: String {
    switch self {
      case .NowPlaying: return "/3/movie/now_playing"
      case .TopRated: return "/3/movie/top_rated"
    }
  }
}

extension Movie {
  var path: String { return "/3/movie/\(self.id!)" }
  var videosPath: String { return self.path + "/videos" }
}

enum MoviesResponse {
  case Success(movies: [Movie])
  case Error(e: ErrorType)
}

enum MovieResponse {
  case Success(movie: Movie)
  case Error(e: ErrorType)
}

class MoviesDatabaseAPIClient {

  static let BaseUrl = NSURL(string: "https://api.themoviedb.org")

  private let apiKeyParamName = "api_key"
  private let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"

  func fetchMovies(moviesList: MoviesList, completion: (response: MoviesResponse) -> Void ) {
    let moviesListUrl =  NSURLComponents(URL: MoviesDatabaseAPIClient.BaseUrl!, resolvingAgainstBaseURL: true)
    moviesListUrl?.path = moviesList.path

    fireRequest(moviesListUrl) { (responseDictionaryOrNil, error) in
      if let responseDictionary = responseDictionaryOrNil {
        if let results = responseDictionary["results"] as? [NSDictionary] {
          let movies = results.map { (movieDic) -> Movie in
            return Movie(dictionary: movieDic)
          }

          completion(response: .Success(movies: movies))
          return
        }
      }

      completion(response: .Error(e: (error ?? NSError(domain: "Parsing Error", code: 1, userInfo: nil))))
    }
  }

  func fetchMovie(movie: Movie, completion: (response: MovieResponse) -> Void) {
    let movieUrl =  NSURLComponents(URL: MoviesDatabaseAPIClient.BaseUrl!, resolvingAgainstBaseURL: true)
    movieUrl?.path = movie.path

    fireRequest(movieUrl) { (responseDictionaryOrNil, error) in
      if let responseDictionary = responseDictionaryOrNil {
        completion(response: .Success(movie: Movie(dictionary: responseDictionary)))
        return
      }

      completion(response: .Error(e: (error ?? NSError(domain: "Parsing Error", code: 1, userInfo: nil))))
    }
  }

  func fetchMovieWithVideos(movie: Movie, completion: (response: MovieResponse) -> Void) {
    let movieUrl =  NSURLComponents(URL: MoviesDatabaseAPIClient.BaseUrl!, resolvingAgainstBaseURL: true)
    movieUrl?.path = movie.path

    let movieVideosUrl =  NSURLComponents(URL: MoviesDatabaseAPIClient.BaseUrl!, resolvingAgainstBaseURL: true)
    movieVideosUrl?.path = movie.videosPath

    // fetch movie first
    fireRequest(movieUrl) { (movieDictionaryOrNil, error) in
      if let movieDictionary = movieDictionaryOrNil {
        // fetch the videos and merge dictionaries
        self.fireRequest(movieVideosUrl) { (videosDictionaryOrNil, error) in

          if let videosDictionary = videosDictionaryOrNil, moviesWithVideos = movieDictionary.mutableCopy() as? NSMutableDictionary {
            moviesWithVideos["videos"] = videosDictionary["results"]
            completion(response: .Success(movie: Movie(dictionary: moviesWithVideos)))
            return
          }

          completion(response: .Error(e: (error ?? NSError(domain: "Video not found", code: 1, userInfo: nil))))
        }
      } else {
        completion(response: .Error(e: (error ?? NSError(domain: "Movie not found", code: 1, userInfo: nil))))
      }
    }
  }

  private func fireRequest(urlComponents: NSURLComponents?, completionHandler: (NSDictionary?, NSError?) -> Void) {
    guard let urlComponents = urlComponents else {
      completionHandler(nil, NSError(domain: "Invalid URL", code: 1, userInfo: nil))
      return
    }

    let apiKeyParam = NSURLQueryItem(name: apiKeyParamName, value: apiKey)

    if urlComponents.queryItems == nil {
      urlComponents.queryItems = []
    }
    urlComponents.queryItems?.append(apiKeyParam)

    let request = NSURLRequest(
      URL: urlComponents.URL!,
      cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
      timeoutInterval: 10)

    let session = NSURLSession(
      configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
      delegate: nil,
      delegateQueue: NSOperationQueue.mainQueue())

    UIApplication.sharedApplication().networkActivityIndicatorVisible = true

    let task: NSURLSessionDataTask = session.dataTaskWithRequest(request){ (dataOrNil, response, error) in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false

      var responseDictionary: NSDictionary?
      if let httpResponse = response as? NSHTTPURLResponse, data = dataOrNil {
        if httpResponse.statusCode == 200 {
          if let jsonDictionary = try? NSJSONSerialization.JSONObjectWithData(data, options:[]) as? NSDictionary {
            responseDictionary = jsonDictionary
          }
        }
      }

      completionHandler(responseDictionary, error)
    }
    
    task.resume()
  }
}