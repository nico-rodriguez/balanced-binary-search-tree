{-# LANGUAGE DataKinds #-}
{-# LANGUAGE Safe      #-}


module AVL.Intern.Lookup.Lookup40 (v40, main) where

import           Data.Time.Clock            (diffUTCTime, getCurrentTime)
import           Data.Proxy                 (Proxy (Proxy))
import           Data.Tree.AVL.Intern       (lookupAVL)
import           Prelude                    (IO, putStrLn, return, seq, show, (++))
import           AVL.Intern.Insert.Insert40 (t40)


v40 = lookupAVL (Proxy::Proxy 39) t40

main :: IO ()
main = do seq t40 (return ())
          t0 <- getCurrentTime
          seq v40 (return ())
          t1 <- getCurrentTime
          putStrLn ("Time: " ++ show (diffUTCTime t1 t0) ++ " seconds")
