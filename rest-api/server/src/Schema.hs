-- | This code was originally created by squealgen. Edit if you know how it got made and are willing to own it now.
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE GADTs #-}
{-# OPTIONS_GHC -fno-warn-unticked-promoted-constructors #-}

module Schema where
import Squeal.PostgreSQL
import GHC.TypeLits(Symbol)

type PGname = UnsafePGType "name"
type PGregclass = UnsafePGType "regclass"
type PGltree = UnsafePGType "ltree"
type PGcidr = UnsafePGType "cidr"
type PGltxtquery = UnsafePGType "ltxtquery"
type PGlquery = UnsafePGType "lquery"

type DB = '["public" ::: Schema]

type Schema = Join Tables (Join Views (Join Enums (Join Functions (Join Composites Domains))))
-- enums
type PGmpaa_rating = 'PGenum
  '["G", "PG", "PG-13", "R", "NC-17"]
-- decls
type Enums =
  ('["mpaa_rating" ::: 'Typedef PGmpaa_rating] :: [(Symbol,SchemumType)])

type Composites =
  ('[] :: [(Symbol,SchemumType)])

-- schema
type Tables = ('[
   "actor" ::: 'Table ActorTable
  ,"address" ::: 'Table AddressTable
  ,"category" ::: 'Table CategoryTable
  ,"city" ::: 'Table CityTable
  ,"country" ::: 'Table CountryTable
  ,"customer" ::: 'Table CustomerTable
  ,"film" ::: 'Table FilmTable
  ,"film_actor" ::: 'Table FilmActorTable
  ,"film_category" ::: 'Table FilmCategoryTable
  ,"inventory" ::: 'Table InventoryTable
  ,"language" ::: 'Table LanguageTable
  ,"payment" ::: 'Table PaymentTable
  ,"rental" ::: 'Table RentalTable
  ,"staff" ::: 'Table StaffTable
  ,"store" ::: 'Table StoreTable]  :: [(Symbol,SchemumType)])

-- defs
type ActorColumns = '["actor_id" ::: 'Def :=> 'NotNull PGint4
  ,"first_name" ::: 'NoDef :=> 'NotNull (PGvarchar 45)
  ,"last_name" ::: 'NoDef :=> 'NotNull (PGvarchar 45)
  ,"last_update" ::: 'Def :=> 'NotNull PGtimestamp]
type ActorConstraints = '["actor_pkey" ::: 'PrimaryKey '["actor_id"]]
type ActorTable = ActorConstraints :=> ActorColumns

type AddressColumns = '["address_id" ::: 'Def :=> 'NotNull PGint4
  ,"address" ::: 'NoDef :=> 'NotNull (PGvarchar 50)
  ,"address2" ::: 'NoDef :=> 'Null (PGvarchar 50)
  ,"district" ::: 'NoDef :=> 'NotNull (PGvarchar 20)
  ,"city_id" ::: 'NoDef :=> 'NotNull PGint2
  ,"postal_code" ::: 'NoDef :=> 'Null (PGvarchar 10)
  ,"phone" ::: 'NoDef :=> 'NotNull (PGvarchar 20)
  ,"last_update" ::: 'Def :=> 'NotNull PGtimestamp]
type AddressConstraints = '["address_pkey" ::: 'PrimaryKey '["address_id"]
  ,"fk_address_city" ::: 'ForeignKey '["city_id"] "public" "city" '["address_id"]]
type AddressTable = AddressConstraints :=> AddressColumns

type CategoryColumns = '["category_id" ::: 'Def :=> 'NotNull PGint4
  ,"name" ::: 'NoDef :=> 'NotNull (PGvarchar 25)
  ,"last_update" ::: 'Def :=> 'NotNull PGtimestamp]
type CategoryConstraints = '["category_pkey" ::: 'PrimaryKey '["category_id"]]
type CategoryTable = CategoryConstraints :=> CategoryColumns

type CityColumns = '["city_id" ::: 'Def :=> 'NotNull PGint4
  ,"city" ::: 'NoDef :=> 'NotNull (PGvarchar 50)
  ,"country_id" ::: 'NoDef :=> 'NotNull PGint2
  ,"last_update" ::: 'Def :=> 'NotNull PGtimestamp]
type CityConstraints = '["city_pkey" ::: 'PrimaryKey '["city_id"]
  ,"fk_city" ::: 'ForeignKey '["country_id"] "public" "country" '["city_id"]]
type CityTable = CityConstraints :=> CityColumns

