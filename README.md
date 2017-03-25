
# AsyncTask for CocoaScript

A simple wrapper to allow CocoaScript to execute `NSTask` (`Process`) asynchronously.

## API

### execWithLaunchPath_arguments(launchPath: String, Arguments:[String])

Same arguments as [`Process`](https://developer.apple.com/reference/foundation/process)

### onData(data: String)
[*Delegate*] Executed when command receives data

### onEnd
[*Delegate*] Executed when command ends


## Usage
```javascript
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
if ( result == 0 ) log( "Failed to load framework..." )

let AsyncTask = NSClassFromString( "MochaAsyncTask.AsyncTask" )

let task = AsyncTask.alloc().init()
let delegate = new MochaJSDelegate()

delegate.setHandlerForSelector("onData:", (data)=> {
    log(data)
})

delegate.setHandlerForSelector("onEnd", (data)=> {
    log("ENDED")
})

task.setDelegate( delegate.getClassInstance() )
task.execWithLaunchPath_arguments("/usr/bin/curl", ["https://google.com"])
```

### Development

Make sure you pull its submodules.

```
$ git submodule update --init
```
