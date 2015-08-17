//
//  NetworkOperation.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 6/16/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import Foundation

public typealias JSON = Dictionary<String, AnyObject>
public typealias JsonBlock = ( (json:JSON) -> Void )
public typealias ErrorBlock = ( (error:ErrorType) -> Void )

public enum FetchError : ErrorType
{
  case HTTPError(Int)
  case JSONError(NSError)
  case None
}



// Fetches JSON async. 
public protocol JSONFetcher
{
  func fetchJSON(success:JsonBlock, failure:ErrorBlock)
}

public class NetworkOperation : JSONFetcher
{
  
  private let urlStr:String
  private var params:[String:String] = [:]
  
  public var fetchError:FetchError = FetchError.None
  
  public func addParam(key:String, value:String)
  {
    params[key] = value
  }
  
  public init(urlStr:String)
  {
    self.urlStr = urlStr
  }
  
  public func fetchJSON(success:JsonBlock, failure:ErrorBlock)
  {
    let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
    let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
    var URL = NSURL(string: self.urlStr)
    URL = NSURLByAppendingQueryParameters(URL!)
    
    print("\(URL)")
    
    let request = NSMutableURLRequest(URL: URL!)
    
    let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
      
      if let unwrapError = error
      {
        print(unwrapError.localizedDescription)
      }
      
      if let unwrapResponse = response as? NSHTTPURLResponse
      {
        if unwrapResponse.statusCode != 200
        {
          self.fetchError = FetchError.HTTPError(unwrapResponse.statusCode)
        }
        else if let unwrapData = data
        {
          do
          {
            if let jsonObject = try NSJSONSerialization.JSONObjectWithData(unwrapData, options: NSJSONReadingOptions.AllowFragments) as? Dictionary<String, AnyObject>
            {
              success(json: jsonObject)
            }
          }
          catch let jsonError as NSError
          {
            failure(error: FetchError.JSONError(jsonError))
          }
          catch
          {
            failure(error: FetchError.None)
          }
        }
      }
    }
    
    task.resume()
  }
  
  private func stringFromQueryParameters() -> String
  {
    var parts:[String] = []
    
    for (name, value) in self.params
    {
      let part = NSString(format: "%@=%@",
        name.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!,
        value.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
      parts.append(part as String)
    }
    return "&".join(parts)
  }
  
  private func NSURLByAppendingQueryParameters(url:NSURL) -> NSURL
  {
    let URLString : NSString = NSString(format: "%@?%@", url.absoluteString, self.stringFromQueryParameters())
    return NSURL(string: URLString as String)!
  }

  
}