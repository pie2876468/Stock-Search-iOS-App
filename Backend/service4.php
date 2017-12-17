<?php
//header('Content-Type: application/json; charset=UTF-8');
header('Content-Type: application/json;');
header('Access-Control-Allow-Origin: *');
//date_default_timezone_set('America/Los_Angeles');
//back up api-key Z7S2MC67HC8S44AS

if ($_SERVER['REQUEST_METHOD'] == "GET") {
    $tmp = $_GET['idx'];
    if(isset($_GET['idx']) && $_GET['idx']=="quickSearch") QuickSearch();
    if(isset($_GET['idx']) && $_GET['idx']=="stocktInfo0") stocktInfoSearch0();
    if(isset($_GET['idx']) && $_GET['idx']=="stocktInfo1") stocktInfoSearch1();
    if(isset($_GET['idx']) && $_GET['idx']=="stocktInfo2") stocktInfoSearch2();
    if(isset($_GET['idx']) && $_GET['idx']=="autocompleteInfo") autoInfoSearch();
    if(isset($_GET['idx']) && $tmp=="News") NewsSearch();
    if(isset($_GET['idx']) && ($tmp=="SMA" || $tmp=="EMA" || $tmp=="STOCH" || $tmp=="RSI" || $tmp=="ADX" || $tmp=="CCI" || $tmp=="BBANDS" || $tmp=="MACD"))
        IndicatorSearch($tmp);

    if(isset($_GET['idx']) && $_GET['idx']=="stocktInfo") stocktInfoSearch();
    /*
    if(isset($_GET["keyword"])){
        $result  = file_get_contents('http://dev.markitondemand.com/MODApis/Api/v2/Lookup/json?input='.$_GET["keyword"]);
        echo($result);
    }
    */
} else if ($_SERVER['REQUEST_METHOD'] == "POST") {

}
function QuickSearch() {
    if (!isset($_GET['inSymbol']) || empty($_GET['inSymbol'])) {
        echo json_encode(array('msg' => 'Invalid Symbol'));
        return;
    }
    $result = array();
    $_symbol = $_GET['inSymbol'];
    $_url = "http://www.alphavantage.co/query?function=TIME_SERIES_DAILY".
    "&symbol=".$_symbol."&apikey=6VW1FDDAWV38YQ8A";
    //InfoDialy
    $InfoTable = json_decode(file_get_contents($_url));
    $result['InfoTable'] = $InfoTable;
    //InfoIntraday
    $_url = "http://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&interval=1min".
    "&symbol=".$_symbol."&apikey=6VW1FDDAWV38YQ8A";
    $InfoTableIntraday = json_decode(file_get_contents($_url));
    $result['InfoTableIntraday'] = $InfoTableIntraday;
    //indicator
    echo isset($result) ? json_encode($result) : json_encode(array('msg' => 'Cannot Get Stock Information！'));
}

function NewsSearch() {
    if (!isset($_GET['inSymbol']) || empty($_GET['inSymbol'])) {
        echo json_encode(array('msg' => 'Invalid Symbol'));
        return;
    }
    $result = array();
    $_symbol = $_GET['inSymbol'];
    $_urlNews = "http://seekingalpha.com/api/sa/combined/".$_symbol.".xml";
    $xml=simplexml_load_file($_urlNews);
    //$xml2=new SimpleXMLElement($xml);
    $news = $xml->channel->item;
    $newsOutput = array();
    for ($i = 1; $i <= 100; $i++) {
      if(substr($xml->channel->item[$i]->link, 0, 33)=="https://seekingalpha.com/article/") {
        $saFields = $xml->channel->item[$i]->children('sa', true);
        //array_push($newsOutput,$saFields);
        array_push($newsOutput,array(
            'Title' => $xml->channel->item[$i]->title,
            'Link' => $xml->channel->item[$i]->link,
            'Author' => $saFields->author_name,
            'Date' => substr($xml->channel->item[$i]->pubDate,0,strlen($xml->channel->item[$i]->pubDate)-5)
        ));
      }
    }
    $result['News'] = $newsOutput;
    echo isset($result) ? json_encode($result) : json_encode(array('msg' => 'Cannot Get Stock Information！'));
}

