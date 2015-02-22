import Data.String.Utils (split)
import HSH (run)
import qualified Data.Map as M

-- {"commit1" : 12, "commit2" : 47 ..}
type LOCperCommit = M.Map String Int

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
countLines FilePath -> IO Int
countLines completeFilePath = do
    a <- run $ "cat " ++ completeFilePath ++ " | wc -l" :: IO String
    return  (read a :: Int)

{-
 - git checkout each commit and find number of lines of all files with type fileType
 - -}
myFold :: FilePath -> String -> LOCperCommit -> [String] -> IO LOCperCommit
myFold repoPath fileType dict []     = return dict
myFold repoPath fileType dict (x:xs) = do
    status     <- run $ "git -C " ++ repoPath ++ " checkout " ++ x :: IO String
    allFiles   <- findFiles repoPath fileType

-- strLOC is total number of lines in that commit of all files with type fileType
    strLOC     <- mapM countLines allFiles

-- sum strLOC is 0 if there are no files of type fileType in that commit
    val        <- myFold repoPath fileType  (M.insert x (sum strLOC) dict) xs
    return val


main :: IO ()
main = do
    allCommits <- getAllCommits "~/scripts/myRepo"
    out <- myFold "~/scripts/myRepo" "py" (M.insert "" 0 M.empty) allCommits
    putStrLn $ M.showTree out
