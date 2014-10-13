{-# LANGUAGE RecordWildCards #-}
module Foreign.JavaScript (
    -- * Synopsis
    -- | Communicate with a web browser and execute JavaScript code.

    -- * Server
    serve, Config(..), defaultConfig,
    Window, root,
    
    -- * JavaScript FFI
    FFI, ToJS(..), JSFunction, JSObject,
    ffi, runFunction, callFunction,
    HsEvent, exportHandler,
    debug,
    ) where

import Foreign.JavaScript.EventLoop
import Foreign.JavaScript.Marshal
import Foreign.JavaScript.Server
import Foreign.JavaScript.Types

{-----------------------------------------------------------------------------
    Server
------------------------------------------------------------------------------}
-- | Run a "Foreign.JavaScript" server.
serve
    :: Config               -- ^ Configuration options.
    -> (Window -> IO ())    -- ^ Initialization whenever a client connects.
    -> IO ()
serve config init = httpComm config (eventLoop init)

{-----------------------------------------------------------------------------
    JavaScript
------------------------------------------------------------------------------}
-- | Run a JavaScript function, but do not wait for a result.
runFunction :: Window -> JSFunction () -> IO ()
runFunction w f = runEval w (toCode f)

-- | Call a JavaScript function and wait for the result.
callFunction :: Window -> JSFunction a -> IO a
callFunction w f = do
    resultJS <- callEval w (toCode f)
    marshalResult f resultJS w
