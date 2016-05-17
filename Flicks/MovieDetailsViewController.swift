//
//  MovieDetailsViewController.swift
//  Flicks
//
//  Created by Manuel Deschamps on 5/16/16.
//
//

import UIKit
import YouTubePlayer
import AlamofireImage

class MovieDetailsViewController: UIViewController {

  @IBOutlet weak var playerView: YouTubePlayerView!
  @IBOutlet weak var moviePosterImage: UIImageView!
  @IBOutlet weak var scrollView: UIScrollView!

  @IBOutlet weak var movieDetailsView: UIView!
  @IBOutlet weak var movieTitleLabel: UILabel!
  @IBOutlet weak var movieOverviewLabel: UILabel!
  @IBOutlet weak var movieReleaseDate: UILabel!
  @IBOutlet weak var movieStarRatingLabel: UILabel!
  @IBOutlet weak var movieDurationLabel: UILabel!
  @IBOutlet weak var playVideoButton: UIButton!

  var movie: Movie?

  override func viewDidLoad() {
    super.viewDidLoad()

    playerView.delegate = self

    if let movie = self.movie {
      renderMovieDetails(movie)

      let apiClient = MoviesDatabaseAPIClient()
      apiClient.fetchMovieWithVideos(movie) { [weak _weakSelf = self] response in
        guard let _weakSelf = _weakSelf else { return }

        if case .Success(let newMovie) = response {
          _weakSelf.movie = newMovie
          _weakSelf.renderMovieExtraDetails(newMovie)
        }
      }
    }
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    if let movie = self.movie {
      loadPosterImage(movie)
    }

    if let detailsTopPosition = scrollView.constraints.filter({ return $0.identifier == "detailsTopPosition" }).first {
      detailsTopPosition.constant = view.frame.size.height - scrollView.frame.origin.y - 200
    }
  }

  private func renderMovieDetails(movie: Movie) {
    title = movie.title
    movieTitleLabel.text = movie.title
    movieOverviewLabel.text = movie.overview

    if let releaseDate = movie.releaseDate  {
      let dateFormatter = NSDateFormatter()
      dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
      dateFormatter.dateFormat = "yyyy'-'MM'-'dd'"
      movieReleaseDate.text = dateFormatter.stringFromDate(releaseDate)
    } else {
      movieReleaseDate.text = ""
    }

    if let popularity = movie.popularity?.intValue {
      let stars = min((Int(popularity) / 20) + 1, 5)
      movieStarRatingLabel.text = "".stringByPaddingToLength(stars, withString: "★", startingAtIndex: 0)
    } else {
      movieStarRatingLabel.text = ""
    }

    movieDurationLabel.text = ""
  }

  private func renderMovieExtraDetails(movie: Movie) {
    if let duration = movie.duration {
      movieDurationLabel.text = duration
    }

    if let trailer = movie.trailer, key = trailer.key {
      playerView.loadVideoID(key)
    }
  }

  private func loadPosterImage(movie: Movie){
    if let posters = movie.posters, lowResPoster = posters[.Low], highResPoster = posters[.High] {
      let imageCache = ImageDownloader.defaultInstance.imageCache
      let highResImageRequest = NSURLRequest(URL: highResPoster)
      let highResCachedImage = imageCache?.imageForRequest(highResImageRequest, withAdditionalIdentifier: nil)

      if let highResImage = highResCachedImage {
        moviePosterImage.image = highResImage
      } else {
        let lowResImageRequest = NSURLRequest(URL: lowResPoster)

        ImageDownloader.defaultInstance.downloadImage(URLRequest: lowResImageRequest) { [weak self] response in
          if let lowResImage = response.result.value {
            self?.moviePosterImage.image = lowResImage
          }

          ImageDownloader.defaultInstance.downloadImage(URLRequest: highResImageRequest) { [weak self] response in
            if let highResImage = response.result.value {
              self?.moviePosterImage.image = highResImage
            }
          }
        }
      }
    }
  }

  @IBAction func didTapPlayVideo(sender: AnyObject) {
    if playerView.ready {
      playerView.play()
    }
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let vc = segue.destinationViewController as? PosterViewController, _ = moviePosterImage?.image {
      vc.movie = movie
    }
  }
}

extension MovieDetailsViewController: YouTubePlayerDelegate {
  func playerReady(videoPlayer: YouTubePlayerView) {
    playVideoButton.hidden = false
  }

  func playerQualityChanged(videoPlayer: YouTubePlayerView, playbackQuality: YouTubePlaybackQuality) { }

  func playerStateChanged(videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
    switch playerState {
    case .Ended, .Paused:
      view.setNeedsLayout()
    default: break
    }
  }
}
