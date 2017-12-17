//
//  Model.swift
//  HW8
//
//  Created by 張任鋒 on 11/19/17.
//  Copyright © 2017 JFC. All rights reserved.
//

import Foundation

struct favoriteList {
    var symbollist = [stockDetail]()
    var tmpStock:stockDetail = stockDetail()
}

struct stockDetail:Codable {
    var symbol = "a"
    var lastPrice = 0.0
    var change = 0.0
    var changeP = 0.0
    var defaultOrder = 0
    var date = ""
    var preDate = ""
    var timeStamp = "00"
    var open = 0.0
    var close = 0.0
    var preclose = 0.0
    var low = 0.0
    var high = 0.0
    var volume = 0.0
    //var news = [News]()
}

struct News {
    var title = ""
    var url = ""
    var author = ""
    var Date = ""
}

struct indicatorDataType {
    var date = ""
    var value = ""
    var value2 = ""
    var value3 = ""
    
}

struct HistoricalPriceElemnt {
    var timeStamp:String = ""
    var price:String = ""
}
