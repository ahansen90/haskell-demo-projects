module Data.Film where

import Control.Monad.Error.Class (throwError)
import Control.Monad.State.Class (get)
import Data.Int

import qualified GHC.Generics as GHC
import qualified Generics.SOP as SOP

import Data.Aeson as Aeson (ToJSON(..), Value(..), (.=), object)
import Data.Text (pack)
import qualified Squeal.PostgreSQL as SQL

import Schema (PGmpaa_rating)

data Rating = G | PG | PG13 | R | NC17
  deriving stock (Show, GHC.Generic)
  deriving anyclass (SOP.Generic, SOP.HasDatatypeInfo)

instance SQL.IsPG Rating where
  type PG Rating = PGmpaa_rating

instance SQL.FromPG Rating where
  fromPG = do
    pgVal <- get
    case pgVal of
      "G" -> return G
      "PG" -> return PG
      "PG-13" -> return PG13
      "R" -> return R
      "NC-17" -> return NC17
      _ -> throwError "Can't Decode Rating"

data Film = Film
  { title :: SQL.VarChar 255
  , releaseYear :: Maybe Int32
  , length :: Maybe Int16
  , rating :: Maybe Rating
  -- , actors :: [Actor]
  }
  deriving stock (Show, GHC.Generic)
  deriving anyclass (SOP.Generic, SOP.HasDatatypeInfo)

instance ToJSON Film where
  toJSON (Film {..}) = object
    [ "title" .= SQL.getVarChar title
    , "releaseYear" .= releaseYear
    , "length" .= length
    , "rating" .= fmap (Aeson.String . pack . show) rating
    ]
