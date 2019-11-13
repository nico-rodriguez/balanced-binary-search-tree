{-# LANGUAGE DataKinds #-}
{-# LANGUAGE Safe      #-}

import           Benchmarking.FullExtern.Operations (InsertN, insertN)
import           Benchmarking.Utils                 (diffUTCTime)
import           Data.Proxy                         (Proxy (Proxy))
import           Extern.AVL                         (AVL ())
import           Prelude                            (Bool (False), IO, putStrLn,
                                                     return, seq, show, (++))
import           System.Time                        (getCurrentTime)
import           ITree (Tree(EmptyTree))


t100 :: AVL (InsertN 100 'False 'EmptyTree)
t100 = insertN (Proxy::Proxy 100) (Proxy::Proxy 'False)

main :: IO ()
main = do t0 <- getCurrentTime
          seq t100 (return ())
          t1 <- getCurrentTime
          putStrLn ("Time: " ++ show (diffUTCTime t0 t1) ++ " seconds")
