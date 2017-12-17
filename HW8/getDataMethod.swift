//
//  getDataMethod.swift
//  HW8
//
//  Created by 張任鋒 on 11/21/17.
//  Copyright © 2017 JFC. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireSwiftyJSON
import EasyToast
import SwiftSpinner

/*
func getDataStockDetail(targetSymbol inputSymbol_: String?) {
    SwiftSpinner.show("Loading data", animated: true)
    let url = "http://newphp2-env.fvkrppm399.us-west-1.elasticbeanstalk.com/service4.php?idx=stocktInfo0&inSymbol="+inputSymbol_!
    Alamofire.request(url).responseSwiftyJSON { response in
        let json = response.result.value //A JSON object
        let isSuccess = response.result.isSuccess
        if (isSuccess && (json != nil)) {
            print(json!["InfoTable"]["Meta Data"]["2. Symbol"].description)
            //self.myFavoriteList.tmpStock.symbol = json!["InfoTable"]["Meta Data"]["2. Symbol"].description
            SwiftSpinner.hide()
        }
        else {
            SwiftSpinner.hide()
        }
    }
}
func getDataNews(targetSymbol inputSymbol_: String?) {
    let url = "http://newphp2-env.fvkrppm399.us-west-1.elasticbeanstalk.com/service4.php?idx=News&inSymbol="+inputSymbol_!
    Alamofire.request(url).responseSwiftyJSON { response in
        let json = response.result.value //A JSON object
        let isSuccess = response.result.isSuccess
        if (isSuccess && (json != nil)) {
            print(json!["InfoTable"]["Meta Data"]["2. Symbol"].description)
            //self.myFavoriteList.tmpStock.symbol = json!["InfoTable"]["Meta Data"]["2. Symbol"].description
            
        }
        else {
        }
    }
}
*/
