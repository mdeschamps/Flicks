//
//  MovieCollectionViewController.swift
//  Flicks
//
//  Created by Manuel Deschamps on 5/19/16.
//
//

import UIKit
import SwiftLoader

class MovieCollectionViewController: UIViewController {

  @IBOutlet weak var collectionView: UICollectionView!

  var delegate: MovieTableDelegate?

  private var movies: [Movie]? {
    didSet {
      SwiftLoader.hide()
      collectionView.hidden = false
      collectionView.reloadData()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    collectionView.dataSource = self
    collectionView.delegate = self

    initUIElements()
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    guard let cell = sender as? UICollectionViewCell,
      indexPath = collectionView.indexPathForCell(cell),
      vc = segue.destinationViewController as? MovieDetailsViewController
      else {
        return
    }

    if let movie = movies?[indexPath.row] {
      vc.movie = movie
    }
  }

  override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    collectionView.collectionViewLayout.invalidateLayout()
  }

  private func initUIElements() {
    collectionView.registerNib(UINib(nibName: "MovieCollectionCell", bundle: nil), forCellWithReuseIdentifier: "movieCollectionCell")
    collectionView.hidden = true

    SwiftLoader.show(animated: true)
  }

  func showMoviesResponse(response: MoviesResponse) {
    SwiftLoader.hide()
    collectionView.hidden = false

    if case let .Success(movies) = response {
      self.movies = movies
      collectionView.reloadData()
    }
  }
}


extension MovieCollectionViewController: MovieListCollection {
  func reloadMovies(movies: [Movie]) {
    self.movies = movies
  }

  func errorLoadingMovies() { }
}

extension MovieCollectionViewController: UICollectionViewDataSource {
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return movies?.count ?? 0
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    guard let movieCell = collectionView.dequeueReusableCellWithReuseIdentifier("movieCollectionCell", forIndexPath: indexPath) as? MovieCollectionViewCell else {
      return MovieCollectionViewCell()
    }

    if let movie = movies?[indexPath.row] {
      movieCell.movie = movie
    }

    return movieCell
  }
}

extension MovieCollectionViewController: UICollectionViewDelegate {

  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    performSegueWithIdentifier("movieDetails", sender: collectionView.cellForItemAtIndexPath(indexPath))
    collectionView.deselectItemAtIndexPath(indexPath, animated: true)
  }
}

extension MovieCollectionViewController: UICollectionViewDelegateFlowLayout {

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    let totalwidth = view.bounds.size.width;

    var numberOfCellsPerRow: CGFloat
    if UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation) {
      numberOfCellsPerRow = 3
    } else {
      numberOfCellsPerRow = 2
    }

    let dimensions: CGFloat = totalwidth / numberOfCellsPerRow
    return CGSizeMake(dimensions-15, 250)
  } 

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
  }
}