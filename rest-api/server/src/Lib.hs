module Lib
    ( startApp
    ) where

import Control.Monad.IO.Class (liftIO)
import Data.String

import Network.Wai.Logger (withStdoutLogger)
import Network.Wai.Handler.Warp (runSettings, setPort, setLogger, defaultSettings)
import Servant
import qualified Squeal.PostgreSQL as SQL

import Api.Film (FilmAPI, filmServer)
import Schema (DB)

type PoolDB = SQL.Pool (SQL.K SQL.Connection DB)

api :: Proxy FilmAPI
api = Proxy

sqlErr :: SQL.SquealException -> ServerError
sqlErr err = err500 { errBody = fromString (show err) }

mkHandler :: PoolDB -> SQL.PQ DB DB IO a -> Handler a
mkHandler pool session = do
    result <- liftIO . SQL.usingConnectionPool pool $
      SQL.trySqueal (SQL.transactionally_ session)
    case result of
      Left err -> throwError (sqlErr err)
      Right res -> return res

serverT :: ServerT FilmAPI (SQL.PQ DB DB IO)
serverT = filmServer

server :: PoolDB -> Server FilmAPI
server pool = hoistServer api (mkHandler pool) serverT

app :: PoolDB -> Application
app = serve api . server

startApp :: IO ()
startApp = do
    withStdoutLogger $ \logger -> do
      let
        port = 1234
        settings = setPort port $ setLogger logger defaultSettings
        numStripes = 1
        maxConnsPerStripe = 1
        unusedConnTimeout = 1
      putStr "Creating connection pool... "
      pool <- SQL.createConnectionPool "postgresql://postgres:password@db:5432/dvdrental" numStripes unusedConnTimeout maxConnsPerStripe
      putStrLn "Done."
      putStrLn $ "Running Servant server on port " ++ show port
      runSettings settings (app pool)
      SQL.destroyConnectionPool pool
