module TrackLoc where

import Control.Monad
import Data.String.Utils (split)
import HSH (run)

-- {"commit1" : 12, "commit2" : 47 ..}
type LOCperCommit = (String, Int)

{-
 - Takes a line of git log, retains the commit hash, discards else
 - -}
filterLog :: String -> String
filterLog x = (split " " x) !! 0

{-
 - Returns all commits of a repository
 - -}
getAllCommits :: FilePath -> IO [String]
getAllCommits repoPath = do
    content <- run $ "git -C " ++ repoPath ++ " --no-pager log --pretty=oneline " :: IO String
    return $ map filterLog (lines content)


findFiles :: FilePath -> String -> IO [String]
findFiles repoPath fileType = do
    out <- run $ " find " ++ repoPath ++ " -name \"*.\"" ++ fileType :: IO String
    return (lines out)

{-
countLines counts lines in that file
-}
countLines :: FilePath -> IO Int
countLines completeFilePath = do
    a <- run $ "cat " ++ completeFilePath ++ " | wc -l" :: IO String
    return  (read a :: Int)

{-
 - git checkout each commit and find number of lines of all files with type fileType
 - -}
myFold :: FilePath -> String -> [String] -> IO [LOCperCommit]
myFold repoPath fileType []     = return []
myFold repoPath fileType (x:xs) = do
    status     <- run $ "git -C " ++ repoPath ++ " checkout " ++ x :: IO String
    allFiles   <- findFiles repoPath fileType

-- strLOC is total number of lines in that commit of all files with type fileType
    strLOC     <- mapM countLines allFiles

-- sum strLOC is 0 if there are no files of type fileType in that commit
    val        <- liftM ([(x, (sum strLOC))] ++ )  (myFold repoPath fileType xs)
    return val

-- get the Branch Head of the repository
findBranchHead :: FilePath -> IO String
findBranchHead repoPath = do
    branchHEAD <- run $ "git -C " ++ repoPath ++ "  rev-parse --abbrev-ref HEAD "
    return branchHEAD

-- revertRepoHead
revertRepoHead :: FilePath -> String -> IO String
revertRepoHead repoPath branchHEAD = do
    revertStatus <- run $ "git -C " ++ repoPath ++ " checkout " ++ branchHEAD :: IO String
    return revertStatus


{-
 - For testing functions
main :: IO ()
main = do
    allCommits <- getAllCommits "~/scripts/myRepo"
    out <- myFold "~/scripts/myRepo" "py" allCommits
    print out
-}
