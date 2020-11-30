{-# LANGUAGE DataKinds #-}
{-# LANGUAGE Safe      #-}


module BST.Extern.Lookup.Lookup20 (v20, main) where

import           Data.Time.Clock            (diffUTCTime, getCurrentTime)
import           Data.Proxy                 (Proxy (Proxy))
import           Data.Tree.BST.Extern       (lookupBST)
import           Prelude                    (IO, putStrLn, return, seq, show, (++))
import           BST.Extern.Insert.Insert20 (t20)


v20 = lookupBST (Proxy::Proxy 19) t20

main :: IO ()
main = do seq t20 (return ())
          t0 <- getCurrentTime
          seq v20 (return ())
          t1 <- getCurrentTime
          putStrLn ("Time: " ++ show (diffUTCTime t1 t0) ++ " seconds")