function IndicatorSearch($indicator) {
    if (!isset($_GET['inSymbol']) || empty($_GET['inSymbol'])) {
        echo json_encode(array('msg' => 'Invalid Symbol'));
        return;
    }
    $result = array();
    $_TIME_SERIES = "TIME_SERIES_DAILY";
    $_symbol = $_GET['inSymbol'];
    $_url = "http://www.alphavantage.co/query?"."function=".$indicator."&symbol=".
        $_symbol."&interval=daily&time_period=10&series_type=open&apikey=Z7S2MC67HC8S44AS";
    $InfoTable = json_decode(file_get_contents($_url));
    $result[$indicator] = $InfoTable;
    echo isset($result) ? json_encode($result) : json_encode(array('msg' => 'Cannot Get '.$indicator.' Information！'));
}

function autoInfoSearch() {
    if (!isset($_GET['inSymbol']) || empty($_GET['inSymbol'])) {
        echo json_encode(array('msg' => 'Invalid Symbol'));
        return;
    }
    $_TIME_SERIES = "TIME_SERIES_DAILY";
    $_symbol = $_GET['inSymbol'];
    $_url = "http://dev.markitondemand.com/MODApis/Api/v2/Lookup/json?input=".$_symbol;
    //$InfoTable = json_decode(file_get_contents($_url));
    //$result = array('ss' => $InfoTable);
    //echo isset($result) ? json_encode($result) : json_encode(array('msg' => 'Cannot Get '.$indicator.' Information！'));
    $result = file_get_contents($_url);
    echo($result);
}

function stocktInfoSearch0() {
    if (!isset($_GET['inSymbol']) || empty($_GET['inSymbol'])) {
        echo json_encode(array('msg' => 'Invalid Symbol'));
        return;
    }
    $result = array();
    $_TIME_SERIES = "TIME_SERIES_DAILY";
    $_symbol = $_GET['inSymbol'];
    $_url = "http://www.alphavantage.co/query?function=TIME_SERIES_DAILY".
    "&symbol=".$_symbol."&apikey=6VW1FDDAWV38YQ8A";
    $InfoTable = json_decode(file_get_contents($_url));
    $result['InfoTable'] = $InfoTable;
    echo isset($result) ? json_encode($result) : json_encode(array('msg' => 'Cannot Get Stock Information！'));
}

function stocktInfoSearch1() {
    if (!isset($_GET['inSymbol']) || empty($_GET['inSymbol'])) {
        echo json_encode(array('msg' => 'Invalid Symbol'));
        return;
    }
    $result = array();
    $_symbol = $_GET['inSymbol'];
    //InfoIntraday
    $_url = "http://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&interval=1min".
    "&symbol=".$_symbol."&apikey=6VW1FDDAWV38YQ8A";
    $InfoTableIntraday = json_decode(file_get_contents($_url));
    $result['InfoTableIntraday'] = $InfoTableIntraday;
    echo isset($result) ? json_encode($result) : json_encode(array('msg' => 'Cannot Get Stock Information！'));
}

function stocktInfoSearch2() {
    if (!isset($_GET['inSymbol']) || empty($_GET['inSymbol'])) {
        echo json_encode(array('msg' => 'Invalid Symbol'));
        return;
    }
    $result = array();
    $_symbol = $_GET['inSymbol'];
    //$InfoTableHistorical
    $_url = "http://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED".
    "&symbol=".$_symbol."&outputsize=full&apikey=6VW1FDDAWV38YQ8A";
    $InfoTableHistoricalJson = json_decode(file_get_contents($_url));

    $InfoTableH= array();
    $_i = 0;
    foreach ($InfoTableHistoricalJson->{'Time Series (Daily)'} as $key => $value) {
      $a = strptime($key, '%Y-%m-%d');
      $timestamp = mktime(0, 0, 0, $a['tm_mon']+1, $a['tm_mday'], $a['tm_year']+1900)*1000;
      array_push($InfoTableH,array(
          'timestamp' => $timestamp,
          'price' => $value->{'4. close'}
      ));
    }
    $result['InfoTableHistorical'] = $InfoTableH;
    echo isset($result) ? json_encode($result) : json_encode(array('msg' => 'Cannot Get Stock Information！'));
}

