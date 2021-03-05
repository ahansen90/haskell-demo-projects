{-# LANGUAGE GeneralizedNewtypeDeriving, FlexibleInstances #-}

module Synchronize
    ( Synchronize(wait, signal)
    , Sync(runSync)
    , Sem(..)
    , sync
    , openSem, closeSems
    , dump
    ) where

import Prelude hiding (read)
import System.IO
import Control.Monad
import Data.IORef

import System.Posix.Files
import System.Posix.Semaphore
import System.Posix.Types

class Synchronize s where
    wait   :: s -> IO ()
    signal :: s -> IO ()

instance Synchronize s => Synchronize (s,s) where
    wait (a,_) = wait a
    signal (_,b) = signal b

instance Synchronize Semaphore where
  wait   = semThreadWait
  signal = semPost

newtype Sync a = Sync {runSync :: (IO a)} deriving (Functor, Applicative, Monad)

data Sem
  = MutexSem Int
  | EmptySem Int
  | FullSem  Int
  | NextSem  Int

-- Synchronize an IO action with the given synchronization variable
sync :: (Synchronize s) => s -> IO a -> Sync a
sync s f = Sync $ do
    wait s
    result <- f
    signal s
    return result

semFlags :: OpenSemFlags
semFlags = OpenSemFlags {semCreate = True, semExclusive = False}

filemode :: FileMode
filemode = unionFileModes ownerReadMode ownerWriteMode

openSem :: Sem -> IO Semaphore
openSem (MutexSem n) = semOpen "asturtz_mutex" semFlags filemode n
openSem (EmptySem n) = semOpen "asturtz_empty" semFlags filemode n
openSem (FullSem  n) = semOpen "asturtz_full"  semFlags filemode n
openSem (NextSem  n) = semOpen "asturtz_next"  semFlags filemode n

closeSems :: IO ()
closeSems = do
    semUnlink "asturtz_mutex"
    semUnlink "asturtz_empty"
    semUnlink "asturtz_full"

-- For debugging purposes only
dump :: Show a => IORef a -> IO ()
dump field = readIORef field >>= (\items -> print items)
