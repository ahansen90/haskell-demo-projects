{-# LANGUAGE RecordWildCards #-}

module Part1 (main) where

import Control.Concurrent
import Control.Exception
import Data.Monoid
import System.Exit

import Options.Applicative

import SharedBuffer(insertItem, removeItem)
import Synchronize
import Options
import Start

runWithSems :: Options -> IO ()
runWithSems args@(Options{..}) = do
    mutex <- openSem $ MutexSem 1
    empty <- openSem $ EmptySem bufferLength
    full  <- openSem $ FullSem  0
    let
      syncProducer item buffer = syncInsert $ syncMutex (insertItem item buffer)
      syncConsumer buffer = syncRemove $ syncMutex (removeItem buffer)
      syncInsert = sync (empty, full)
      syncRemove = sync (full, empty)
      syncMutex io = runSync $ sync mutex io
    start args syncProducer syncConsumer

main :: IO ()
main = do
    args@(Options b p c i) <- execParser opts
    finally (runWithSems args) closeSems
  where
    opts = info (options <**> helper)
        ( fullDesc
        <> progDesc "Producer/consumer using semaphores"
        <> header "PA2 - Part 1")
