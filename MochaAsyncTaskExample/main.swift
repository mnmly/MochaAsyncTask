//
//  main.swift
//  MochaAsyncTaskExample
//
//  Created by Hiroaki Yamane on 3/24/17.
//  Copyright © 2017 Hiroaki Yamane. All rights reserved.
//

import Foundation


COScript.listen()
COScript.loadPlugins()

let jsPath = Bundle.main.path(forResource: "example", ofType: "js")
let baseURL = Bundle.main.bundleURL

do {
    let content = try String(contentsOfFile: jsPath!)
    let jstalk = COScript()
    jstalk.shouldPreprocess = true
    jstalk.execute(content, baseURL: baseURL)
}

RunLoop.main.run(until: Date(timeIntervalSinceNow: 15))
