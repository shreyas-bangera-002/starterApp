//
//  Api.swift
//  StarterApp
//
//  Created by Shreyas Bangera on 12/07/19.
//  Copyright © 2019 Shreyas Bangera. All rights reserved.
//

import Foundation
import ws
import Arrow
import then
import CryptoSwift
import Keys

protocol ModelType: ArrowParsable {
    init()
}

enum NetworkError: Error {
    case parse
}

protocol ApiType {
    var endpoint: String { get }
}

enum MethodType {
    case get, post
}

struct Api {
    
    static func service<T: ModelType>(_ api: ApiType, method: MethodType = .get, params: Params = Params()) -> Promise<[T]> {
        let webService = WS("https://gateway.marvel.com")
//        webService.logLevels = .debug
        return Promise { resolve, reject in
            switch method {
            case .get:
                webService.get(api.endpoint, params: parameters(params)).then { (json: JSON) in
                    guard let jsonData = json["data"]?["results"]?.collection else {
                        reject(NetworkError.parse)
                        return
                    }
                    resolve(jsonData.compactMap { data in
                        var model = T.init()
                        model.deserialize(data)
                        return model
                    })
                    }.onError { (error) in
                        reject(error)
                }
            case .post:
                return reject(NetworkError.parse)
            }
        }
    }
    
    private static func parameters(_ params: Params) -> Params {
        let ts = Date().timeIntervalSince1970.description
        let keys = StarterAppKeys()
        let (apiKey, privateKey)  = (keys.marvelApiKey, keys.marvelPrivateKey)
        var parameters: Params = [
            "ts": ts,
            "apikey": apiKey,
            "hash": "\(ts)\(privateKey)\(apiKey)".md5()
        ]
        parameters += params
        return parameters
    }
}
