//
//  Video.swift
//  Flicks
//
//  Created by Manuel Deschamps on 5/18/16.
//
//

import Foundation
import EVReflection

class Video: EVObject {

  var id: String?
  var key: String?
  var name: String?
  var site: String?
  var size: NSNumber?
  var type: String?

  override func setValue(value: AnyObject!, forUndefinedKey key: String) { }
}