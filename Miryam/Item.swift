//
//  Item.swift
//  Miryam
//
//  Created by Rafael da Silva Ferreira on 29/03/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
