{-# LANGUAGE NamedFieldPuns, RecordWildCards, OverloadedStrings #-}

module SharedBuffer
    ( empty
    , createItem, insertItem, removeItem
    , printModified
    , Buffer(inserted, size, totalItems)
    , ThreadType(..)
    , InsertResult(..), RemoveResult(..)
    ) where

import Prelude
import Control.Concurrent
import Control.Monad
import Data.Maybe
import Data.IORef

import Control.Monad.Random (uniform)
import Data.Text (Text)
import qualified Data.Text as Text
import Data.Vector.Unboxed (Vector)
import qualified Data.Vector.Unboxed as Vec

-- No synchronization is performed with the mutable fields.
data Buffer = Buffer
    { items :: IORef (Vector Char)
    , inserted :: IORef Int
    , removed :: IORef Int
    , size :: Int
    , totalItems :: Int
    }

data InsertResult = Inserted Int | InsertDone
data RemoveResult = Removed Char Int | RemoveDone

data ThreadType = Producer | Consumer

instance Show ThreadType where
    show Producer = "p: "
    show Consumer = "c: "

empty :: Int -> Int -> IO Buffer
empty bufferLength numItems = do
    buffer <- newIORef Vec.empty
    ins    <- newIORef 0
    rem    <- newIORef 0
    return $ Buffer
      { items = buffer
      , inserted = ins
      , removed = rem
      , size = bufferLength
      , totalItems = numItems
      }

alphabet :: String
alphabet = ['A'..'Z'] ++ ['a'..'z']

createItem :: IO Char
createItem = uniform alphabet

insertItem :: Char -> Buffer -> IO InsertResult
insertItem item Buffer {..} = do
    buffer <- readIORef items
    count  <- readIORef inserted
    if count == totalItems
    then return InsertDone
    else do
      insert
      modifyIORef' inserted (+1)
      return $ Inserted (index buffer)
  where
    insert = modifyIORef' items $ append item
    index buffer = Vec.length buffer

removeItem :: Buffer -> IO RemoveResult
removeItem Buffer {..} = do
    buffer <- readIORef items
    count  <- readIORef removed
    if count == totalItems
    then return RemoveDone
    else do
      remove buffer
      modifyIORef' removed (+1)
      return $ Removed (removedItem buffer) (index buffer)
  where
    remove buffer = modifyIORef' items $ Vec.take (index buffer)
    removedItem   = Vec.last
    index buffer  = Vec.length buffer - 1

printModified :: ThreadType -> Char -> Int -> IO ()
printModified threadType char index = do
    thread <- showThread
    print $ Text.intercalate ", " [thread, item, bufferPos]
  where
    item          = "item: " <> Text.singleton char
    bufferPos     = "at "    <> Text.pack (show index)
    showThread    = myThreadId >>= format
    format thread = return $ Text.pack (show threadType) <> showId thread

showId :: ThreadId -> Text
showId thread = last . Text.words . Text.pack $ show thread

append :: Vec.Unbox a => a -> Vector a -> Vector a
append = flip Vec.snoc
