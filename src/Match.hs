{-# LANGUAGE OverloadedStrings #-}

module Match
  ( T(..)
  , defClass
  ) where

import Data.Typeable (Typeable)
import Data.Text (Text)

import Graphics.QML

-- this is what will be displayed in the search results
-- the choice of Text is due to that HsQML cannot marshal String
data T = T
  { name     :: Text
  , url      :: Text
  , language :: Text
  , version  :: Text
  , source   :: Text

  -- hoogle stuff
  , package_       :: Maybe Text
  , module_        :: Maybe Text
  , typeConstraint :: Maybe Text
  } deriving (Eq, Show, Typeable)


defClass :: IO (Class T)
defClass =
  newClass
    [ defPropertyConst' "name"
        (\obj -> return (name $ fromObjRef obj))

    , defPropertyConst' "url"
        (\obj -> return (url $ fromObjRef obj))

    , defPropertyConst' "language"
        (\obj -> return (language $ fromObjRef obj))

    , defPropertyConst' "source"
        (\obj -> return (source $ fromObjRef obj))

    , defPropertyConst' "version"
        (\obj -> return (version $ fromObjRef obj))

    , defPropertyConst' "package_"
        (\obj -> return (package_ $ fromObjRef obj))

    , defPropertyConst' "module_"
        (\obj -> return (module_ $ fromObjRef obj))

    , defPropertyConst' "typeConstraint"
        (\obj -> return (typeConstraint $ fromObjRef obj))
    ]
