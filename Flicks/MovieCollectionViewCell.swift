//
//  MovieCollectionViewCell.swift
//  Flicks
//
//  Created by Manuel Deschamps on 5/19/16.
//
//

import UIKit
import AlamofireImage

class MovieCollectionViewCell: UICollectionViewCell {
    
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var genreLabel: UILabel!
  @IBOutlet weak var posterImage: UIImageView!

  var movie: Movie? {
    didSet {
      guard let movie = self.movie else {
        return
      }

      titleLabel.text = movie.title
      genreLabel.text = movie.genres?.first?.name ?? ""
      
      if let posters = movie.posters, posterUrl = posters[.Low] {
        loadPosterImage(posterUrl)
      }
    }
  }

  private func loadPosterImage(posterUrl: NSURL){
    let imageCache = ImageDownloader.defaultInstance.imageCache
    let imageRequest = NSURLRequest(URL: posterUrl)
    let cachedImage = imageCache?.imageForRequest(imageRequest, withAdditionalIdentifier: nil)

    if let image = cachedImage {
      posterImage.image = image
    } else {
      ImageDownloader.defaultInstance.downloadImage(URLRequest: imageRequest) { [weak self] response in
        if let image = response.result.value, weakSelf = self {
          weakSelf.posterImage.alpha = 0.0
          weakSelf.posterImage.image = image
          weakSelf.posterImage.contentMode = .ScaleAspectFill
          UIView.animateWithDuration(0.3, animations: { () -> Void in
            self?.posterImage.alpha = 1.0
          })
        }
      }
    }
  }
}
