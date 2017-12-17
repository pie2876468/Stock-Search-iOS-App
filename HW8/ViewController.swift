//
//  ViewController.swift
//  HW8
//
//  Created by 張任鋒 on 11/19/17.
//  Copyright © 2017 JFC. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireSwiftyJSON
import EasyToast
import SwiftSpinner
import SearchTextField

class ViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    var myFavoriteList:favoriteList = favoriteList()
    var sortbywhat = 0
    var sortorder = 0
    var myUserDefaults :UserDefaults!
    override func viewDidLoad() {
        super.viewDidLoad()
        //Auto-complete
        // Set data source
        inputSymbol.maxNumberOfResults = 5
        inputSymbol.maxResultsListHeight = 180
        //inputSymbol.startVisibleWithoutInteraction = true
        inputSymbol.userStoppedTypingHandler = {
            if let criteria = self.inputSymbol.text {
                if criteria.characters.count > 1 {
                    let url = "http://newphp2-env.fvkrppm399.us-west-1.elasticbeanstalk.com/service4.php?idx=autocompleteInfo&inSymbol=" + criteria
                    Alamofire.request(url).responseSwiftyJSON { response in
                        let json = response.result.value //A JSON object
                        let isSuccess = response.result.isSuccess
                        if (isSuccess && (json != nil)) {
                            var tmpSearchResult:[String] = [String]()
                            for idx in 0...json!.count {
                                if json![idx]["Symbol"].description != "null" && json![idx]["Name"].description != "null" && json![idx]["Exchange"].description != "null" {
                                    tmpSearchResult.append(json![idx]["Symbol"].description + " - " + json![idx]["Name"].description + " (" + json![idx]["Exchange"].description + ")")
                                }
                            }
                            //print(tmpSearchResult)
                            self.inputSymbol.filterStrings(tmpSearchResult)
                        }
                        else {
                        }
                    }
                }
            }
        } as (() -> Void)
        inputSymbol.itemSelectionHandler = { filteredResults, itemPosition in
            // Just in case you need the item position
            let item = filteredResults[itemPosition]
            print("Item at position \(itemPosition): \(item.title)")
            // Do whatever you want with the picked item
            self.inputSymbol.text = item.title
        }
        //===Auto-complete===
        self.SortBy.delegate = self
        self.SortBy.dataSource = self
        self.Order.delegate = self
        self.Order.dataSource = self
        Order.isUserInteractionEnabled = false
        favoriteTable.delegate = self //News Table
        favoriteTable.dataSource = self//News Table
        favoriteListLoadingActivity.hidesWhenStopped = true
        
        myUserDefaults = UserDefaults.standard
        
        
        if myFavoriteList.symbollist.count==0 {
            if let data = UserDefaults.standard.value(forKey:"info") as? Data {
                let info3 = try? PropertyListDecoder().decode(Array<stockDetail>.self, from: data)
                myFavoriteList.symbollist = info3!
                print(info3 ?? "Errot local Storage")
            } else {
                print("尚未儲存資訊")
            }
        }
 
        if myFavoriteList.symbollist.count != 0 {
            self.favoriteListLoadingActivity.startAnimating()
            self.refreshFavoriteList()
        }
        //testfavoriteList()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func testfavoriteList() {
        var a:stockDetail = stockDetail()
        var b:stockDetail = stockDetail()
        var c:stockDetail = stockDetail()
        a.symbol = "AAPL"
        b.symbol = "CSCO"
        c.symbol = "FB"
        a.lastPrice = 300
        b.lastPrice = 200
        c.lastPrice = 100
        a.change = 10
        b.change = 20
        c.change = 30
        a.changeP = 3
        b.changeP = 2
        c.changeP = 1
        a.defaultOrder = 0
        b.defaultOrder = 1
        c.defaultOrder = 2
        myFavoriteList.symbollist += [a,b,c]
    }
    
    //PickerView Setting
    @IBOutlet weak var SortBy: UIPickerView!
    @IBOutlet weak var Order: UIPickerView!
    let SortByData:[String] = ["Default","Symbol","Price","Change","Change(%)","Volume"]
    let OrderData:[String] = ["Ascending","Descending"]
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == SortBy {
            return SortByData.count
        }
        if pickerView == Order {
            return OrderData.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.black
        pickerLabel.font = UIFont(name: "Arial", size: 12) // In this use your custom font
        pickerLabel.textAlignment = NSTextAlignment.center
        if pickerView == SortBy {
            pickerLabel.text = SortByData[row]
        }
        if pickerView == Order {
            pickerLabel.text = OrderData[row]
        }
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        if pickerView == SortBy {
            sortbywhat = row
            print(SortByData[row])
            Order.isUserInteractionEnabled = true
            if sortorder==0 {
                switch sortbywhat {
                case 0:
                    Order.isUserInteractionEnabled = false
                    myFavoriteList.symbollist.sort{
                        $0.defaultOrder <= $1.defaultOrder
                    }
                    self.favoriteTable.reloadData()
                case 1:
                    myFavoriteList.symbollist.sort{
                        $0.symbol <= $1.symbol
                    }
                    self.favoriteTable.reloadData()
                case 2:
                    myFavoriteList.symbollist.sort{
                        $0.lastPrice <= $1.lastPrice
                    }
                    self.favoriteTable.reloadData()
                case 3:
                    myFavoriteList.symbollist.sort{
                        $0.change <= $1.change
                    }
                    self.favoriteTable.reloadData()
                case 4:
                    myFavoriteList.symbollist.sort{
                        $0.changeP <= $1.changeP
                    }
                    self.favoriteTable.reloadData()
                case 5:
                    myFavoriteList.symbollist.sort{
                        $0.volume <= $1.volume
                    }
                    self.favoriteTable.reloadData()
                default:
                    print("error")
                }
            }
            else {
                switch sortbywhat {
                case 0:
                    Order.isUserInteractionEnabled = false
                    myFavoriteList.symbollist.sort{
                        $0.defaultOrder > $1.defaultOrder
                    }
                    self.favoriteTable.reloadData()
                case 1:
                    myFavoriteList.symbollist.sort{
                        $0.symbol > $1.symbol
                    }
                    self.favoriteTable.reloadData()
                case 2:
                    myFavoriteList.symbollist.sort{
                        $0.lastPrice > $1.lastPrice
                    }
                    self.favoriteTable.reloadData()
                case 3:
                    myFavoriteList.symbollist.sort{
                        $0.change > $1.change
                    }
                    self.favoriteTable.reloadData()
                case 4:
                    myFavoriteList.symbollist.sort{
                        $0.changeP > $1.changeP
                    }
                    self.favoriteTable.reloadData()
                case 5:
                    myFavoriteList.symbollist.sort{
                        $0.volume > $1.volume
                    }
                    self.favoriteTable.reloadData()
                default:
                    print("error")
                }
            }
        }
        if pickerView == Order {
            sortorder = row
            print(OrderData[row])
            if sortorder==0 {
                switch sortbywhat {
                case 0:
                    myFavoriteList.symbollist.sort{
                        $0.defaultOrder <= $1.defaultOrder
                    }
                    self.favoriteTable.reloadData()
                case 1:
                    myFavoriteList.symbollist.sort{
                        $0.symbol <= $1.symbol
                    }
                    self.favoriteTable.reloadData()
                case 2:
                    myFavoriteList.symbollist.sort{
                        $0.lastPrice <= $1.lastPrice
                    }
                    self.favoriteTable.reloadData()
                case 3:
                    myFavoriteList.symbollist.sort{
                        $0.change <= $1.change
                    }
                    self.favoriteTable.reloadData()
                case 4:
                    myFavoriteList.symbollist.sort{
                        $0.changeP <= $1.changeP
                    }
                    self.favoriteTable.reloadData()
                case 5:
                    myFavoriteList.symbollist.sort{
                        $0.volume <= $1.volume
                    }
                    self.favoriteTable.reloadData()
                default:
                    print("error")
                }
            }
            else {
                switch sortbywhat {
                case 0:
                    myFavoriteList.symbollist.sort{
                        $0.defaultOrder > $1.defaultOrder
                    }
                    self.favoriteTable.reloadData()
                case 1:
                    myFavoriteList.symbollist.sort{
                        $0.symbol > $1.symbol
                    }
                    self.favoriteTable.reloadData()
                case 2:
                    myFavoriteList.symbollist.sort{
                        $0.lastPrice > $1.lastPrice
                    }
                    self.favoriteTable.reloadData()
                case 3:
                    myFavoriteList.symbollist.sort{
                        $0.change > $1.change
                    }
                    self.favoriteTable.reloadData()
                case 4:
                    myFavoriteList.symbollist.sort{
                        $0.changeP > $1.changeP
                    }
                    self.favoriteTable.reloadData()
                case 5:
                    myFavoriteList.symbollist.sort{
                        $0.volume > $1.volume
                    }
                    self.favoriteTable.reloadData()
                default:
                    print("error")
                }
            }
        }
        
    }
    //===PickerView Setting====


    
    private func checkAllSpace(input sample: String) -> Bool {
        var res: Bool = true
        for element in sample {
            if element != " " {
                res = false
            }
        }
        return res
    }

    @IBOutlet weak var inputSymbol: SearchTextField!
    @IBOutlet var MainPage: UIView!

    //Buttons
    @IBAction func GetQuoteButton(_ sender: UIButton) {
        let inputSymbol_ = inputSymbol.text
        //print("\(inputSymbol_ ?? "Input is nil")")
        if inputSymbol_==nil || (inputSymbol_!)=="" || checkAllSpace(input: inputSymbol_!) {
            self.view.showToast("Please enter a stock name of symbol", position: .bottom, popTime: 5, dismissOnTap: false)
            print("Error Input")
        } else {
            var tmpSymbol:String = ""
            for idx in inputSymbol_! {
                if idx != " " {
                    tmpSymbol.append(idx)
                }
                else {
                    break;
                }
            }
            self.myFavoriteList.tmpStock.symbol = tmpSymbol
            print(self.myFavoriteList.tmpStock.symbol)
            self.performSegue(withIdentifier: "main2detail", sender: self)
            //getData(targetSymbol: inputSymbol_)
        }
    }
    
    @IBAction func ClearButton(_ sender: UIButton) {
        inputSymbol.text = ""
    }
    //===Buttons===
    
    //Auto-complete
    // Hide keyboard when touching the screen
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    //===Auto-complete===
    
    //Favorite List
    @IBOutlet weak var favoriteTable: UITableView!
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 50
    }
    //table number
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return myFavoriteList.symbollist.count
    }
    //table data
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteListCellPro") as! FavoriteListTableViewCell
        cell.symbol.text = String(myFavoriteList.symbollist[indexPath.row].symbol)
        cell.price.text = "$" + String(myFavoriteList.symbollist[indexPath.row].lastPrice.R2D())
        cell.change.text = String(myFavoriteList.symbollist[indexPath.row].change.R2D()) + " (" + String((myFavoriteList.symbollist[indexPath.row].changeP*100).R2D()) + "%)"
        if(myFavoriteList.symbollist[indexPath.row].change >= 0) {
            cell.change.textColor = UIColor.green
        }
        else {
            cell.change.textColor = UIColor.red
        }
        return cell
    }
    //table delete
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            self.myFavoriteList.symbollist.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            print(self.myFavoriteList.symbollist)
            UserDefaults.standard.set(try? PropertyListEncoder().encode(myFavoriteList.symbollist), forKey:"info")
            myUserDefaults.synchronize()
        }
    }
    //tabl select
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.myFavoriteList.tmpStock.symbol = self.myFavoriteList.symbollist[indexPath.row].symbol
        print("Favorite List row selected: \(indexPath.row)  == \(self.myFavoriteList.tmpStock.symbol)")
        self.performSegue(withIdentifier: "main2detail", sender: self)
    }
    //===Favorite List===
    
    //Refresh
    @IBOutlet weak var autoRefreshSwitch: UISwitch!
    @IBOutlet weak var favoriteListLoadingActivity: UIActivityIndicatorView!
    var timer: Timer?
    @IBAction func autoRefreshSwitchAction(_ sender: Any) {
        if autoRefreshSwitch.isOn {
            print("Auto Refresh ON")
            timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.refreshEvery5Secs), userInfo: nil, repeats: true)
        }
        else {
            print("Auto Refresh OFF")
            timer?.invalidate()
            timer = nil
        }
    }
    @objc func refreshEvery5Secs(){
        favoriteListLoadingActivity.startAnimating()
        refreshFavoriteList()
    }
    @IBAction func refreshButton(_ sender: Any) {
        print("Click Refresh Button")
        favoriteListLoadingActivity.startAnimating()
        refreshFavoriteList()
    }

    var refreshCount:Int = 0
    private func refreshFavoriteList() {
        refreshCount = 0
        for idx in 0..<self.myFavoriteList.symbollist.count {
            getDataStockDetailAdv(targetSymbol: myFavoriteList.symbollist[idx].symbol)
        }
        UserDefaults.standard.set(try? PropertyListEncoder().encode(myFavoriteList.symbollist), forKey:"info")
        myUserDefaults.synchronize()
    }
    private func getDataStockDetailAdv(targetSymbol inputSymbol_: String?) {
        let url = "http://newphp2-env.fvkrppm399.us-west-1.elasticbeanstalk.com/service4.php?idx=quickSearch&inSymbol="+inputSymbol_!
        Alamofire.request(url).responseSwiftyJSON { response in
            let json = response.result.value //A JSON object
            let isSuccess = response.result.isSuccess
            if (isSuccess && (json != nil)) {
                //'msg' => 'Cannot Get Stock Information！'
                if(json!["InfoTable"]["Error Message"].description == "null" && json!["InfoTableIntraday"]["Error Message"].description == "null") {
                    //print(json!["InfoTable"]["Meta Data"]["2. Symbol"].description)
                    let tmpSymbol = json!["InfoTable"]["Meta Data"]["2. Symbol"].description
                    var tmpSymbolIdx:Int = 0
                    for idx in 0..<self.myFavoriteList.symbollist.count {
                        if(self.myFavoriteList.symbollist[idx].symbol == tmpSymbol) {
                            tmpSymbolIdx = idx
                            break
                        }
                    }
                    self.myFavoriteList.symbollist[tmpSymbolIdx].timeStamp = String(json!["InfoTableIntraday"]["Meta Data"]["3. Last Refreshed"].description)
                    self.myFavoriteList.symbollist[tmpSymbolIdx].lastPrice = Double(json!["InfoTableIntraday"]["Time Series (1min)"][self.myFavoriteList.symbollist[tmpSymbolIdx].timeStamp]["4. close"].description)!
                    
                    self.myFavoriteList.symbollist[tmpSymbolIdx].date = json!["InfoTable"]["Meta Data"]["3. Last Refreshed"].description

                    let index = self.myFavoriteList.symbollist[tmpSymbolIdx].date.index(self.myFavoriteList.symbollist[tmpSymbolIdx].date.startIndex, offsetBy: 10)
                    let mySubstring = self.myFavoriteList.symbollist[tmpSymbolIdx].date.prefix(upTo: index)
                    let mySubstring2 = mySubstring + " 16:00:00"
                    let mySubstring3 = mySubstring + " 09:00:00"
                    /*
                    print(mySubstring<mySubstring2)
                    print(mySubstring<mySubstring3)
                    print(json!["InfoTable"]["Meta Data"]["3. Last Refreshed"].description<mySubstring2)
                    print(json!["InfoTable"]["Meta Data"]["3. Last Refreshed"].description>mySubstring3)
                    print(json!["InfoTable"]["Meta Data"]["3. Last Refreshed"].description>mySubstring)
                    */
                    let stockOpen:Bool = json!["InfoTable"]["Meta Data"]["3. Last Refreshed"].description<mySubstring2 && json!["InfoTable"]["Meta Data"]["3. Last Refreshed"].description>mySubstring3
                    print("Stock Open ? \(stockOpen)")
                    //if self.myFavoriteList.symbollist[tmpSymbolIdx].date.count > 10 {}
                    var tmpDate:[String] = [String]()
                    for (index, _) in json!["InfoTable"]["Time Series (Daily)"] {
                        tmpDate.append(index)
                    }
                    tmpDate.sort(by: >)
                    if stockOpen {
                        self.myFavoriteList.symbollist[tmpSymbolIdx].date = tmpDate[1]
                        self.myFavoriteList.symbollist[tmpSymbolIdx].preDate = tmpDate[2]
                        print("Date: \(self.myFavoriteList.symbollist[tmpSymbolIdx].date);   PreDate:\(self.myFavoriteList.symbollist[tmpSymbolIdx].preDate)")
                    }
                    else {
                        self.myFavoriteList.symbollist[tmpSymbolIdx].date = tmpDate[0]
                        self.myFavoriteList.symbollist[tmpSymbolIdx].preDate = tmpDate[1]
                        print("Date: \(self.myFavoriteList.symbollist[tmpSymbolIdx].date);   PreDate:\(self.myFavoriteList.symbollist[tmpSymbolIdx].preDate)")
                    }
                    self.myFavoriteList.symbollist[tmpSymbolIdx].volume = Double(json!["InfoTable"]["Time Series (Daily)"][self.myFavoriteList.symbollist[tmpSymbolIdx].date]["5. volume"].description)!
                    self.myFavoriteList.symbollist[tmpSymbolIdx].high = Double(json!["InfoTable"]["Time Series (Daily)"][self.myFavoriteList.symbollist[tmpSymbolIdx].date]["2. high"].description)!
                    self.myFavoriteList.symbollist[tmpSymbolIdx].low = Double(json!["InfoTable"]["Time Series (Daily)"][self.myFavoriteList.symbollist[tmpSymbolIdx].date]["3. low"].description)!
                    self.myFavoriteList.symbollist[tmpSymbolIdx].open = Double(json!["InfoTable"]["Time Series (Daily)"][self.myFavoriteList.symbollist[tmpSymbolIdx].date]["1. open"].description)!
                    self.myFavoriteList.symbollist[tmpSymbolIdx].close = Double(json!["InfoTable"]["Time Series (Daily)"][self.myFavoriteList.symbollist[tmpSymbolIdx].date]["4. close"].description)!
                    // Change:  compare date and timestamp to determinate which close will be used
                    self.myFavoriteList.symbollist[tmpSymbolIdx].preclose = Double(json!["InfoTable"]["Time Series (Daily)"][self.myFavoriteList.symbollist[tmpSymbolIdx].preDate]["4. close"].description)!
                    if !stockOpen {
                        self.myFavoriteList.symbollist[tmpSymbolIdx].change = self.myFavoriteList.symbollist[tmpSymbolIdx].lastPrice -  self.myFavoriteList.symbollist[tmpSymbolIdx].preclose
                        self.myFavoriteList.symbollist[tmpSymbolIdx].changeP = self.myFavoriteList.symbollist[tmpSymbolIdx].change/self.myFavoriteList.symbollist[tmpSymbolIdx].preclose
                    }
                    else {
                        self.myFavoriteList.symbollist[tmpSymbolIdx].change = self.myFavoriteList.symbollist[tmpSymbolIdx].lastPrice -  self.myFavoriteList.symbollist[tmpSymbolIdx].close
                        self.myFavoriteList.symbollist[tmpSymbolIdx].changeP = self.myFavoriteList.symbollist[tmpSymbolIdx].change/self.myFavoriteList.symbollist[tmpSymbolIdx].close
                    }
                    // ===Change:  compare date and timestamp to determinate which close will be used===
                    
                    self.refreshCount += 1
                    print("Refresh: \(self.refreshCount) / \(self.myFavoriteList.symbollist.count)")
                    if(self.refreshCount == self.myFavoriteList.symbollist.count) {
                        self.favoriteTable.reloadData()
                        print("Refresh!!!!!!!!!")
                        self.favoriteListLoadingActivity.stopAnimating()
                    }
                }
                else {
                    self.view.showToast("Failed to refresh. Please try again later.", position: .bottom, popTime: 5, dismissOnTap: false)
                }
            }
            else {
                self.view.showToast("Failed to refresh. Please try again later.", position: .bottom, popTime: 5, dismissOnTap: false)
            }
        }
    }
    //===Refresh===
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "main2detail" {
            let destinationVC = segue.destination as! SecondViewController
            destinationVC.myFavoriteList = self.myFavoriteList
            print("1to2")
            print(self.myFavoriteList.symbollist)
        }
    }
}

