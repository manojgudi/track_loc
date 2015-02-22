{-# LANGUAGE FlexibleInstances, TypeSynonymInstances, IncoherentInstances #-}
{-
-- If chart library ever installs correctly
import Graphics.Rendering.Chart.Easy
import Graphics.Rendering.Chart.Backend.Cairo

titles = ["commits"]

values :: [ (Strint, Int) ]
values = [("commit1", 123)
         ,("commit2", 14)
         ,("commit3", 43)
         ]

main = toFile def "example.png" $ do
    layout_title .= "Sample Bars"
    layout_title_style . font_size .= 10
    layout_x_axis . laxis_generate .= autoIndexAxis (map fst values)
    plot $ fmap plotBars $ bars titles (addIndexes (map snd values))
-}
import qualified Data.Map as M
import Graphics.EasyPlot
import TrackLoc

main = do
    allCommits <- getAllCommits "~/scripts/supa"
    out <- myFold "~/scripts/supa" "py" (M.insert "" 0 M.empty) allCommits
    let pdata = M.toList out
    print [(x, snd y) | (x,y) <- zip [1..(length pdata)] pdata] 
    plot X11 $ Data2D [Title "Sample Data"] [] [(toEnum x, snd y) | (x,y) <- zip [1..(length pdata)] pdata] 
