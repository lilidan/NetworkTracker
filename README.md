# NetworkTracker

An iOS library for network tracking.It can be used to evaluate performance or capture packets.

Supports HTTP/WebView/TCP.

![](/assets/Group.png)

### Dependency

[Fishhook](https://github.com/facebook/fishhook)

[AAChartKit](https://github.com/AAChartModel/AAChartKit)(Used for sample project)

### Compatibility

|iOS SDK|NSURLConnetion|NSURLSession|UIWebView|WKWebView|CocoaAyncSocket
|-| - | -| - | -| - |
|8.4| YES | YES  | via TCP | via TCP | YES |
|9.3| YES | YES | YES| YES|YES|
|10.3| YES | YES| YES| YES|YES|
|11.3| YES |YES| YES| YES|YES|

# performance

### HTTP

![](/assets/urlsession.png)

NSURLSession library has NSURLSessionTaskMetrics API for those higher than iOS 10.0.
So we can evaluate HTTP network performance by ```domainLookupTime``` or ```secureConnectionTime```.

For NSURLConnetion or NSURLSession lower than iOS 10.0, we can only use BSD Socket APIs to collect part of data.

### WebView

![](/assets/webview.png)

Either UIWebView or WKWebView implements ```Performance.timing``` API above iOS 9.
For those lower than iOS 10.0, we also use BSD Socket APIs to collect part of data.


# Installation

Drag and use.
