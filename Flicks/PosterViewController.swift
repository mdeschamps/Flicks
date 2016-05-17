//
//  PosterViewController.swift
//  Flicks
//
//  Created by Manuel Deschamps on 5/19/16.
//
//

import UIKit

class PosterViewController: UIViewController {

  @IBOutlet weak var posterImageView: UIImageView!
  @IBOutlet weak var scrollView: UIScrollView!

  var movie: Movie?

  override func viewDidLoad() {
    super.viewDidLoad()

    scrollView.delegate = self

    if let highResImageUrl = movie?.posters?[.High] {
      posterImageView.af_setImageWithURL(highResImageUrl)
    }
  }

  @IBAction func didTapDismiss(sender: AnyObject) {
    dismissViewControllerAnimated(false, completion: nil)
  }
}

extension PosterViewController: UIScrollViewDelegate {
  func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
    return posterImageView
  }
}
