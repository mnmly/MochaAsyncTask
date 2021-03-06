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
    func onError(_ data: String) -> Void
    func onEnd() -> Void
}

@objc public class AsyncTask: NSObject {
    
    @objc public var delegate: AsyncTaskProtocol?
    
    @objc public func exec(launchPath: String, arguments: [String]?) {
        
        let task = Process()
        task.launchPath = launchPath
        task.arguments = arguments
        
        let pipe = Pipe()
        let pipeError = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipeError
        
        let outHandle = pipe.fileHandleForReading
        outHandle.waitForDataInBackgroundAndNotify()
        
        let outErrorHandle = pipeError.fileHandleForReading
        outErrorHandle.waitForDataInBackgroundAndNotify()
        
        var progressObserver : NSObjectProtocol!
        progressObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.NSFileHandleDataAvailable,
            object: outHandle, queue: nil) { notification -> Void in
            let data = outHandle.availableData
            if data.count > 0 {
                if let str = String(data: data, encoding: String.Encoding.utf8) {
                    if (self.delegate as? NSObject)?.responds(to: #selector(AsyncTaskProtocol.onData(_:))) == true {
                        self.delegate?.onData(str)
                    }
                }
                outHandle.waitForDataInBackgroundAndNotify()
            } else {
                NotificationCenter.default.removeObserver(progressObserver)
            }
        }
        
        var progressErrorObserver : NSObjectProtocol!
        progressErrorObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.NSFileHandleDataAvailable,
            object: outErrorHandle, queue: nil) { notification -> Void in
            let data = outErrorHandle.availableData
            if data.count > 0 {
                if let str = String(data: data, encoding: String.Encoding.utf8) {
                    if (self.delegate as? NSObject)?.responds(to: #selector(AsyncTaskProtocol.onError(_:))) == true {
                        self.delegate?.onError(str)
                    }
                }
                outErrorHandle.waitForDataInBackgroundAndNotify()
            } else {
                NotificationCenter.default.removeObserver(progressErrorObserver)
            }
        }
        
        var terminationObserver : NSObjectProtocol!
        terminationObserver = NotificationCenter.default.addObserver(
            forName: Process.didTerminateNotification,
            object: task, queue: nil)
        {
            notification -> Void in
            NotificationCenter.default.removeObserver(terminationObserver)
            if (self.delegate as? NSObject)?.responds(to: #selector(AsyncTaskProtocol.onEnd)) == true {
                self.delegate?.onEnd()
            }
        }
        
        task.launch()
    }
}
