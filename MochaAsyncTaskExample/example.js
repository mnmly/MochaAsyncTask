@import "Debug/MochaJSDelegate.js"

COScript.currentCOScript().setShouldKeepAround_(true)

function loadFramework(pluginRoot, pluginName, className) {
    className = className ? `${pluginName}.${className}` : pluginName
    if ( NSClassFromString( className ) == null ) {
        let mocha = Mocha.sharedRuntime()
        return mocha.loadFrameworkWithName_inDirectory( pluginName, pluginRoot )
    } else {
        return true
    }
}

let result = loadFramework( "./", "MochaAsyncTask", "AsyncTask" )
let AsyncTask = NSClassFromString( "MochaAsyncTask.AsyncTask" )


let task = AsyncTask.alloc().init()
let delegate = new MochaJSDelegate()

//delegate.setHandlerForSelector("onError:", (data)=> {
//    log(data)
//})
//

delegate.setHandlerForSelector("onData:", (data)=> {
    log(data)
})

delegate.setHandlerForSelector("onEnd", (data)=> {
    log("ENDED")
})

task.setDelegate( delegate.getClassInstance() )
task.execWithLaunchPath_arguments("/usr/bin/curl", ["https://google.com"])