type CountryColumns = '["country_id" ::: 'Def :=> 'NotNull PGint4
  ,"country" ::: 'NoDef :=> 'NotNull (PGvarchar 50)
  ,"last_update" ::: 'Def :=> 'NotNull PGtimestamp]
type CountryConstraints = '["country_pkey" ::: 'PrimaryKey '["country_id"]]
type CountryTable = CountryConstraints :=> CountryColumns

type CustomerColumns = '["customer_id" ::: 'Def :=> 'NotNull PGint4
  ,"store_id" ::: 'NoDef :=> 'NotNull PGint2
  ,"first_name" ::: 'NoDef :=> 'NotNull (PGvarchar 45)
  ,"last_name" ::: 'NoDef :=> 'NotNull (PGvarchar 45)
  ,"email" ::: 'NoDef :=> 'Null (PGvarchar 50)
  ,"address_id" ::: 'NoDef :=> 'NotNull PGint2
  ,"activebool" ::: 'Def :=> 'NotNull PGbool
  ,"create_date" ::: 'Def :=> 'NotNull PGdate
  ,"last_update" ::: 'Def :=> 'Null PGtimestamp
  ,"active" ::: 'NoDef :=> 'Null PGint4]
type CustomerConstraints = '["customer_address_id_fkey" ::: 'ForeignKey '["address_id"] "public" "address" '["customer_id"]
  ,"customer_pkey" ::: 'PrimaryKey '["customer_id"]]
type CustomerTable = CustomerConstraints :=> CustomerColumns

type FilmColumns = '["film_id" ::: 'Def :=> 'NotNull PGint4
  ,"title" ::: 'NoDef :=> 'NotNull (PGvarchar 255)
  ,"description" ::: 'NoDef :=> 'Null PGtext
  ,"release_year" ::: 'NoDef :=> 'Null PGint4
  ,"language_id" ::: 'NoDef :=> 'NotNull PGint2
  ,"rental_duration" ::: 'Def :=> 'NotNull PGint2
  ,"rental_rate" ::: 'Def :=> 'NotNull PGnumeric
  ,"length" ::: 'NoDef :=> 'Null PGint2
  ,"replacement_cost" ::: 'Def :=> 'NotNull PGnumeric
  ,"rating" ::: 'Def :=> 'Null PGmpaa_rating
  ,"last_update" ::: 'Def :=> 'NotNull PGtimestamp
  ,"special_features" ::: 'NoDef :=> 'Null (PGvararray (NotNull PGtext))
  ,"fulltext" ::: 'NoDef :=> 'NotNull PGtsvector]
type FilmConstraints = '["film_language_id_fkey" ::: 'ForeignKey '["language_id"] "public" "language" '["film_id"]
  ,"film_pkey" ::: 'PrimaryKey '["film_id"]]
type FilmTable = FilmConstraints :=> FilmColumns

type FilmActorColumns = '["actor_id" ::: 'NoDef :=> 'NotNull PGint2
  ,"film_id" ::: 'NoDef :=> 'NotNull PGint2
  ,"last_update" ::: 'Def :=> 'NotNull PGtimestamp]
type FilmActorConstraints = '["film_actor_actor_id_fkey" ::: 'ForeignKey '["actor_id"] "public" "actor" '["actor_id"]
  ,"film_actor_film_id_fkey" ::: 'ForeignKey '["film_id"] "public" "film" '["actor_id"]
  ,"film_actor_pkey" ::: 'PrimaryKey '["actor_id","film_id"]]
type FilmActorTable = FilmActorConstraints :=> FilmActorColumns

type FilmCategoryColumns = '["film_id" ::: 'NoDef :=> 'NotNull PGint2
  ,"category_id" ::: 'NoDef :=> 'NotNull PGint2
  ,"last_update" ::: 'Def :=> 'NotNull PGtimestamp]
type FilmCategoryConstraints = '["film_category_category_id_fkey" ::: 'ForeignKey '["category_id"] "public" "category" '["film_id"]
  ,"film_category_film_id_fkey" ::: 'ForeignKey '["film_id"] "public" "film" '["film_id"]
  ,"film_category_pkey" ::: 'PrimaryKey '["film_id","category_id"]]
type FilmCategoryTable = FilmCategoryConstraints :=> FilmCategoryColumns

