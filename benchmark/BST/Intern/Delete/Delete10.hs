{-# LANGUAGE DataKinds #-}
{-# LANGUAGE Safe      #-}

module BST.Intern.Delete.Delete10 (e10, main) where


import           Data.Time.Clock            (diffUTCTime, getCurrentTime)
import           Data.Proxy                 (Proxy (Proxy))
import           Data.Tree.BST.Intern       (deleteBST)
import           Prelude                    (IO, putStrLn, return, seq,
                                            show, (++), ($))
import           BST.Intern.Example.Example10 (t10)


e10 = deleteBST (Proxy::Proxy 9) t10

main :: IO ()
main = do seq t10 (return ())
          t0 <- getCurrentTime
          seq e10 (return ())
          t1 <- getCurrentTime
          putStrLn ("Time: " ++ show (diffUTCTime t1 t0) ++ " seconds")
