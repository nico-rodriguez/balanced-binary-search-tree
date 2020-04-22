{-# LANGUAGE DataKinds #-}
{-# LANGUAGE Safe      #-}


module Benchmarking.Extern.Lookup.Lookup30 (v30, main) where

import           Data.Time.Clock (diffUTCTime, getCurrentTime)
import           Data.Proxy                     (Proxy (Proxy))
import           Extern.AVL                     (AVL (AVL))
import           Extern.BSTOperations               (Lookupable (lookup))
import           Prelude                        (IO, putStrLn, return, seq, show, (++))
import           Benchmarking.Extern.Insert.Insert30 (t30)


v30 = case t30 of
  AVL t30' -> lookup (Proxy::Proxy 0) t30'

main :: IO ()
main = do seq t30 (return ())
          t0 <- getCurrentTime
          seq v30 (return ())
          t1 <- getCurrentTime
          putStrLn ("Time: " ++ show (diffUTCTime t0 t1) ++ " seconds")