type InventoryColumns = '["inventory_id" ::: 'Def :=> 'NotNull PGint4
  ,"film_id" ::: 'NoDef :=> 'NotNull PGint2
  ,"store_id" ::: 'NoDef :=> 'NotNull PGint2
  ,"last_update" ::: 'Def :=> 'NotNull PGtimestamp]
type InventoryConstraints = '["inventory_film_id_fkey" ::: 'ForeignKey '["film_id"] "public" "film" '["inventory_id"]
  ,"inventory_pkey" ::: 'PrimaryKey '["inventory_id"]]
type InventoryTable = InventoryConstraints :=> InventoryColumns

type LanguageColumns = '["language_id" ::: 'Def :=> 'NotNull PGint4
  ,"name" ::: 'NoDef :=> 'NotNull (PGchar 20)
  ,"last_update" ::: 'Def :=> 'NotNull PGtimestamp]
type LanguageConstraints = '["language_pkey" ::: 'PrimaryKey '["language_id"]]
type LanguageTable = LanguageConstraints :=> LanguageColumns

type PaymentColumns = '["payment_id" ::: 'Def :=> 'NotNull PGint4
  ,"customer_id" ::: 'NoDef :=> 'NotNull PGint2
  ,"staff_id" ::: 'NoDef :=> 'NotNull PGint2
  ,"rental_id" ::: 'NoDef :=> 'NotNull PGint4
  ,"amount" ::: 'NoDef :=> 'NotNull PGnumeric
  ,"payment_date" ::: 'NoDef :=> 'NotNull PGtimestamp]
type PaymentConstraints = '["payment_customer_id_fkey" ::: 'ForeignKey '["customer_id"] "public" "customer" '["payment_id"]
  ,"payment_pkey" ::: 'PrimaryKey '["payment_id"]
  ,"payment_rental_id_fkey" ::: 'ForeignKey '["rental_id"] "public" "rental" '["payment_id"]
  ,"payment_staff_id_fkey" ::: 'ForeignKey '["staff_id"] "public" "staff" '["payment_id"]]
type PaymentTable = PaymentConstraints :=> PaymentColumns

type RentalColumns = '["rental_id" ::: 'Def :=> 'NotNull PGint4
  ,"rental_date" ::: 'NoDef :=> 'NotNull PGtimestamp
  ,"inventory_id" ::: 'NoDef :=> 'NotNull PGint4
  ,"customer_id" ::: 'NoDef :=> 'NotNull PGint2
  ,"return_date" ::: 'NoDef :=> 'Null PGtimestamp
  ,"staff_id" ::: 'NoDef :=> 'NotNull PGint2
  ,"last_update" ::: 'Def :=> 'NotNull PGtimestamp]
type RentalConstraints = '["rental_customer_id_fkey" ::: 'ForeignKey '["customer_id"] "public" "customer" '["rental_id"]
  ,"rental_inventory_id_fkey" ::: 'ForeignKey '["inventory_id"] "public" "inventory" '["rental_id"]
  ,"rental_pkey" ::: 'PrimaryKey '["rental_id"]
  ,"rental_staff_id_key" ::: 'ForeignKey '["staff_id"] "public" "staff" '["rental_id"]]
type RentalTable = RentalConstraints :=> RentalColumns

type StaffColumns = '["staff_id" ::: 'Def :=> 'NotNull PGint4
  ,"first_name" ::: 'NoDef :=> 'NotNull (PGvarchar 45)
  ,"last_name" ::: 'NoDef :=> 'NotNull (PGvarchar 45)
  ,"address_id" ::: 'NoDef :=> 'NotNull PGint2
  ,"email" ::: 'NoDef :=> 'Null (PGvarchar 50)
  ,"store_id" ::: 'NoDef :=> 'NotNull PGint2
  ,"active" ::: 'Def :=> 'NotNull PGbool
  ,"username" ::: 'NoDef :=> 'NotNull (PGvarchar 16)
  ,"password" ::: 'NoDef :=> 'Null (PGvarchar 40)
  ,"last_update" ::: 'Def :=> 'NotNull PGtimestamp
  ,"picture" ::: 'NoDef :=> 'Null PGbytea]
type StaffConstraints = '["staff_address_id_fkey" ::: 'ForeignKey '["address_id"] "public" "address" '["staff_id"]
  ,"staff_pkey" ::: 'PrimaryKey '["staff_id"]]
type StaffTable = StaffConstraints :=> StaffColumns

type StoreColumns = '["store_id" ::: 'Def :=> 'NotNull PGint4
  ,"manager_staff_id" ::: 'NoDef :=> 'NotNull PGint2
  ,"address_id" ::: 'NoDef :=> 'NotNull PGint2
  ,"last_update" ::: 'Def :=> 'NotNull PGtimestamp]
