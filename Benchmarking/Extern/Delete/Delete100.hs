{-# LANGUAGE DataKinds #-}
{-# LANGUAGE Safe      #-}

import           Benchmarking.Extern.Operations (InsertN, deleteN, insertN)
import           Data.Time.Clock (diffUTCTime, getCurrentTime)
import           Data.Proxy                     (Proxy (Proxy))
import           Extern.AVL                     (AVL (AVL))
import           ITree                          (Tree (EmptyTree), ITree (EmptyITree))
import           Prelude                        (Bool (False), IO, putStrLn,
                                                 return, seq, show, (++))



t100 :: AVL (InsertN 100 'False 'EmptyTree)
t100 = insertN (Proxy::Proxy 100) (Proxy::Proxy 'False) (AVL EmptyITree)
e :: AVL 'EmptyTree
e = deleteN (Proxy::Proxy 100) t100

main :: IO ()
main = do seq t100 (return ())
          t0 <- getCurrentTime
          seq e (return ())
          t1 <- getCurrentTime
          putStrLn ("Time: " ++ show (diffUTCTime t0 t1) ++ " seconds")
