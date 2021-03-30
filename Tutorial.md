# Creating a yesod project with flake.nix

Here we will create a yesod project that functions with flake. What we will be doing is the following:

- [Disclaimer](https://github.com/Joshie112358/StartingYesodWith_flake/blob/master/Tutorial.md#disclaimer)
- [Important note about github](https://github.com/Joshie112358/StartingYesodWith_flake/blob/master/Tutorial.md#important-note-about-github)
1. [Installing flakes](https://github.com/Joshie112358/StartingYesodWith_flake/blob/master/Tutorial.md#installing-flakes)
2. [Creating our project](https://github.com/Joshie112358/StartingYesodWith_flake/blob/master/Tutorial.md#creating-our-project)
3. [Adding flakes to our project](https://github.com/Joshie112358/StartingYesodWith_flake/blob/master/Tutorial.md#adding-flakes-to-our-project)
4. [Setting up our database](https://github.com/Joshie112358/StartingYesodWith_flake/blob/master/Tutorial.md#setting-up-our-database)
5. [Modifying our .cabal file](https://github.com/Joshie112358/StartingYesodWith_flake/blob/master/Tutorial.md#modifying-our-cabal-file)
6. [Adding Lucid and LucidTemplates](https://github.com/Joshie112358/StartingYesodWith_flake/blob/master/Tutorial.md#adding-lucid-and-lucidtemplates)
7. [The problem with github](https://github.com/Joshie112358/StartingYesodWith_flake/blob/master/Tutorial.md#the-problem-with-github)


## Disclaimer
This is a guide similar to [Guia para el uso de Yesod en Linux con Postgres](https://github.com/VicHebar/YesodProject/blob/master/TutorialPostgres.md), and in fact, you should follow the steps 1 and 2 of that guide in order for you to be able to use this guide. We will do something similar to what that guide does in steps 3 and 4 but using flakes. We don't talk about what that guide does in step 5, but after following this guide you should be able to use the other guide in order to further develop your project.

## Important note about github
If you want your project to be in a repository, then create the repository at the end, because it can cause some errors that we will discuss at the end of this guide.



## Installing flakes
In order for you to use this guide, you will need to have flakes installed in your system, we are no experts in that matter, so please go to [Flakes' official wiki](https://nixos.wiki/wiki/Flakes).



## Creating our project
What we will first do is create our project in the directory that we want with the command `stack new my-project some-Template` where you will have to replace `my-project` with the name you want your project to have (preferably use only lowercase letters, sometimes uppercase letters cause errors) and also replace `some-Template` with the name of the template you want to use, without the *.hsfiles* extension, which in our case will be `yesodweb/postgres`. 
Our command will look like this `stack new tutorial yesodweb/postgres`. 

Next we will go to the new folder we just created with `cd my-project`, in our case `cd tutorial`. If you then run `ls` you will see the following files:

``` 
app  config  package.yaml  README.md  src  stack.yaml  static  templates  test  tutorial.cabal
```

**From now on, whenever you see `tutorial` inside a command or file, please remember that you will have to replace it with the name of your project.**

## Adding flakes to our project
Before we make our first webpage we will need add flakes to our project (because that is what we will be using).
Start by placing the following code inside a file, name it `flake.nix` and place it inside your project's main directory. Then you will have to replace every "tutorial" with the name of your project, in emacs this can be easily done with `Meta-shift-5`.


```
{
  description = "Nix flake for tutorial";

  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };
  inputs.haskellNix.url = "github:input-output-hk/haskell.nix";
  inputs.nixpkgs.follows = "haskellNix/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils, haskellNix, flake-compat }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
    let
      overlays =
        [ haskellNix.overlay
          (final: prev: {
            # This overlay adds our project to pkgs

            tutorial = final.haskell-nix.cabalProject {
              # If these null parameters are absent, you get a RestrictedPathError error
              # from trying to do readIfExists on cabal.project file
              cabalProjectFreeze = null;
              cabalProject = null;
              cabalProjectLocal = null;

              src = final.haskell-nix.cleanSourceHaskell {
                src = ./.;
                name = "tutorial";
              };
              compiler-nix-name = "ghc884";

              pkg-def-extras = with final.haskell.lib; [];
              modules = [];
            };
          })
        ];
      # lucid-from-html = haskellNix.hackage-package {
      #   name         = "pandoc";
      #   version      = "2.9.2.1";
      #   index-state  = "2020-04-15T00:00:00Z";
      #   # Function that returns a sha256 string by looking up the location
      #   # and tag in a nested attrset
      #   sha256map =
      #     { "https://github.com/jgm/pandoc-citeproc"."0.17"
      #         = "0dxx8cp2xndpw3jwiawch2dkrkp15mil7pyx7dvd810pwc22pm2q"; };
      # };
      pkgs = import nixpkgs { inherit system overlays; };
      flake = pkgs.tutorial.flake {};
    in flake // {
      # Built by `nix build .`
      defaultPackage = flake.packages."tutorial:exe:tutorial";

      # This is used by `nix develop .` to open a shell for use with
      # `cabal`, `hlint` and `haskell-language-server`
      devShell = pkgs.tutorial.shellFor {
        tools = {
          cabal = "latest";
          hlint = "latest";
          haskell-language-server = "latest";
          ghcid = "latest";
        };
      };
    });
}
```

When you have `flake.nix` inside your project folder, run `nix build` inside your folder, this will build your project, be patient, it will take a while.

Once `nix build` is done, rename `stack.yaml` to `stack.yaml.bak`and `package.yaml` to `package.yaml.bak`; you could also delete them, but renaming them gives you the opportunity to restore them in case an error occurs. As we said in the beginning, if you had made the github repository since the beginning, this step would cause an error when running `nix build` or `nix develop`.

Then, in your projects' main directory create a file named `devel.sh` with the following contents:
```
# ALL: Fix crazy reloading.

ghcid --command '(echo ":l app/DevelMain.hs" && cat) | cabal v2-repl' --test 'update' --warnings
```
This is only a command we will run inside `nix develop`, that will make something similar to what `yesod devel` does, and we will use it a lot throughout this guide.

## Setting up our database

Because we will store information, we need to setup our database. First go to  `tutorial/config/settings.yml`, there we will find the following lines:
```
database:
  user:     "_env:YESOD_PGUSER:tutorial"
  password: "_env:YESOD_PGPASS:tutorial"
  host:     "_env:YESOD_PGHOST:localhost"
  port:     "_env:YESOD_PGPORT:5432"
  # See config/test-settings.yml for an override during tests
  database: "_env:YESOD_PGDATABASE:tutorial"
  poolsize: "_env:YESOD_PGPOOLSIZE:10"
```
We will then modify the user, password and database parameters a bit, so they look like this:
```
database:
  user:     "_env:YESOD_PGUSER:tutorialu"
  password: "_env:YESOD_PGPASS:tutorialP"
  host:     "_env:YESOD_PGHOST:localhost"
  port:     "_env:YESOD_PGPORT:5432"
  # See config/test-settings.yml for an override during tests
  database: "_env:YESOD_PGDATABASE:tutorialdb"
  poolsize: "_env:YESOD_PGPOOLSIZE:10"
```
This is so we can distinguish the user, password and database.
Now go to a terminal and run `psql -U postgres postgres`, this will enter us to the prompt `postrgres=#`. We will now create our role (that will enable our project to access the database) with `CREATE ROLE tutorialu WITH LOGIN PASSWORD 'tutorialP';`, we will then see `CREATE ROLE` appear, which will notify us that there where no errors.
Then, to create our database we will run `CREATE DATABASE tutorialdb;`, the text *CREATE DATABASE* will notify us that everything went well. Lastly, we will give rights to our project to access the database, this is done with `GRANT ALL ON DATABASE tutorialdb TO tutorialu;`, the word *GRANT* will show us everything went without a hitch. 


Next, run `nix develop`, this will also take a while, and once that is finished run `./devel.sh`, or if that doesn't work try, `ghcid --command '(echo ":l app/DevelMain.hs" && cat) | cabal v2-repl' --test 'update' --warnings` (the command that is inside devel.sh). If there is an error, try again or reboot your pc or both. If everything goes well, we will see `Devel application launched: http://localhost:3000` appear in our console, then if we go to that url in our browser we will see our first webpage!, although at this point it will only be the default page that the template provides us; let's change that. But before that press Ctrl-C to end the command, then write `exit` or press Ctrl-D to exit `nix develop`, because we will run `nix develop` again in the next section.



## Modifying our .cabal file 

Now we will go to our `tutorial.cabal` file, first, at the beginning of the file, after `build type: Simple` you will need to write `data-files:` followed by the files (with routes and extensions) your project will use. Because writing every single file name would need a lot of lines and time, we will use the wildcard pattern "\*" so we need to only write one line per extension. Since we just started our project, it will look like this:
```
data-files:     config/*.yml
              , config/routes.yesodroutes
              , config/*.ico
              , config/models.persistentmodels
              , config/*.txt
              , static/css/*.css
              , static/fonts/*.eot
              , static/fonts/*.svg
              , static/fonts/*.ttf
              , static/fonts/*.woff
              , templates/*.hamlet
              , templates/*.lucius
              , templates/*.julius
```
This means, in the first line for example, that our project will use all of the files with extension .yml that are in the `config` folder. Note that when you add new files to your project you will need to come back here to list it, otherwise your project won't identify it.

Then go to the section of `exposed-modules` inside the `library` section. Here we see all the files we have in our `tutorial/src` folder, except the ones we will add, i.e. Lucid.Supplemental and LucidTemplates.HomeTemplate, add them. Once added, it should look like this:
```
library
  exposed-modules:
      Application
      Foundation
      Handler.Comment
      Handler.Common
      Handler.Home
      Handler.Profile
      LucidTemplates.HomeTemplate
      Lucid.Supplemental
      Import
      Import.NoFoundation
      Model
      Settings
      Settings.StaticFiles
```
And as with the other section, everytime you create a file (or folder) in `tutorial/src`, you will need to list it here, otherwise, you will have an error.

Now search for the end of the `build depends` section inside the `library` and `executable` modules (this should be around line 38 and line 91), there we will add the following lines: 

```
    , blaze-builder
    , blaze-html
    , blaze-markup
    , lucid
```
Because we made it so our project searches for "LucidTemplates.HomeTemplate" and "Lucid.Supplemental", we wont be able to run `nix develop` and `ghcid --command '(echo ":l app/DevelMain.hs" && cat) | cabal v2-repl' --test 'update' --warnings` without encountering an error, so let's fix that by adding those files. 

## Adding Lucid and LucidTemplates

Now we will create two new folders inside `tutorial/src`, those will be `Lucid` and `LucidTemplates`. Then go to this [Github repository](https://github.com/Joshie112358/StartingYesodWith_flake) and download the `tutorial/src/Lucid/Supplemental.hs` and `tutorial/src/LucidTemplates/HomeTemplate.hs` files. And as one would expect, we will save the `Supplemental.hs` file inside our `tutorial/src/Lucid` folder; and the `HomeTemplate.hs` file inside `tutorial/src/LucidTemplates`.


Now lets modify the `tutorial/src/Handler/Home.hs` file, where the first thing we will change are the language pragmas we will be using. Language pragmas look like this:
> {-# LANGUAGE MyLanguageExtension #-}


You can read more about them here [Yesod book](https://www.yesodweb.com/book/haskell). Replace all of the language pragmas inside `Home.hs` with the following:
```
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
```

Now go beyond `module Handler.Home where` to the imports section, you should have these imports:
```
import Import
import Yesod.Form.Bootstrap3 (BootstrapFormLayout (..), renderBootstrap3)
import Text.Julius (RawJS (..))
```
We will need to add the following imports:
```
import           Lucid                       hiding (Html, toHtml)
import           LucidTemplates.HomeTemplate
import           Text.Blaze.Html
```
So in total we will have 6 imports. What is beyond the imports section doesn't interest us, so you can erase or just comment the lines after the imports. The only function that we want inside Home.hs for now is the following, add it:
```
getHomeR :: Handler Html
getHomeR = do
  defaultLayout $ do
    setTitle "Hola Mundo!"
    toWidget . preEscapedToHtml . renderText $ homePage
```
So now our Home.hs file should look like the one over [this Github repository](https://github.com/Joshie112358/StartingYesodWith_flake). We are almost there, go to `tutorial/config/routes.yesodroutes`, there will be a line that reads like this:
```
/ HomeR GET POST
```
This tells our project that inside our Home.hs file we use both GET and POST methods, which isn't the case (because we erased the post functions that it had), so we should notify our project of this; so in the line shown before, erase the "POST" word so we only have this:
```
/ HomeR GET
```
We are now ready to run `nix develop` and `ghcid --command '(echo ":l app/DevelMain.hs" && cat) | cabal v2-repl' --test 'update' --warnings` again, if everything goes according to plan we should see `Devel application launched: http://localhost:3000` appear in the console. And if we now go to `http://localhost:3000` the words "Hello world, this is a tutorial!" will greet us.

With this you should be able to get started with your yesod project, if you want to read further go to [Guia para el uso de Yesod en Linux con Postgres](https://github.com/VicHebar/YesodProject/blob/master/TutorialPostgres.md) and read section 5. If you are interested in making your project into a github repository then read the next section.

## The problem with github
We now have our project which is able to run `ghcid --command '(echo ":l app/DevelMain.hs" && cat) | cabal v2-repl' --test 'update' --warnings` inside `nix develop`. Now lets make it a repository with 

```
git init
git add -A
git commit -m "Initial commit"
```
, and then try to run `nix build` or `nix develop`, if you are unlucky an error like this will pop up:

```
error: --- Error -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- nix
builder for '/nix/store/w2qfz2g7rsmspqznf308r9khxd8jg25q-helloworld-plan-to-nix-pkgs.drv' failed with exit code 1; last 4 log lines:
  Using index-state 2021-03-23T00:00:00Z
  No cabal.project file or cabal file matching the default glob './*.cabal' was found.
  Please create a package description file <pkgname>.cabal or a cabal.project file referencing the packages you want to build.
```

To solve this issue go to the `.gitignore` file inside your project and erase the line that says `tutorial.cabal` (instead of tutorial it should be your projects' name), this will make it so our project doesn't ignore our .cabal file. Then commit your changes with `git add -A` and `git commit -m "Modified gitignore"`. With this, you should be able to use `nix develop` and `ghcid --command '(echo ":l app/DevelMain.hs" && cat) | cabal v2-repl' --test 'update' --warnings` as before, so give it a try and start creating your project. 




