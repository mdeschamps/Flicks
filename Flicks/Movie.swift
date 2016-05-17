//
//  Movie.swift
//  Flicks
//
//  Created by Manuel Deschamps on 5/17/16.
//
//

import Foundation
import EVReflection

enum Resolution {
  case Low
  case High
}

class Movie: EVObject {

  static let BaseImageUrl = NSURL(string: "https://image.tmdb.org/t/p")

  static var Genres: [NSNumber: Genre] = {
    var result: [NSNumber: Genre] = [:]
    if let filePath = NSBundle.mainBundle().pathForResource("genres", ofType: "json"), data = NSData(contentsOfFile: filePath) {
      do {
        let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as! [NSDictionary]
        json.forEach{ genreDict  in
          if let genreId = genreDict["id"] as? NSNumber {
            result[genreId] = Genre(dictionary: genreDict)
          }
        }
      } catch { }
    }
    return result
  }()

  var id: NSNumber?
  var title: String?
  var overview: String?
  var originalLanguage: String?
  var originalTitle: String?
  var releaseDate: NSDate?
  var popularity: NSNumber?
  var voteCount: NSNumber?
  var posters: [Resolution: NSURL]?
  var backdrops: [Resolution: NSURL]?
  var revenue: NSNumber?
  var runtime: NSNumber?
  var duration: String?
  var videos: [Video]?
  var genres: [Genre]?

  private var initOnce = dispatch_once_t()

  required init(){
    super.init()

    dispatch_once(&initOnce) {
      let dateFormatter = NSDateFormatter()
      dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
      dateFormatter.dateFormat = "yyyy'-'MM'-'dd'"
      EVReflection.setDateFormatter(dateFormatter)
    }
  }

  var trailer: Video? {
    get {
      return self.videos?.filter({$0.site?.lowercaseString == "youtube"}).first
    }
  }

  override func propertyConverters() -> [(String?, ((Any?)->())?, (() -> Any?)? )] {
    return [
      ("poster_path"
          , {
            let posterPath = $0 as? String
            let lowResUrl = self.makeUrlFromPath(posterPath, resolution: .Low)
            let highResUrl = self.makeUrlFromPath(posterPath, resolution: .High)
            self.posters = [:]
            self.posters![.Low] = lowResUrl
            self.posters![.High] = highResUrl
          }
          , { return self.posters?[.Low]!.path!.characters.split{$0 == "/"}.last } ),

      ("backdrop_path"
        , {
          let backdropPath = $0 as? String
          let lowResUrl = self.makeUrlFromPath(backdropPath, resolution: .Low)
          let highResUrl = self.makeUrlFromPath(backdropPath, resolution: .High)
          self.backdrops = [:]
          self.backdrops![.Low] = lowResUrl
          self.backdrops![.High] = highResUrl
        }
        , { return self.backdrops?[.Low]!.path!.characters.split{$0 == "/"}.last } ),

      ("runtime"
        , {
          self.runtime = $0 as? NSNumber
          self.duration = self.minutesToHoursMinutes(self.runtime)
        }
        , { return self.runtime } ),

      ("genre_ids"
        , {
          self.genres = self.mapGenres($0 as? NSArray)
        }
        , { return self.genres?.map { return $0.id } } )
    ]
  }

  override func setValue(value: AnyObject!, forUndefinedKey key: String) { }

  private func makeUrlFromPath(path: NSString?, resolution: Resolution) -> NSURL? {
    guard let path = path else {
      return nil
    }
    switch resolution {
    case .Low:
      return Movie.BaseImageUrl?.URLByAppendingPathComponent("/w185\(path)")
    case .High:
      return Movie.BaseImageUrl?.URLByAppendingPathComponent("/original\(path)")
    }
  }

  private func mapGenres(genreIds: NSArray?) -> [Genre]? {
    guard let genreIds = genreIds else {
      return nil
    }

    return genreIds.flatMap { (genreId) -> Genre? in
      if let genreId = genreId as? NSNumber {
        return Movie.Genres[genreId]
      }
      return nil
    }
  }

  private func minutesToHoursMinutes(minutes : NSNumber?) -> String {
    if let minutes = minutes?.integerValue {
      let (h, m) = (minutes / 60, minutes % 60)
      return String(format:"%ih %im", h, m)
    }

    return ""
  }
}
