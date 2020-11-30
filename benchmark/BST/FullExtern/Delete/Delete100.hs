{-# LANGUAGE DataKinds #-}
{-# LANGUAGE Safe      #-}

module BST.FullExtern.Delete.Delete100 (e100, main) where


import           Data.Time.Clock                (diffUTCTime, getCurrentTime)
import           Data.Proxy                     (Proxy (Proxy))
import           Data.Tree.BST.FullExtern       (delete, BST(BST), mkBST)
import           Prelude                        (IO, putStrLn, return, seq,
                                                show, (++), ($))
import           BST.FullExtern.Insert.Insert100 (t100)


e100 = case t100 of
  BST t100' _ -> mkBST t
      where
        t = delete (Proxy::Proxy 99) $ delete (Proxy::Proxy 98) $ delete (Proxy::Proxy 97) $ delete (Proxy::Proxy 96) $ delete (Proxy::Proxy 95) $ delete (Proxy::Proxy 94) $ delete (Proxy::Proxy 93) $ delete (Proxy::Proxy 92) $ delete (Proxy::Proxy 91) $ delete (Proxy::Proxy 90) $
            delete (Proxy::Proxy 89) $ delete (Proxy::Proxy 88) $ delete (Proxy::Proxy 87) $ delete (Proxy::Proxy 86) $ delete (Proxy::Proxy 85) $ delete (Proxy::Proxy 84) $ delete (Proxy::Proxy 83) $ delete (Proxy::Proxy 82) $ delete (Proxy::Proxy 81) $ delete (Proxy::Proxy 80) $
            delete (Proxy::Proxy 79) $ delete (Proxy::Proxy 78) $ delete (Proxy::Proxy 77) $ delete (Proxy::Proxy 76) $ delete (Proxy::Proxy 75) $ delete (Proxy::Proxy 74) $ delete (Proxy::Proxy 73) $ delete (Proxy::Proxy 72) $ delete (Proxy::Proxy 71) $ delete (Proxy::Proxy 70) $
            delete (Proxy::Proxy 69) $ delete (Proxy::Proxy 68) $ delete (Proxy::Proxy 67) $ delete (Proxy::Proxy 66) $ delete (Proxy::Proxy 65) $ delete (Proxy::Proxy 64) $ delete (Proxy::Proxy 63) $ delete (Proxy::Proxy 62) $ delete (Proxy::Proxy 61) $ delete (Proxy::Proxy 60) $
            delete (Proxy::Proxy 59) $ delete (Proxy::Proxy 58) $ delete (Proxy::Proxy 57) $ delete (Proxy::Proxy 56) $ delete (Proxy::Proxy 55) $ delete (Proxy::Proxy 54) $ delete (Proxy::Proxy 53) $ delete (Proxy::Proxy 52) $ delete (Proxy::Proxy 51) $ delete (Proxy::Proxy 50) $
            delete (Proxy::Proxy 49) $ delete (Proxy::Proxy 48) $ delete (Proxy::Proxy 47) $ delete (Proxy::Proxy 46) $ delete (Proxy::Proxy 45) $ delete (Proxy::Proxy 44) $ delete (Proxy::Proxy 43) $ delete (Proxy::Proxy 42) $ delete (Proxy::Proxy 41) $ delete (Proxy::Proxy 40) $
            delete (Proxy::Proxy 39) $ delete (Proxy::Proxy 38) $ delete (Proxy::Proxy 37) $ delete (Proxy::Proxy 36) $ delete (Proxy::Proxy 35) $ delete (Proxy::Proxy 34) $ delete (Proxy::Proxy 33) $ delete (Proxy::Proxy 32) $ delete (Proxy::Proxy 31) $ delete (Proxy::Proxy 30) $
            delete (Proxy::Proxy 29) $ delete (Proxy::Proxy 28) $ delete (Proxy::Proxy 27) $ delete (Proxy::Proxy 26) $ delete (Proxy::Proxy 25) $ delete (Proxy::Proxy 24) $ delete (Proxy::Proxy 23) $ delete (Proxy::Proxy 22) $ delete (Proxy::Proxy 21) $ delete (Proxy::Proxy 20) $
            delete (Proxy::Proxy 19) $ delete (Proxy::Proxy 18) $ delete (Proxy::Proxy 17) $ delete (Proxy::Proxy 16) $ delete (Proxy::Proxy 15) $ delete (Proxy::Proxy 14) $ delete (Proxy::Proxy 13) $ delete (Proxy::Proxy 12) $ delete (Proxy::Proxy 11) $ delete (Proxy::Proxy 10) $
            delete (Proxy::Proxy 9) $ delete (Proxy::Proxy 8) $ delete (Proxy::Proxy 7) $ delete (Proxy::Proxy 6) $ delete (Proxy::Proxy 5) $ delete (Proxy::Proxy 4) $ delete (Proxy::Proxy 3) $ delete (Proxy::Proxy 2) $ delete (Proxy::Proxy 1) $ delete (Proxy::Proxy 0) t100'

main :: IO ()
main = do seq t100 (return ())
          t0 <- getCurrentTime
          seq e100 (return ())
          t1 <- getCurrentTime
          putStrLn ("Time: " ++ show (diffUTCTime t0 t1) ++ " seconds")
