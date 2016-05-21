//
//  MovieListViewController.swift
//  Flicks
//
//  Created by Manuel Deschamps on 5/19/16.
//
//

import UIKit
import SwiftLoader

protocol MovieListCollection {
  func reloadMovies(movies: [Movie])
}

class MovieListViewController: UIViewController {

  @IBOutlet weak var tableContainerView: UIView!
  @IBOutlet weak var collectionContainerView: UIView!
  @IBOutlet weak var containerToggle: UISegmentedControl!
  @IBOutlet weak var errorMessageLabel: UILabel?

  private var tableViewController: MovieTableViewController?
  private var collectionViewController: MovieCollectionViewController?

  var visibleCollectionViewController: MovieListCollection? {
    return containerToggle.selectedSegmentIndex == 0 ? tableViewController : collectionViewController
  }

  var movies: [Movie]? {
    didSet {
      if let movies = self.movies {
        SwiftLoader.hide()
        hideErrorMessage()
        
        visibleCollectionViewController?.reloadMovies(movies)
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    var config: SwiftLoader.Config = SwiftLoader.Config()
    config.size = 150
    config.spinnerColor = .darkGrayColor()
    config.backgroundColor = UIColor(red:0, green:0, blue:0, alpha:0)
    SwiftLoader.setConfig(config)

    SwiftLoader.show(animated: true)

    loadMovies()
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    switch segue.destinationViewController {

    case let vc as MovieTableViewController:
      vc.delegate = self
      tableViewController = vc

    case let vc as MovieCollectionViewController:
      collectionViewController = vc

    default: break
    }
  }

  internal func loadMovies() {  }

  internal func showErrorMessage() {
    guard let errorMessageLabel = self.errorMessageLabel else {
      return
    }

    SwiftLoader.hide()

    let frame = errorMessageLabel.frame
    errorMessageLabel.frame.origin.y = -errorMessageLabel.frame.height

    errorMessageLabel.hidden = false

    UIView.animateWithDuration(0.6) {
      errorMessageLabel.frame = frame
    }
  }

  internal func hideErrorMessage(){
    errorMessageLabel?.hidden = true
  }

  @IBAction func didTapToggle(sender: AnyObject) {
    if let movies = self.movies {
      visibleCollectionViewController?.reloadMovies(movies)
    }
    
    var transitionOptions: UIViewAnimationOptions = [.TransitionFlipFromLeft, .ShowHideTransitionViews]
    var inView = tableContainerView
    var outView = collectionContainerView

    if containerToggle.selectedSegmentIndex == 1 {
      outView = tableContainerView
      inView = collectionContainerView
      transitionOptions = [.TransitionFlipFromRight, .ShowHideTransitionViews]
    }

    UIView.transitionWithView(outView, duration: 1.0, options: transitionOptions, animations: {
      outView.hidden = true

    }, completion: nil)

    UIView.transitionWithView(inView, duration: 1.0, options: transitionOptions, animations: {
      inView.hidden = false
    }, completion: nil)
  }
}

extension MovieListViewController: MovieCollectionDelegate {
  func refreshMovieList() {
    hideErrorMessage()
    loadMovies()
  }
}