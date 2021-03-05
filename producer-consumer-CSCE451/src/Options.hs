module Options
    ( Options(..)
    , options
    ) where

import Options.Applicative
import Data.Monoid((<>))

data Options = Options
    { bufferLength :: Int
    , numProducers :: Int
    , numConsumers :: Int
    , numItems     :: Int
    }

options :: Parser Options
options = Options <$> buffer <*> producers <*> consumers <*> items

buffer :: Parser Int
buffer = option auto
    $  long "buffer-size"
    <> short 'b'
    <> value 1000
    <> help "Buffer length in bytes"

producers :: Parser Int
producers = option auto
    $  long "producers"
    <> short 'p'
    <> value 10
    <> help "Number of producer threads"

consumers :: Parser Int
consumers = option auto
    $  long "consumers"
    <> short 'c'
    <> value 10
    <> help "Number of consumer threads"

items :: Parser Int
items = option auto
    $  long "items"
    <> short 'i'
    <> value 10
    <> help "Number of items to insert"
