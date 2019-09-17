//
//  Dependencies.swift
//  GithubSearch
//
//  Created by Majid Jabrayilov on 9/16/19.
//  Copyright © 2019 Majid Jabrayilov. All rights reserved.
//

import Foundation

struct Dependencies {
    var githubService: GithubService
}

let dependencies = Dependencies(githubService: GithubService())
