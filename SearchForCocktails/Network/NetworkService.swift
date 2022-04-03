//
//  NetworkService.swift
//  SearchForCocktails
//
//  Created by Евгений Таракин on 01.04.2022.
//

import Foundation
import Alamofire

struct NetworkConstants {
    struct URLString {
        static let drinksList = "https://www.thecocktaildb.com/api/json/v1/1/filter.php?a=Non_Alcoholic"
    }
}

protocol FilmsListNetworkService {
    func getDrinksList(onRequestCompleted: @escaping ((DrinksResponseModel?, Error?) -> ()))
}


class NetworkService: FilmsListNetworkService {
    
    func getDrinksList(onRequestCompleted: @escaping ((DrinksResponseModel?, Error?) -> ())) {
        performGetRequest(urlString: NetworkConstants.URLString.drinksList, onRequestCompleted: onRequestCompleted)
    }
    
    private func performGetRequest<ResponseModel: Decodable>(urlString: String, method: HTTPMethod = .get, onRequestCompleted: @escaping ((ResponseModel?, Error?)->())) {
        AF.request(urlString,
                   method: method,
                   encoding: JSONEncoding.default
        ).response { (responseData) in
            guard responseData.error == nil,
                  let data = responseData.data
            else {
                onRequestCompleted(nil, responseData.error)
                return
            }
            do {
                let decodedValue: ResponseModel = try JSONDecoder().decode(ResponseModel.self, from: data)
                onRequestCompleted(decodedValue, nil)
            }
            catch (let error) {
                print("Response parsing error: \(error.localizedDescription)")
                onRequestCompleted(nil, error)
            }
        }
    }
    
}
