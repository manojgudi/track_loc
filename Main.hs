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

-- Will soon be taken as command line arguments
repoPath = "~/scripts/myRepo"
fileType = "py"

main = do
    -- get Branch Head
    branchHEAD   <- findBranchHead repoPath

    allCommits   <- getAllCommits repoPath
    commitsLOC   <- liftM reverse $ myFold repoPath fileType allCommits

    revertStatus <- revertRepositoryHead repoPath

    plot X11 $ Data2D [Title "Sample Data"] [] [(toEnum x, snd y) | (x,y) <- zip [1..(length commitsLOC)] commitsLOC]

