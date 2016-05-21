//
//  MovieTableViewController.swift
//  Flicks
//
//  Created by Manuel Deschamps on 5/16/16.
//
//

import UIKit

protocol MovieCollectionDelegate {
  func refreshMovieList()
}

class MovieTableViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var searchBar: UISearchBar?

  internal var delegate: MovieCollectionDelegate?

  private var movies: [Movie]? {
    didSet {
      refreshControl?.endRefreshing()
      
      tableView.hidden = false
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
    refreshControl = UIRefreshControl()
    refreshControl!.addTarget(self, action: #selector(pulledToRefresh), forControlEvents: UIControlEvents.ValueChanged)
    tableView.insertSubview(refreshControl!, atIndex: 0)
    
    tableView.registerNib(UINib(nibName: "MovieTableCell", bundle: nil), forCellReuseIdentifier: "movieCell")
    tableView.hidden = true
  }

  @objc private func pulledToRefresh(){
    guard let delegate = delegate else {
      refreshControl?.endRefreshing()
      return
    }
    delegate.refreshMovieList()
  }
}

extension MovieTableViewController: MovieListCollection {
  func reloadMovies(movies: [Movie]) {
    self.movies = movies
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