type StoreConstraints = '["store_address_id_fkey" ::: 'ForeignKey '["address_id"] "public" "address" '["store_id"]
  ,"store_manager_staff_id_fkey" ::: 'ForeignKey '["manager_staff_id"] "public" "staff" '["store_id"]
  ,"store_pkey" ::: 'PrimaryKey '["store_id"]]
type StoreTable = StoreConstraints :=> StoreColumns

-- VIEWS
type Views =
  '["actor_info" ::: 'View ActorInfoView,"customer_list" ::: 'View CustomerListView,"film_list" ::: 'View FilmListView,"nicer_but_slower_film_list" ::: 'View NicerButSlowerFilmListView,"sales_by_film_category" ::: 'View SalesByFilmCategoryView,"sales_by_store" ::: 'View SalesByStoreView,"staff_list" ::: 'View StaffListView]

type ActorInfoView =
  '["actor_id" ::: 'Null PGint4
   ,"first_name" ::: 'Null PGtext
   ,"last_name" ::: 'Null PGtext
   ,"film_info" ::: 'Null PGtext]

type CustomerListView =
  '["id" ::: 'Null PGint4
   ,"name" ::: 'Null PGtext
   ,"address" ::: 'Null PGtext
   ,"zip code" ::: 'Null PGtext
   ,"phone" ::: 'Null PGtext
   ,"city" ::: 'Null PGtext
   ,"country" ::: 'Null PGtext
   ,"notes" ::: 'Null PGtext
   ,"sid" ::: 'Null PGint2]

type FilmListView =
  '["fid" ::: 'Null PGint4
   ,"title" ::: 'Null PGtext
   ,"description" ::: 'Null PGtext
   ,"category" ::: 'Null PGtext
   ,"price" ::: 'Null PGnumeric
   ,"length" ::: 'Null PGint2
   ,"rating" ::: 'Null PGmpaa_rating
   ,"actors" ::: 'Null PGtext]

type NicerButSlowerFilmListView =
  '["fid" ::: 'Null PGint4
   ,"title" ::: 'Null PGtext
   ,"description" ::: 'Null PGtext
   ,"category" ::: 'Null PGtext
   ,"price" ::: 'Null PGnumeric
   ,"length" ::: 'Null PGint2
   ,"rating" ::: 'Null PGmpaa_rating
   ,"actors" ::: 'Null PGtext]

type SalesByFilmCategoryView =
  '["category" ::: 'Null PGtext
   ,"total_sales" ::: 'Null PGnumeric]

type SalesByStoreView =
  '["store" ::: 'Null PGtext
   ,"manager" ::: 'Null PGtext
   ,"total_sales" ::: 'Null PGnumeric]

type StaffListView =
  '["id" ::: 'Null PGint4
   ,"name" ::: 'Null PGtext
   ,"address" ::: 'Null PGtext
   ,"zip code" ::: 'Null PGtext
   ,"phone" ::: 'Null PGtext
   ,"city" ::: 'Null PGtext
   ,"country" ::: 'Null PGtext
   ,"sid" ::: 'Null PGint2]

-- functions
type Functions =
  '[ "_group_concat" ::: Function ('[ Null PGtext,  Null PGtext ] :=> 'Returns ( 'Null PGtext) )
   , "film_in_stock" ::: Function ('[ Null PGint4,  Null PGint4 ] :=> 'Returns ( 'Null PGint4) )
   , "film_not_in_stock" ::: Function ('[ Null PGint4,  Null PGint4 ] :=> 'Returns ( 'Null PGint4) )
   , "get_customer_balance" ::: Function ('[ Null PGint4,  Null PGtimestamp ] :=> 'Returns ( 'Null PGnumeric) )
   , "group_concat" ::: Function ('[ Null PGtext ] :=> 'Returns ( 'Null PGtext) )
   , "inventory_held_by_customer" ::: Function ('[ Null PGint4 ] :=> 'Returns ( 'Null PGint4) )
   , "inventory_in_stock" ::: Function ('[ Null PGint4 ] :=> 'Returns ( 'Null PGbool) )
   , "last_day" ::: Function ('[ NotNull PGtimestamp ] :=> 'Returns ( 'Null PGdate) ) ]
type Domains = '["year" ::: 'Typedef PGint4]
type PGyear = PGint4
