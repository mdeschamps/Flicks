//
//  MovieTableViewController.swift
//  Flicks
//
//  Created by Manuel Deschamps on 5/16/16.
//
//

import UIKit
import SwiftLoader

protocol MovieTableDelegate {
  func reloadMovies()
}

class MovieTableViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var errorMessageLabel: UILabel?
  @IBOutlet weak var searchBar: UISearchBar?

  var delegate: MovieTableDelegate?

  private var movies: [Movie]? {
    didSet {
      refreshControl?.endRefreshing()

      SwiftLoader.hide()
      tableView.hidden = false

      hideErrorMessage()
      tableView.reloadData()
    }
  }
  private var filteredMovies: [Movie]?
  private var isSearchingMovies: Bool = false
  private var activeMoviesList: [Movie]? {
    get {
      return isSearchingMovies ? filteredMovies : movies
    }
  }
  private var refreshControl: UIRefreshControl?

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.dataSource = self
    tableView.delegate = self
    searchBar?.delegate = self

    initUIElements()
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    guard let cell = sender as? UITableViewCell,
      indexPath = tableView.indexPathForCell(cell),
      vc = segue.destinationViewController as? MovieDetailsViewController
    else {
      return
    }

    view.endEditing(true)

    if let movie = activeMoviesList?[indexPath.row] {
      vc.movie = movie
    }
  }

  private func initUIElements() {
    tableView.registerNib(UINib(nibName: "MovieTableCell", bundle: nil), forCellReuseIdentifier: "movieCell")
    tableView.hidden = true

    var config: SwiftLoader.Config = SwiftLoader.Config()
    config.size = 150
    config.spinnerColor = .darkGrayColor()
    config.backgroundColor = UIColor(red:0, green:0, blue:0, alpha:0)
    SwiftLoader.setConfig(config)

    SwiftLoader.show(animated: true)

    refreshControl = UIRefreshControl()
    refreshControl!.addTarget(self, action: #selector(pulledToRefresh), forControlEvents: UIControlEvents.ValueChanged)
    tableView.insertSubview(refreshControl!, atIndex: 0)
  }

  func showErrorMessage() {
    guard let errorMessageLabel = self.errorMessageLabel else {
      return
    }

    let frame = errorMessageLabel.frame
    errorMessageLabel.frame.origin.y = -errorMessageLabel.frame.height

    errorMessageLabel.hidden = false

    UIView.animateWithDuration(0.6) {
      errorMessageLabel.frame = frame
    }
  }

  @objc private func pulledToRefresh(){
    guard let delegate = delegate else {
      refreshControl?.endRefreshing()
      return
    }

    hideErrorMessage()
    delegate.reloadMovies()
  }

  private func hideErrorMessage(){
    errorMessageLabel?.hidden = true
  }
}

extension MovieTableViewController: MovieListCollection {
  func reloadMovies(movies: [Movie]) {
    self.movies = movies
  }

  func errorLoadingMovies() {
    showErrorMessage()
  }
}

extension MovieTableViewController: UITableViewDataSource {

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return activeMoviesList?.count ?? 0
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    guard let movieCell = tableView.dequeueReusableCellWithIdentifier("movieCell") as? MovieTableCell else {
      return UITableViewCell()
    }

    if let movie = activeMoviesList?[indexPath.row] {
      movieCell.movie = movie
    }

    return movieCell
  }
}

extension MovieTableViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    performSegueWithIdentifier("movieDetails", sender: tableView.cellForRowAtIndexPath(indexPath))
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }

  func scrollViewWillBeginDragging(scrollView: UIScrollView) {
    searchBar?.resignFirstResponder()
  }
}

extension MovieTableViewController: UISearchBarDelegate {

  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    if(searchText.characters.count > 0){
      isSearchingMovies = true
      filteredMovies = movies?.filter({ (movie) -> Bool in
        guard let title = movie.title else { return false }
        return title.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil
      })
    } else {
      isSearchingMovies = false
      filteredMovies = []
    }

    self.tableView.reloadData()
  }
}
