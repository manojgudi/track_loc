{-# LANGUAGE FlexibleInstances, TypeSynonymInstances, IncoherentInstances #-}
{-
 - Need to add:
 - Take FilePath and fileType as command line arguments
 - Leave the folder in original state (git checkout original branch) after done crawling
 - -}
import Control.Monad
import qualified Data.Map as M
import Graphics.EasyPlot
import TrackLoc

main = do
    allCommits <- getAllCommits "~/scripts/myRepo"
    commitsLOC <- liftM reverse $ myFold "~/scripts/myRepo" "py" allCommits

    plot X11 $ Data2D [Title "Sample Data"] [] [(toEnum x, snd y) | (x,y) <- zip [1..(length commitsLOC)] commitsLOC] 
