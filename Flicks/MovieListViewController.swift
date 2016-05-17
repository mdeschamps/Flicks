//
//  MovieListViewController.swift
//  Flicks
//
//  Created by Manuel Deschamps on 5/19/16.
//
//

import UIKit

protocol MovieListCollection {
  func reloadMovies(movies: [Movie])
  func errorLoadingMovies()
}

class MovieListViewController: UIViewController {

  @IBOutlet weak var tableContainerView: UIView!
  @IBOutlet weak var collectionContainerView: UIView!
  @IBOutlet weak var containerToggle: UISegmentedControl!

  private var tableViewController: MovieTableViewController?
  private var collectionViewController: MovieCollectionViewController?

  var visibleCollectionViewController: MovieListCollection? {
    return containerToggle.selectedSegmentIndex == 0 ? tableViewController : collectionViewController
  }

  var movies: [Movie]? {
    didSet {
      if let movies = self.movies {
        visibleCollectionViewController?.reloadMovies(movies)
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    loadMoviews()
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    switch segue.destinationViewController {

    case let vc as MovieTableViewController:
      vc.delegate = self
      tableViewController = vc

    case let vc as MovieCollectionViewController:
      vc.delegate = self
      collectionViewController = vc

    default: break
    }
  }

  func loadMoviews() {  }

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

extension MovieListViewController: MovieTableDelegate {
  func reloadMovies() {
    loadMoviews()
  }
}