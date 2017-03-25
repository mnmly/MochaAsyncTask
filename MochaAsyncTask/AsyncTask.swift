//
//  AsyncTask.swift
//  MochaAsyncTask
//
//  Created by Hiroaki Yamane on 3/24/17.
//  Copyright © 2017 Hiroaki Yamane. All rights reserved.
//

import Foundation

@objc public protocol AsyncTaskProtocol {
    func onData(_ data: String) -> Void
    func onEnd() -> Void
}

@objc public class AsyncTask: NSObject {
    
    @objc public var delegate: AsyncTaskProtocol?
    
    public func exec(launchPath: String, arguments: [String]?) {
        
        let task = Process()
        task.launchPath = launchPath
        task.arguments = arguments
        
        let pipe = Pipe()
        task.standardOutput = pipe
        let outHandle = pipe.fileHandleForReading
        outHandle.waitForDataInBackgroundAndNotify()
        
        var progressObserver : NSObjectProtocol!
        progressObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.NSFileHandleDataAvailable,
            object: outHandle, queue: nil) { notification -> Void in
            let data = outHandle.availableData
            
            if data.count > 0 {
                if let str = String(data: data, encoding: String.Encoding.utf8) {
                    if (self.delegate as? NSObject)?.responds(to: Selector("onData:")) == true {
                        self.delegate?.onData(str)
                    }
                }
                outHandle.waitForDataInBackgroundAndNotify()
            } else {
                NotificationCenter.default.removeObserver(progressObserver)
            }
        }
        
        var terminationObserver : NSObjectProtocol!
        terminationObserver = NotificationCenter.default.addObserver(
            forName: Process.didTerminateNotification,
            object: task, queue: nil)
        {
            notification -> Void in
            NotificationCenter.default.removeObserver(terminationObserver)
            if (self.delegate as? NSObject)?.responds(to: Selector("onEnd")) == true {
                self.delegate?.onEnd()
            }
        }
        
        task.launch()
    }
}
