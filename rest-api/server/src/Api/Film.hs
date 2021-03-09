module Api.Film where

import Data.Int

import Data.Text
import Servant
import qualified Squeal.PostgreSQL as SQL

import Data.Film (Film)
import DB.Film (getFilms, getFilmById)
import Schema (DB)

type GetFilms = QueryParam "title" Text :> Get '[JSON] [Film]
type GetFilm = Capture "film_id" Int32 :> Get '[JSON] (Maybe Film)

type FilmAPI = "films" :> (GetFilm :<|> GetFilms)

filmServer :: ServerT FilmAPI (SQL.PQ DB DB IO)
filmServer = getFilmById :<|> getFilms