function stocktInfoSearch() {
    if (!isset($_GET['inSymbol']) || empty($_GET['inSymbol'])) {
        echo json_encode(array('msg' => 'Invalid Symbol'));
        return;
    }
    $result = array();
    $_TIME_SERIES = "TIME_SERIES_DAILY";
    $_symbol = $_GET['inSymbol'];
    $_url = "http://www.alphavantage.co/query?function=TIME_SERIES_DAILY".
    "&symbol=".$_symbol."&apikey=6VW1FDDAWV38YQ8A";
    //InfoDialy
    $InfoTable = json_decode(file_get_contents($_url));
    $result['InfoTable'] = $InfoTable;
    //InfoIntraday
///*
    $_url = "http://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&interval=1min".
    "&symbol=".$_symbol."&apikey=6VW1FDDAWV38YQ8A";
    $InfoTableIntraday = json_decode(file_get_contents($_url));
    $result['InfoTableIntraday'] = $InfoTableIntraday;
//*/
    //$InfoTableHistorical
    $_url = "http://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED".
    "&symbol=".$_symbol."&outputsize=full&apikey=6VW1FDDAWV38YQ8A";
    $InfoTableHistorical = json_decode(file_get_contents($_url));
    $result['InfoTableHistorical'] = $InfoTableHistorical;
    //indicator
    $indicatorarray = array("SMA", "EMA", "STOCH", "RSI", "ADX", "CCI", "BBANDS", "MACD");
    for($_i =0; $_i<4; $_i++) {
        $_url = "http://www.alphavantage.co/query?"."function=".$indicatorarray[$_i]."&symbol=".
            $_symbol."&interval=daily&time_period=10&series_type=open&apikey=6VW1FDDAWV38YQ8A";
        $IndicatorInfo = json_decode(file_get_contents($_url));
        $result[$indicatorarray[$_i]] = $IndicatorInfo;
    }
    for($_i =4; $_i<8; $_i++) {
        $_url = "http://www.alphavantage.co/query?"."function=".$indicatorarray[$_i]."&symbol=".
            $_symbol."&interval=daily&time_period=10&series_type=open&apikey=SO4BW560CSMQV20V";
        $IndicatorInfo = json_decode(file_get_contents($_url));
        $result[$indicatorarray[$_i]] = $IndicatorInfo;
    }
    //Indicator

    //news
    $_urlNews = "http://seekingalpha.com/api/sa/combined/".$_symbol.".xml";
    $xml=simplexml_load_file($_urlNews);
    //$xml2=new SimpleXMLElement($xml);
    $news = $xml->channel->item;
    $_i = 0;
    $newsOutput = array();
    for ($i = 1; $i <= 100; $i++) {
      if($_i<5 && substr($xml->channel->item[$i]->link, 0, 33)=="https://seekingalpha.com/article/") {
        $saFields = $xml->channel->item[$i]->children('sa', true);
        //array_push($newsOutput,$saFields);
        array_push($newsOutput,array(
            'Title' => $xml->channel->item[$i]->title,
            'Link' => $xml->channel->item[$i]->link,
            'Author' => $saFields->author_name,
            'Date' => substr($xml->channel->item[$i]->pubDate,0,strlen($xml->channel->item[$i]->pubDate)-5)
            //'Date' => date("D, j M Y H:i:s T",strtotime($xml->channel->item[$i]->pubDate))
        ));
        $_i++;
      }
      if($_i==5) {
        break;
      }
    }
    $result['News'] = $newsOutput;
    //news
    echo isset($result) ? json_encode($result) : json_encode(array('msg' => 'Cannot Get Stock Information！'));
}

?>
