//
//  Dependencies.swift
//  GithubSearch
//
//  Created by Majid Jabrayilov on 9/16/19.
//  Copyright © 2019 Majid Jabrayilov. All rights reserved.
//
import Foundation

// For more information check "How To Control The World" - Stephen Celis
// https://vimeo.com/291588126
struct Environment {
    var searchRepos = GithubService().searchPublisher
}

var Current = Environment()
