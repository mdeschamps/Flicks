//
//  Genre.swift
//  Flicks
//
//  Created by Manuel Deschamps on 5/19/16.
//
//

import Foundation
import EVReflection

class Genre: EVObject {

  var id: NSNumber?
  var name: String?

  override func setValue(value: AnyObject!, forUndefinedKey key: String) { }
}
