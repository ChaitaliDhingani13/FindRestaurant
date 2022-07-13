//
//  WebService.swift
//  FindRestaurant
//
//  Created by Chaitali Patel on 04/07/22.
//
import Foundation
import UIKit


enum AppMode{
    case Development
    case Production
    case Staging
}

enum HttpMethod: String {
    case GET = "GET"
    case POST = "POST"
}

class WebService: NSObject{
    
    static let shared = WebService()
    
    private override init() {
        super.init()
    }
    
    var appmode : AppMode = .Development
    
    lazy var decoder: JSONDecoder = { return JSONDecoder() }()
    
    private func getBaseUrl() -> String {
        
        let BaseURL = APIHelper.baseUrl
        return BaseURL
    }
    
    
    func getDataFromWebService<T>(task: String, params: [String : String] = [:], httpMethod: HttpMethod , modType: T.Type, completion: @escaping ((T?, String?) -> Void)) where T: Decodable {
        
        
        let strURL = getBaseUrl() + task
        guard let url = URL(string: strURL) else{
            completion(nil, Constant.APIURLError)
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        urlRequest.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        
        if params.count > 0 {
            guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
                completion(nil, Constant.APIJsonError)
                return
            }
            urlRequest.httpBody = httpBody
        }
        
        
        URLSession.shared.dataTask(with: urlRequest) { (data, res, err) in
            guard let data = data else {
                completion(nil, Constant.APIParsingError)
                return
            }
            let decoder = JSONDecoder()
            guard let placesResponse = try? decoder.decode(modType.self, from: data) else {
                DispatchQueue.main.async {
                    completion(nil, Constant.APIParsingError)
                }
                return
            }
            
            DispatchQueue.main.async {
                
                completion(placesResponse, nil)
            }
            
        }.resume()
    }
    
}
