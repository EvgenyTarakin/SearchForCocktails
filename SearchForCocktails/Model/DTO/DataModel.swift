//
//  DataModel.swift
//  SearchForCocktails
//
//  Created by Евгений Таракин on 01.04.2022.
//

import Foundation

struct DrinksResponseModel: Codable {
    let drinks: [CocktailResponseModel]?
}

struct CocktailResponseModel: Codable {
    let strDrink: String?
}
