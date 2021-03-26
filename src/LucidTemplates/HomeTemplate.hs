{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE FlexibleInstances    #-}
{-# LANGUAGE NoImplicitPrelude    #-}
{-# LANGUAGE OverloadedStrings    #-}
{-# LANGUAGE ScopedTypeVariables  #-}

module LucidTemplates.HomeTemplate where

import           Blaze.ByteString.Builder           (Builder)
import qualified Blaze.ByteString.Builder           as Blaze
import qualified Blaze.ByteString.Builder.Html.Utf8 as Blaze
import           Data.Text.Lazy.IO                  as L
import           Database.Persist.Sql               (fromSqlKey)
import           Import                             hiding (Builder, Html, for_,
                                                     toHtml, (==.))
import           Lucid
import qualified Lucid.Base                         as LucidBase
import           Lucid.Supplemental
import           System.IO                          (hSetEncoding, stdout, utf8)

homePage :: Html ()
homePage =  do
  toHtmlRaw "<!-- Products -->"
  section_ [ class_ "about full-screen d-lg-flex justify-content-center align-items-center", id_ "products" ] $ do
    div_ [ class_ "container" ] $ do
      p_ [] "Hello world, this is a tutorial!"
