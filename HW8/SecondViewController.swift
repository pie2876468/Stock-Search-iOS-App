//
//  SecondViewController.swift
//  HW8
//
//  Created by 張任鋒 on 11/19/17.
//  Copyright © 2017 JFC. All rights reserved.
//

import UIKit
import EasyToast
import SwiftSpinner
import Alamofire
import AlamofireSwiftyJSON
import FacebookShare
import MobileCoreServices

class SecondViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    var myUserDefaults :UserDefaults!
    var myFavoriteList:favoriteList = favoriteList()
    var myNews = [News]()
    //var data = ["Stock Symbol \t ", "Last Price \t\t ", "Change \t\t ", "Timestamp \t ", "Open \t\t\t ", "Close \t\t\t ", "Day's Range \t ", "Volume \t\t "]
    var stockDetailsTopic:[String] = ["Stock Symbol", "Last Price", "Change", "Timestamp", "Open", "Close", "Day's Range", "Volume"]
    var stockDetailsContent:[String] = [" ", " ", " ", " ", " ", " ", " ", " "]
    var myHistoricalChartData = [HistoricalPriceElemnt]()
    
    override func viewWillAppear(_ animated: Bool) {
        Symbolname.text = myFavoriteList.tmpStock.symbol
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        currentSeg.isHidden = false
        HistorSeg.isHidden = true
        newsSeg.isHidden = true
        errorMessage.isHidden = true
        self.indicatorsPickerView.delegate = self
        self.indicatorsPickerView.dataSource = self
        favoriteListButton.setTitle("☆", for: UIControlState.normal)
        for i in myFavoriteList.symbollist.indices {
            if(myFavoriteList.symbollist[i].symbol == myFavoriteList.tmpStock.symbol) {
                favoriteListButton.setTitle("★", for: UIControlState.normal)
            }
        }
        getDataStockDetailAdv(targetSymbol: myFavoriteList.tmpStock.symbol)
        getDataNews(targetSymbol: myFavoriteList.tmpStock.symbol)
        stockDetailsTableView.delegate = self //Stock Table
        stockDetailsTableView.dataSource = self//Stock Table
        newsTableView.delegate = self //News Table
        newsTableView.dataSource = self//News Table
        stockDetailsTableView.isScrollEnabled = false;
        //Historical Part
        HistoricalActivity.hidesWhenStopped = true
        indicatorWevViewLoading.hidesWhenStopped = true
        indicatorsChangeButton.isEnabled = false
        indicatorWevViewLoading.startAnimating()
        loadHtml()
        indicatorsWebView.isHidden = true
        let when = DispatchTime.now() + 4 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            if self.isError == false {
                self.indicatorsWebView.isHidden = false
                let js:String = "Begin(0,'\(self.myFavoriteList.tmpStock.symbol)');"
                _ = self.indicatorsWebView.stringByEvaluatingJavaScript(from: js)
            }
            else {
                self.view.showToast("Failed to load data and display the chart!", position: .bottom, popTime: 5, dismissOnTap: false)
            }
        }
        
        myUserDefaults = UserDefaults.standard
        //getSMA(targetSymbol: myFavoriteList.tmpStock.symbol, highchartContent: indictorsHighchartString)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var stockDetailSegCtrl: UISegmentedControl!
    @IBOutlet weak var currentSeg: UIScrollView!
    @IBOutlet weak var HistorSeg: UIView!
    @IBOutlet weak var newsSeg: UITableView!
    @IBOutlet weak var HistorWeb: UIWebView!
    @IBOutlet weak var favoriteListButton: UIButton!
    @IBOutlet weak var Symbolname: UILabel!
    @IBOutlet weak var HistoricalActivity: UIActivityIndicatorView!
    
    var isError:Bool = false
    @IBOutlet weak var errorMessage: UILabel!
    
    //FB post
    
    @IBOutlet weak var fbButton: UIButton!
    
    func showShareDialog<C: ContentProtocol>(_ content: C, mode: ShareDialogMode = .automatic) {
        let dialog = ShareDialog(content: content)
        dialog.presentingViewController = self
        dialog.mode = mode
        dialog.completion = { result in
            switch result {
            case .success:
                self.view.showToast("Share Successfully!", position: .bottom, popTime: 5, dismissOnTap: false)
            case .cancelled:
                self.view.showToast("Share Cancelled!", position: .bottom, popTime: 5, dismissOnTap: false)
            case .failed:
                self.view.showToast("Share Failed!", position: .bottom, popTime: 5, dismissOnTap: false)
            }
        }
        do {
            try dialog.show() 
        } catch (let error) {
            //let alertController = UIAlertController(title: "Invalid share content", message: "Failed to present share dialog with error \(error)")
            //present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func FBpost(_ sender: Any) {
        let js:String = "GetFBurl();"
        let highchartUrl:String = self.indicatorsWebView.stringByEvaluatingJavaScript(from: js)!
        //print(highchartUrl)
        let url = URL(string: highchartUrl)
        var content = LinkShareContent(url: url!)
        // placeId is hardcoded here, see https://developers.facebook.com/docs/graph-api/using-graph-api/#search for building a place picker.
        content.placeId = "465570600503313"
        showShareDialog(content, mode: .web)
    }
    
    //===fb post
    @IBAction func favoriteListChange(_ sender: Any) {
        if favoriteListButton.currentTitle == "☆" {
            favoriteListButton.setTitle("★", for: UIControlState.normal)
            myFavoriteList.tmpStock.defaultOrder = myFavoriteList.symbollist.count
            myFavoriteList.symbollist += [myFavoriteList.tmpStock]
        }
        else {
            favoriteListButton.setTitle("☆", for: UIControlState.normal)
            var idx = 0
            for i in myFavoriteList.symbollist.indices {
                if(myFavoriteList.symbollist[i].symbol == myFavoriteList.tmpStock.symbol) {
                    idx = i
                }
            }
            myFavoriteList.symbollist.remove(at: idx)
        }
        UserDefaults.standard.set(try? PropertyListEncoder().encode(myFavoriteList.symbollist), forKey:"info")
        myUserDefaults.synchronize()
    }
    @IBAction func segChanged(_ sender: Any) {
        switch stockDetailSegCtrl.selectedSegmentIndex
        {
            case 0:
                currentSeg.isHidden = false
                HistorSeg.isHidden = true
                newsSeg.isHidden = true
                errorMessage.isHidden = true
            case 1:
                //Historical Part
                currentSeg.isHidden = true
                newsSeg.isHidden = true
                if isError == false {
                    HistorSeg.isHidden = false
                    //getHistoricalChartDetail(targetSymbol: myFavoriteList.tmpStock.symbol)
                    //HistoricalActivity.startAnimating()
                    //HistorWeb.isHidden = true
                    HistoricalActivity.startAnimating()
                    loadHtml2()
                    let when = DispatchTime.now() + 2 // change 2 to desired number of seconds
                    //let when2 = DispatchTime.now() + 6 // change 2 to desired number of seconds
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        let js:String = "Begin('\(self.myFavoriteList.tmpStock.symbol)');"
                        _ = self.HistorWeb.stringByEvaluatingJavaScript(from: js)
                    }
                    /*
                    DispatchQueue.main.asyncAfter(deadline: when2) {
                        self.HistorWeb.isHidden = false
                        self.HistoricalActivity.stopAnimating()
                    }
                     */
                }
                else {
                    HistorSeg.isHidden = true
                    errorMessage.isHidden = false
                    errorMessage.text = "Failed to load historical data"
                }
            case 2:
                currentSeg.isHidden = true
                HistorSeg.isHidden = true
                if isError == false {
                    newsSeg.isHidden = false
                }
                else {
                    newsSeg.isHidden = true
                    errorMessage.isHidden = false
                    errorMessage.text = "Failed to load news data"
                }
            default:
            break
        }
    }
    //stock table
    @IBOutlet weak var stockDetailsTableView: UITableView!
    //news table
    @IBOutlet weak var newsTableView: UITableView!
    //table height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tableView==stockDetailsTableView) {
            return 50
        }
        else if(tableView==newsTableView) {//should be the same as the value in Main.storyboard
            return 180
        }
        return 100
    }
    //table number
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView==stockDetailsTableView) {
            return stockDetailsTopic.count
        }
        else if(tableView==newsTableView) {
            return myNews.count
        }
        return 0
    }
    //table data
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let tmpcell = UITableViewCell(style: .default, reuseIdentifier: nil)
        if(tableView==stockDetailsTableView) {
            //let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            //cell.textLabel?.text = data[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "StockDetailsTableViewPro") as! StockDetailsTableViewCell
            cell.topic.text = stockDetailsTopic[indexPath.row]
            cell.content.text = stockDetailsContent[indexPath.row]
            cell.arrow.isHidden = true
            if indexPath.row==2 && isError==false {
                cell.arrow.isHidden = false
                if self.myFavoriteList.tmpStock.change < 0 {
                    cell.arrow.image = #imageLiteral(resourceName: "Red_Arrow_Down.png")
                }
            }
            return cell
        }
        else if(tableView==newsTableView) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCellPro") as! NewsTableViewCell
            cell.Title.text = myNews[indexPath.row].title
            cell.Author.text = myNews[indexPath.row].author
            cell.Date.text = myNews[indexPath.row].Date
            return cell
        }
        return tmpcell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(tableView==newsTableView) {
            if let url = URL(string: myNews[indexPath.row].url) {
                UIApplication.shared.open(url, options: [:])
            }
        }
        print("row selected: \(indexPath.row)")
    }
    
    //Indicators

    @IBOutlet weak var indicatorsPickerView: UIPickerView!
    @IBOutlet weak var indicatorsWebView: UIWebView!
    @IBOutlet weak var indicatorsChangeButton: UIButton!
    @IBOutlet weak var indicatorWevViewLoading: UIActivityIndicatorView!
    
    let indicators:[String] = ["Price", "SMA", "EMA", "STOCH", "RSI", "ADX", "CCI", "BBANDS", "MACD"]
    var indicatorschosenIdx:Int = 0
    var indicatorsPickerIdx:Int = 0
    var indictorsHighchartString:String = ""
    
    @IBAction func indicatorsChangeAct(_ sender: Any) {
        indicatorschosenIdx = indicatorsPickerIdx
        print(indicatorschosenIdx)
        indicatorsChangeButton.isEnabled = false
        //let tmpContent:String = "<html><body>" + indicators[indicatorschosenIdx] + "</body></html>"
        //indicatorsWebView.loadHTMLString(tmpContent, baseURL: nil)
        /*
        indicatorsWebView.isHidden = true
        indicatorWevViewLoading.startAnimating()
        let js:String = "Begin(\(indicatorschosenIdx),'\(myFavoriteList.tmpStock.symbol)');"
        _ = indicatorsWebView.stringByEvaluatingJavaScript(from: js)
        let when = DispatchTime.now() + 2.5 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.indicatorsWebView.isHidden = false
            self.indicatorWevViewLoading.stopAnimating()
        }
        */
        loadHtml()
        indicatorsWebView.isHidden = true
        //indicatorWevViewLoading.startAnimating()
        let when = DispatchTime.now() + 2 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.indicatorsWebView.isHidden = false
            let js:String = "Begin(\(self.indicatorschosenIdx),'\(self.myFavoriteList.tmpStock.symbol)');"
            _ = self.indicatorsWebView.stringByEvaluatingJavaScript(from: js)
            //self.indicatorWevViewLoading.stopAnimating()
        }
    }
    
    func loadHtml() {
        // Adding webView content
        do {
            guard let filePath = Bundle.main.path(forResource: "index", ofType: "html")
                else {
                    // File Error
                    print ("File reading error")
                    return
            }
            let contents =  try String(contentsOfFile: filePath, encoding: .utf8)
            let baseUrl = URL(fileURLWithPath: filePath)
            indicatorsWebView.loadHTMLString(contents as String, baseURL: baseUrl)
        }
        catch {
            print ("File HTML error")
        }
    }
    func loadHtml2() {
        // Adding webView content
        do {
            guard let filePath = Bundle.main.path(forResource: "index2", ofType: "html")
                else {
                    // File Error
                    print ("File reading error")
                    return
            }
            let contents =  try String(contentsOfFile: filePath, encoding: .utf8)
            let baseUrl = URL(fileURLWithPath: filePath)
            HistorWeb.loadHTMLString(contents as String, baseURL: baseUrl)
        }
        catch {
            print ("File HTML error")
        }
    }
    //PickerView setting
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return indicators.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.black
        pickerLabel.font = UIFont(name: "Arial", size: 12) // In this use your custom font
        pickerLabel.textAlignment = NSTextAlignment.center
        pickerLabel.text = indicators[row]
        return pickerLabel
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        print(indicators[row])
        indicatorsPickerIdx = row
        if indicatorschosenIdx != indicatorsPickerIdx {
            indicatorsChangeButton.isEnabled = true
        }
    }
    //===Indicators
    
    
    
    private func HistorialSegContentGen(inputsymbol:String, inputdata: [HistoricalPriceElemnt]) -> String {
        var HistorialSegContent =
        "<html><head><script src='https://code.highcharts.com/stock/highstock.js'></script><script src='https://code.highcharts.com/stock/modules/exporting.js'></script><script src='http://code.highcharts.com/stock/highcharts-more.js'></script></head><body><div id='containerHistoricalChart' style=' max-width: 1000px; max-height: 2500px; margin: 0 auto'></div><script type='text/JavaScript'>"
        HistorialSegContent = HistorialSegContent + "var title ='" + inputsymbol + "';"
        //let data = "[[1290729600000,45.00],[1290988800000,45.27],[1291075200000,44.45]]"
        var data = "["
        for idx in inputdata.indices {
            if idx != 0 {
                data = data + ","
            }
            data = data + "[" + inputdata[idx].timeStamp + "," + inputdata[idx].price + "]"
            
        }
        data = data + "]"
        HistorialSegContent = HistorialSegContent + "var yyHistoricalPrice = " + data + ";yyHistoricalPrice.reverse();"
        HistorialSegContent = HistorialSegContent + "function fillHistoricalChart() {Highcharts.stockChart('containerHistoricalChart', {rangeSelector: {buttons: [{type: 'month',count: 1,text: '1m'}, {type: 'month',count: 3,text: '3m'}, {type: 'month',count: 6,text: '6m'}, {type: 'year',count: 1,text: '1y'}, {type: 'all',text: 'All'}],selected: 0},title: {text: title+' Stock Value'},subtitle: {text: 'Source: <a href=\"http://www.alphavantage.co/\"> Alpha Vantage</a>',style: {color: '#0000FF'}},yAxis: [{title: {text: 'Stock Value'},min: 0,}],series: [{type: 'area',name: title,data: yyHistoricalPrice,tooltip: {valueDecimals: 2}}]});};"
        HistorialSegContent = HistorialSegContent + "fillHistoricalChart();"
        HistorialSegContent = HistorialSegContent + "</script></body></html>"
        return HistorialSegContent
    }
    
    /*
    private func IndicatorsContentGen_SMA(inpuutSymbol:String, input: [indicatorDataType]) -> String {
        var IndicatorsContent = "{chart: {type: 'line',zoomType: 'x'},title: {text: 'Simple Moving Average (SMA)'},subtitle: {text: 'Source: <a href=\"http://www.alphavantage.co/\"> Alpha Vantage</a>',style: {color: '#0000FF'}},xAxis: {categories:"
        var data = "["
        for idx in input.indices {
            if idx != 0 {
                data = data + ","
            }
            data = data + "'" + input[idx].date + "'"
            
        }
        data = data + "]"
        IndicatorsContent += data
        IndicatorsContent += ",tickInterval: 5},yAxis: {"
        IndicatorsContent += "'" + inpuutSymbol + "'"
        IndicatorsContent += ": {text: 'SMA'},},legend: {layout: 'horizontal',align: 'center',verticalAlign: 'bottom'},plotOptions: {series: {marker: {enabled: true}}},series: [{name:"
        IndicatorsContent += "'" + inpuutSymbol + "'"
        IndicatorsContent += ",data:"
        data = "["
        for idx in input.indices {
            if idx != 0 {
                data = data + ","
            }
            data = data + input[idx].value
        }
        data = data + "]"
        IndicatorsContent += data
        IndicatorsContent += ",color: '#FF0000',marker:{symbol : 'square',radius : 3 }}]}"
        return IndicatorsContent
    }
    
    private func IndicatorsHtmlGen(inputData: String) -> String {
        var IndicatorsHtmlContent = "<html><head><script src='https://code.highcharts.com/highcharts.js'></script></head><body><div id='containerHistoricalChart' style=' max-width: 1000px; max-height: 2500px; margin: 0 auto'></div><script type='text/JavaScript'> function Indicators() {Highcharts.chart('containerHistoricalChart', "
        IndicatorsHtmlContent += inputData + ");} Indicators();</script></body></html>"
        return IndicatorsHtmlContent
    }
    */
    
    private func getDataStockDetail(targetSymbol inputSymbol_: String?) {
        SwiftSpinner.show("Loading data", animated: true)
        let url = "http://newphp2-env.fvkrppm399.us-west-1.elasticbeanstalk.com/service4.php?idx=stocktInfo0&inSymbol="+inputSymbol_!
        Alamofire.request(url).responseSwiftyJSON { response in
            let json = response.result.value //A JSON object
            let isSuccess = response.result.isSuccess
            if (isSuccess && (json != nil)) {
                //'msg' => 'Cannot Get Stock Information！'
                if(json!["msg"].description=="null") {
                    //print(json!["InfoTable"]["Meta Data"]["2. Symbol"].description)
                    self.myFavoriteList.tmpStock.symbol = json!["InfoTable"]["Meta Data"]["2. Symbol"].description
                    self.myFavoriteList.tmpStock.date = json!["InfoTable"]["Meta Data"]["3. Last Refreshed"].description
                    //print(json!["InfoTable"]["Time Series (Daily)"][self.myFavoriteList.tmpStock.date])
                    self.myFavoriteList.tmpStock.volume = Double(json!["InfoTable"]["Time Series (Daily)"][self.myFavoriteList.tmpStock.date]["5. volume"].description)!
                    self.myFavoriteList.tmpStock.high = Double(json!["InfoTable"]["Time Series (Daily)"][self.myFavoriteList.tmpStock.date]["2. high"].description)!
                    self.myFavoriteList.tmpStock.low = Double(json!["InfoTable"]["Time Series (Daily)"][self.myFavoriteList.tmpStock.date]["3. low"].description)!
                    self.myFavoriteList.tmpStock.open = Double(json!["InfoTable"]["Time Series (Daily)"][self.myFavoriteList.tmpStock.date]["1. open"].description)!
                    self.myFavoriteList.tmpStock.close = Double(json!["InfoTable"]["Time Series (Daily)"][self.myFavoriteList.tmpStock.date]["4. close"].description)!
                    
                    //data = ["Stock Symbol \t ", "Last Price \t\t ", "Change \t\t ", "Timestamp \t ", "Open \t\t\t ", "Close \t\t\t ", "Day's Range \t ", "Volume \t\t "]
                    self.stockDetailsContent[0] = String(self.myFavoriteList.tmpStock.symbol)
                    self.stockDetailsContent[4] = String(self.myFavoriteList.tmpStock.open)
                    self.stockDetailsContent[5] = String(self.myFavoriteList.tmpStock.close)
                    self.stockDetailsContent[6] = String(self.myFavoriteList.tmpStock.low) + " - " + String(self.myFavoriteList.tmpStock.high)
                    self.stockDetailsContent[7] = String(self.myFavoriteList.tmpStock.volume)
                    self.stockDetailsTableView.reloadData()
                    SwiftSpinner.hide()
                }
                else {
                    SwiftSpinner.hide()
                    self.view.showToast("Failed to load data. Please try again later.", position: .bottom, popTime: 5, dismissOnTap: false)
                }
            }
            else {
                SwiftSpinner.hide()
                self.view.showToast("Failed to load data. Please try again later.", position: .bottom, popTime: 5, dismissOnTap: false)
            }
        }
    }
    
    private func getDataStockDetailAdv(targetSymbol inputSymbol_: String?) {
        SwiftSpinner.show("Loading data", animated: true)
        let url = "http://newphp2-env.fvkrppm399.us-west-1.elasticbeanstalk.com/service4.php?idx=quickSearch&inSymbol="+inputSymbol_!
        Alamofire.request(url).responseSwiftyJSON { response in
            let json = response.result.value //A JSON object
            let isSuccess = response.result.isSuccess
            if (isSuccess && (json != nil)) {
                //'msg' => 'Cannot Get Stock Information！'
                if(json!["InfoTable"]["Error Message"].description == "null") {
                    //print(json!["InfoTable"]["Meta Data"]["2. Symbol"].description)
                    self.myFavoriteList.tmpStock.symbol = json!["InfoTable"]["Meta Data"]["2. Symbol"].description
                    self.myFavoriteList.tmpStock.timeStamp = String(json!["InfoTableIntraday"]["Meta Data"]["3. Last Refreshed"].description)
                    self.myFavoriteList.tmpStock.lastPrice = Double(json!["InfoTableIntraday"]["Time Series (1min)"][self.myFavoriteList.tmpStock.timeStamp]["4. close"].description)!
                    
                    self.myFavoriteList.tmpStock.date = json!["InfoTable"]["Meta Data"]["3. Last Refreshed"].description
                    let index = self.myFavoriteList.tmpStock.date.index(self.myFavoriteList.tmpStock.date.startIndex, offsetBy: 10)
                    let mySubstring = self.myFavoriteList.tmpStock.date.prefix(upTo: index)
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
                        self.myFavoriteList.tmpStock.date = tmpDate[1]
                        self.myFavoriteList.tmpStock.preDate = tmpDate[2]
                        print("Date: \(self.myFavoriteList.tmpStock.date);   PreDate:\(self.myFavoriteList.tmpStock.preDate)")
                    }
                    else {
                        self.myFavoriteList.tmpStock.date = tmpDate[0]
                        self.myFavoriteList.tmpStock.preDate = tmpDate[1]
                        print("Date: \(self.myFavoriteList.tmpStock.date);   PreDate:\(self.myFavoriteList.tmpStock.preDate)")
                    }
                    self.myFavoriteList.tmpStock.volume = Double(json!["InfoTable"]["Time Series (Daily)"][self.myFavoriteList.tmpStock.date]["5. volume"].description)!
                    self.myFavoriteList.tmpStock.high = Double(json!["InfoTable"]["Time Series (Daily)"][self.myFavoriteList.tmpStock.date]["2. high"].description)!
                    self.myFavoriteList.tmpStock.low = Double(json!["InfoTable"]["Time Series (Daily)"][self.myFavoriteList.tmpStock.date]["3. low"].description)!
                    self.myFavoriteList.tmpStock.open = Double(json!["InfoTable"]["Time Series (Daily)"][self.myFavoriteList.tmpStock.date]["1. open"].description)!
                    self.myFavoriteList.tmpStock.close = Double(json!["InfoTable"]["Time Series (Daily)"][self.myFavoriteList.tmpStock.date]["4. close"].description)!
                    // Change:  compare date and timestamp to determinate which close will be used
                    self.myFavoriteList.tmpStock.preclose = Double(json!["InfoTable"]["Time Series (Daily)"][self.myFavoriteList.tmpStock.preDate]["4. close"].description)!
                    if !stockOpen {
                        self.myFavoriteList.tmpStock.change = self.myFavoriteList.tmpStock.lastPrice -  self.myFavoriteList.tmpStock.preclose
                        self.myFavoriteList.tmpStock.changeP = self.myFavoriteList.tmpStock.change/self.myFavoriteList.tmpStock.preclose
                    }
                    else {
                        self.myFavoriteList.tmpStock.change = self.myFavoriteList.tmpStock.lastPrice -  self.myFavoriteList.tmpStock.close
                        self.myFavoriteList.tmpStock.changeP = self.myFavoriteList.tmpStock.change/self.myFavoriteList.tmpStock.close
                    }
                    // ===Change:  compare date and timestamp to determinate which close will be used===
                    
                    
                    
                    //data = ["Stock Symbol \t ", "Last Price \t\t ", "Change \t\t ", "Timestamp \t ", "Open \t\t\t ", "Close \t\t\t ", "Day's Range \t ", "Volume \t\t "]
                    self.stockDetailsContent[0] = String(self.myFavoriteList.tmpStock.symbol)
                    self.stockDetailsContent[1] = String(self.myFavoriteList.tmpStock.lastPrice.R2D())
                    self.stockDetailsContent[2] = String(self.myFavoriteList.tmpStock.change.R2D()) + " (" + String((self.myFavoriteList.tmpStock.changeP*100).R2D()) + "%)"
                    self.stockDetailsContent[3] = String(self.myFavoriteList.tmpStock.timeStamp) + " EDT"
                    self.stockDetailsContent[4] = String(self.myFavoriteList.tmpStock.open.R2D())
                    self.stockDetailsContent[5] = String(self.myFavoriteList.tmpStock.close.R2D())
                    self.stockDetailsContent[6] = String(self.myFavoriteList.tmpStock.low.R2D()) + " - " + String(self.myFavoriteList.tmpStock.high.R2D())
                    let numberFormatter = NumberFormatter()
                    numberFormatter.numberStyle = NumberFormatter.Style.decimal
                    let formattedNumber = numberFormatter.string(from: NSNumber(value:self.myFavoriteList.tmpStock.volume.R2D()))
                    self.stockDetailsContent[7] = formattedNumber!
                    self.stockDetailsTableView.reloadData()
                    let when = DispatchTime.now() + 2 // change 2 to desired number of seconds
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        SwiftSpinner.hide()
                    }
                }
                else {
                    self.isError = true
                    self.favoriteListButton.isEnabled = false
                    self.fbButton.isEnabled = false
                    self.favoriteListButton.isEnabled = false
                    self.stockDetailsTableView.reloadData()
                    SwiftSpinner.hide()
                    self.view.showToast("Failed to load data. Please try again later.", position: .bottom, popTime: 5, dismissOnTap: false)
                }
            }
            else {
                SwiftSpinner.hide()
                self.view.showToast("Failed to load data. Please try again later.", position: .bottom, popTime: 5, dismissOnTap: false)
            }
        }
    }
    /*
    private func getSMA(targetSymbol inputSymbol_: String?, highchartContent: String)  {
        let url = "http://newphp2-env.fvkrppm399.us-west-1.elasticbeanstalk.com/service4.php?idx=SMA&inSymbol="+inputSymbol_!
        Alamofire.request(url).responseSwiftyJSON { response in
            let json = response.result.value //A JSON object
            let isSuccess = response.result.isSuccess
            if (isSuccess && (json != nil)) {
                //'msg' => 'Cannot Get Stock Information！'
                if(json!["msg"].description=="null") {
                    //print(json!["InfoTable"]["Meta Data"]["2. Symbol"].description)
                    var tmpSMA:Array<indicatorDataType> = Array<indicatorDataType>()
                    for (index, _) in json!["SMA"]["Technical Analysis: SMA"] {
                        var tmpElmnt:indicatorDataType = indicatorDataType()
                        //if(json!["SMA"]["Technical Analysis: SMA"][index].description != "null" && json!["SMA"]["Technical Analysis: SMA"][index]["SMA"].description != "null") {
                            tmpElmnt.date = index.description
                            tmpElmnt.value = json!["SMA"]["Technical Analysis: SMA"][index]["SMA"].description
                        //}
                        tmpSMA.append(tmpElmnt)
                    }
                    tmpSMA.sort{
                        $0.date < $1.date
                    }
                    let tmpSMA2ChartTmp:ArraySlice<indicatorDataType> = tmpSMA[tmpSMA.count-130..<tmpSMA.count]
                    let tmpSMA2Chart:Array<indicatorDataType> = [] + tmpSMA2ChartTmp
                    let highchartContent = self.IndicatorsContentGen_SMA(inpuutSymbol: inputSymbol_!,input: tmpSMA2Chart)
                    self.indictorsHighchartString = highchartContent
                    self.indicatorsWebView.loadHTMLString(self.IndicatorsHtmlGen(inputData: highchartContent), baseURL: nil)
                }
                else {
                    self.view.showToast("Failed to load SMA data. Please try again later.", position: .bottom, popTime: 5, dismissOnTap: false)
                }
            }
            else {
                self.view.showToast("Failed to load SMA data. Please try again later.", position: .bottom, popTime: 5, dismissOnTap: false)
            }
        }
    }
    */
    
    private func getHistoricalChartDetail(targetSymbol inputSymbol_: String?) {
        self.HistorWeb.isHidden = true
        let url = "http://newphp2-env.fvkrppm399.us-west-1.elasticbeanstalk.com/service4.php?idx=stocktInfo2&inSymbol="+inputSymbol_!
        Alamofire.request(url).responseSwiftyJSON { response in
            let json = response.result.value //A JSON object
            let isSuccess = response.result.isSuccess
            if (isSuccess && (json != nil)) {
                //print(json!["InfoTableHistorical"])
                for idx in 0...json!["InfoTableHistorical"].count {
                    var elemnt:HistoricalPriceElemnt = HistoricalPriceElemnt();
                    elemnt.price = json!["InfoTableHistorical"][idx]["price"].description
                    elemnt.timeStamp = json!["InfoTableHistorical"][idx]["timestamp"].description
                    if elemnt.price != "null" && elemnt.timeStamp != "null" {
                        self.myHistoricalChartData.append(elemnt)
                    }
                }
                //print(self.myHistoricalChartData)
                let HistorialSegContent = self.HistorialSegContentGen(inputsymbol: self.myFavoriteList.tmpStock.symbol, inputdata: self.myHistoricalChartData)
                //print(HistorialSegContent)
                self.HistoricalActivity.stopAnimating()
                self.HistorWeb.loadHTMLString(HistorialSegContent, baseURL: nil)
                self.HistorWeb.isHidden = false
            }
            else {
            }
        }
    }
    
    private func getDataNews(targetSymbol inputSymbol_: String?) {
        let url = "http://newphp2-env.fvkrppm399.us-west-1.elasticbeanstalk.com/service4.php?idx=News&inSymbol="+inputSymbol_!
        Alamofire.request(url).responseSwiftyJSON { response in
            let json = response.result.value //A JSON object
            let isSuccess = response.result.isSuccess
            if (isSuccess && (json != nil)) {
                for idx in 0...json!["News"].count {
                    var newsElmnt:News = News()
                    newsElmnt.title = json!["News"][idx]["Title"]["0"].description
                    newsElmnt.url = json!["News"][idx]["Link"]["0"].description
                    newsElmnt.author = json!["News"][idx]["Author"]["0"].description
                    newsElmnt.Date = json!["News"][idx]["Date"].description + "PDT"
                    if newsElmnt.title != "null" && newsElmnt.url != "null" && newsElmnt.author != "null" && newsElmnt.Date != "null" {
                        self.myNews.append(newsElmnt)
                    }
                }
                /*
                for idx in self.myNews.indices {
                    print(idx)
                    print(self.myNews[idx].title)
                    print(self.myNews[idx].url)
                    print(self.myNews[idx].author)
                    print(self.myNews[idx].Date)
                    print("=================")
                }
                 */
                //print(self.myNews)
                self.newsTableView.reloadData()
            }
            else {
            }
        }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detail2main" {
            let destinationVC = segue.destination as! ViewController
            destinationVC.myFavoriteList = self.myFavoriteList
            print("2to1")
            print(self.myFavoriteList.symbollist)
        }
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func R2D() -> Double {
        let divisor = 100.0
        return (self * divisor).rounded() / divisor
    }
    
}

