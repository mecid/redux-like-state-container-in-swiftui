//
//  Dependencies.swift
//  GithubSearch
//
//  Created by Majid Jabrayilov on 9/16/19.
//  Copyright © 2019 Majid Jabrayilov. All rights reserved.
//
import UIKit
import Foundation

struct Dependencies {
    var githubService: GithubService
}

let dependencies = Dependencies(githubService: GithubService())


extension UIColor {
    static var primary = UIColor(named: "primary")
    static var appBackground = UIColor(named: "background")
}
