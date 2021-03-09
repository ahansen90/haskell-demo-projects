module DB.Film where

import Data.Int
import Control.Monad.IO.Class

import Data.Text (Text)
import Squeal.PostgreSQL (as, (!), NP(..), PGType(..), MonadPQ, (.==), (&), NullType(..))
import qualified Squeal.PostgreSQL as SQL

import Data.Film (Film)
import Schema (DB)

getFilmById :: (MonadPQ DB m, MonadIO m) => Int32 -> m (Maybe Film)
getFilmById id = SQL.runQueryParams filmByIdQuery (SQL.Only id) >>= SQL.firstRow
  where
    filmByIdQuery :: SQL.Query_ DB (SQL.Only Int32) Film
    filmByIdQuery = SQL.select_
      (#f ! #title :* #f ! #release_year `as` #releaseYear :* #f ! #length :* #f ! #rating)
      (SQL.from (SQL.table (#film `as` #f))
        & SQL.where_ (#f ! #film_id .== (SQL.param @1)))

getFilms :: (MonadPQ DB m, MonadIO m) => Maybe Text -> m [Film]
getFilms titleParam = do
    result <- case titleParam >>= SQL.varChar of
      Just title -> SQL.runQueryParams filmsByTitleQuery (SQL.Only title)
      Nothing -> SQL.runQuery filmsQuery
    SQL.getRows result
  where
    table = SQL.from . SQL.table $ (#film `as` #f)
    filmsQuery = SQL.select_
      (#f ! #title :* #f ! #release_year `as` #releaseYear :* #f ! #length :* #f ! #rating)
      table

    filmsByTitleQuery :: SQL.Query_ DB (SQL.Only (SQL.VarChar 255)) Film
    filmsByTitleQuery = SQL.select_
      (#f ! #title :* #f ! #release_year `as` #releaseYear :* #f ! #length :* #f ! #rating)
      (table & SQL.where_ (#f ! #title .== (SQL.param @1 @(SQL.NotNull ('PGvarchar 255)))))
