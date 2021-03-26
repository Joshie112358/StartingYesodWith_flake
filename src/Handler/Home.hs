{-# LANGUAGE DeriveDataTypeable         #-}
{-# LANGUAGE FlexibleContexts           #-}
{-# LANGUAGE GADTs                      #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE NoImplicitPrelude          #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE QuasiQuotes                #-}
{-# LANGUAGE ScopedTypeVariables        #-}
{-# LANGUAGE TemplateHaskell            #-}
{-# LANGUAGE TypeFamilies               #-}



module Handler.Home where


import           Import
import           Lucid                       hiding (Html, toHtml)
import           LucidTemplates.HomeTemplate
import           Text.Blaze.Html
import           Text.Julius                 (RawJS (..))
import           Yesod.Form.Bootstrap3       (BootstrapFormLayout (..),
                                              renderBootstrap3)

getHomeR :: Handler Html
getHomeR = do
  defaultLayout $ do
    setTitle "Hola Mundo!"
    toWidget . preEscapedToHtml . renderText $ homePage
