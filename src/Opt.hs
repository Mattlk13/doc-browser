{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Opt
  ( T(..)
  , get
  , Logging(..)
  ) where

import Options.Applicative
import Data.Monoid

import Path

import qualified Doc
import Utils

data T
  = StartGUI Logging

  | InstallDevDocs [Doc.Collection]
  | ListInstalledDevDocs
  | RemoveDevDocs [(Doc.Collection, Doc.Version)]

  | InstallDash [Doc.Collection]
  | ListInstalledDash
  | ListRemoteDash
  | RemoveDash [(Doc.Collection, Doc.Version)]

  | InstallHoogle String Doc.Collection

  | PrintPublicAPI
  | PrintDefaultConfig
  | PrintPort
  deriving (Show)

data Logging
  = NoLog
  | Log
  deriving(Show)

data IsStartedOK
  = StartedOK
  | StartedNotOK
  deriving (Show)


optParser :: ParserInfo T
optParser =
  info
    (optParser' <**> helper)
    (progDesc "A documentation browser for developers")
  where
    optParser' :: Parser T
    optParser' =
      startGUIParser
        <|> installDevDocsParser
        <|> listInstalledDevDocsParser
        <|> removeDevDocsParser

        <|> installDashParser
        <|> listInstalledDashParser
        <|> listRemoteDashParser
        <|> removeDashParser

        <|> installHoogleParser
        <|> printPublicAPIParser
        <|> printDefaultConfigParser
        <|> printPortParser
        <|> pure (StartGUI NoLog)

startGUIParser :: Parser T
startGUIParser =
  flag' StartGUI
    (  long "gui"
    <> help "Start the GUI. This is the default behaviour")
  <*> flag NoLog Log
    (  long "debug"
    <> help "Write some debug information to stdout, I'm sorry if you need this")

readCollection :: ReadM Doc.Collection
readCollection = eitherReader $ \str' ->
  case Doc.parseCollection str' of
    Left e -> Left $ show e
    Right x -> Right x

installDevDocsParser :: Parser T
installDevDocsParser =
  flag' InstallDevDocs
    (  long "install-devdocs"
    <> help "Install DevDocs' docset")
  <*> some (argument readCollection
    (  metavar "DOC"
    <> help "Docset to install, like \"haskell\", \"python\""
    ))

listInstalledDevDocsParser :: Parser T
listInstalledDevDocsParser =
  flag' ListInstalledDevDocs
    (  long "list-installed-devdocs"
    <> help "List installed DevDocs' docset")

removeDevDocsParser :: Parser T
removeDevDocsParser =
  flag' RemoveDevDocs
    (  long "remove-devdocs"
    <> help "Remove DevDocs' docset")
  <*> some (argument readCollectionVersionTuple
    (  metavar "CV"
    <> help "A string in the format of COLLECTION==VERSION. Intended to be used with --list-installed-devdocs"
    ))

readCollectionVersionTuple :: ReadM (Doc.Collection, Doc.Version)
readCollectionVersionTuple = eitherReader $ \str -> do
  cvPath <- mapLeft show $ parseRelDir str
  mapLeft show (Doc.breakCollectionVersion cvPath)

installDashParser :: Parser T
installDashParser =
  flag' InstallDash
    (  long "install-dash"
    <> help "Install Dash's docset")
  <*> some (argument readCollection
    (  metavar "COLLECTION"
    -- TODO @incomplete: documentation
    <> help "Collection to install"
    ))

listInstalledDashParser :: Parser T
listInstalledDashParser =
  flag' ListInstalledDash
    (  long "list-installed-dash"
    <> help "List installed Dash's docset")

listRemoteDashParser :: Parser T
listRemoteDashParser =
  flag' ListRemoteDash
    (  long "list-remote-dash"
    <> help "List all available Dash docset")

removeDashParser :: Parser T
removeDashParser =
  flag' RemoveDash
    (  long "remove-dash"
    <> help "Remove Dash's docset")
  <*> some (argument readCollectionVersionTuple
    (  metavar "CV"
    <> help "A string in the format of COLLECTION==VERSION. Intended to be used with --list-installed-dash"
    ))

installHoogleParser :: Parser T
installHoogleParser =
  flag' InstallHoogle
    (  long "install-hoogle"
    <> help "Generate a Hoogle database from an archive, so it can be queried later")
  <*> strArgument
    (  metavar "URL"
    <> help (unwords
        [ "The archive to read."
        , "It can either be a local file or a HTTP link,"
        , "but should be in the format of \".tar.xz\"."
        , "It expects the unpacked archive can be consumed by `hoogle generate --local=<unpack_dir>`"
        , "Example: https://s3.amazonaws.com/haddock.stackage.org/lts-10.8/bundle.tar.xz"
        ]))
  <*> (argument readCollection
    (  metavar "COLLECTION"
    <> help "Name of the database and documentation directory. Something like \"lts-10.8\" would be a good choice"))

printPublicAPIParser :: Parser T
printPublicAPIParser =
  flag' PrintPublicAPI
    (  long "print-api"
    <> help "Print the HTTP API")

printDefaultConfigParser :: Parser T
printDefaultConfigParser =
  flag' PrintDefaultConfig
    (  long "print-default-config"
    <> help "Print the default configuration, which has detailed documentation")

printPortParser :: Parser T
printPortParser =
  flag' PrintPort
    (  long "get-port"
    <> help "Find out which port does this application use")

get :: IO T
get = execParser optParser
