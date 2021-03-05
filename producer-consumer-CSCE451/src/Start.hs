{-# LANGUAGE RecordWildCards #-}

module Start(start) where

import Control.Concurrent
import Control.Monad
import System.IO.Unsafe(unsafePerformIO)

import Options (Options(..))
import SharedBuffer
import Synchronize (Sync, runSync)

producer
  :: (Char -> Buffer -> Sync InsertResult) -- Synchronized insert
  -> Buffer -- Shared buffer among all threads
  -> IO ()  -- Production
producer insert buffer = do
    item <- createItem
    result <- runSync $ insert item buffer
    case result of
      Inserted idx -> printModified Producer item idx >> producer insert buffer
      InsertDone -> return ()

consumer
  :: (Buffer -> Sync RemoveResult) -- Synchronized remove
  -> Buffer -- Shared buffer among all threads
  -> IO () -- Consumption
consumer remove buffer = do
    result <- runSync $ remove buffer
    case result of
      Removed item idx -> printModified Consumer item idx >> consumer remove buffer
      RemoveDone      -> return ()

start
  :: Options -- Command line arguments
  -> (Char -> Buffer -> Sync InsertResult) -- Synchronized insert function
  -> (Buffer -> Sync RemoveResult) -- Synchronized remove function
  -> IO () -- Program execution
start (Options {..}) insert remove = do
    buffer <- empty bufferLength numItems
    create numProducers (producer insert buffer)
    create numConsumers (consumer remove buffer)
    waitForThreads
  where
    create n io = replicateM_ n (forkThread io)

forkThread :: IO () -> IO ThreadId
forkThread io = do
    mvar         <- newEmptyMVar
    otherThreads <- takeMVar threads
    putMVar threads (mvar:otherThreads)
    forkFinally io (\_ -> putMVar mvar ())

threads :: MVar [MVar ()]
threads = unsafePerformIO (newMVar [])

waitForThreads :: IO ()
waitForThreads = do
    ts <- takeMVar threads
    case ts of
      [] -> return ()
      m:ms -> do
          putMVar threads ms
          takeMVar m
          waitForThreads
