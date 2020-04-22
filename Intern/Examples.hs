{-# LANGUAGE DataKinds #-}

module Intern.Examples where

import           Data.Proxy
import           Intern.AVL
import           Intern.BST
import           ITree
import           Node

p0 :: Proxy 0
p0 = Proxy
p1 :: Proxy 1
p1 = Proxy
p2 :: Proxy 2
p2 = Proxy
p3 :: Proxy 3
p3 = Proxy
p4 :: Proxy 4
p4 = Proxy
p5 :: Proxy 5
p5 = Proxy
p6 :: Proxy 6
p6 = Proxy
p7 :: Proxy 7
p7 = Proxy

bste = emptyBST

bst1 = insertBST p4 'f' bste
bst2 = insertBST p2 (4::Int) bst1
bst3 = insertBST p6 "lala" bst2
bst4 = insertBST p3 True bst3
bst5 = insertBST p5 ([1,2,3]::[Int]) bst4
bst6 = insertBST p0 (1.8::Float) bst5
bst7 = insertBST p7 [False] bst6

data SomeData = SD
  deriving (Show)

bst8 = insertBST p7 SD bst7

l1 :: String
l1 = lookupBST p6 bst8

-- | Error: key p1 ('S 'Z) is not in the tree bst8
-- err = lookupBST p1 bst8

bst9 = deleteBST p7 bst7
bst10 = deleteBST p4 bst7
bst11 = deleteBST p1 bst7
bst12 = deleteBST p0 bst7
bst13 = deleteBST p2 bst7
bst14 = deleteBST p6 bst7
bst15 = deleteBST p5 bst7
bst16 = deleteBST p3 bst7

-- | Test Balanced Binary Tree
avle = emptyAVL
avlt1 = insertAVL (Proxy::Proxy 20) 'f' avle
avlt2 = insertAVL (Proxy::Proxy 60) (4::Int) avlt1
avlt3 = insertAVL (Proxy::Proxy 30) "lala" avlt2
avlt4 = insertAVL (Proxy::Proxy 50) True avlt3
avlt5 = insertAVL (Proxy::Proxy 0) ([1,2,3]::[Int]) avlt4
avlt6 = insertAVL (Proxy::Proxy 70) (1.8::Float) avlt5
avlt7 = insertAVL (Proxy::Proxy 70) [False] avlt6
avlt8 = insertAVL (Proxy::Proxy 75) 'a' avlt7
avlt9 = insertAVL (Proxy::Proxy 80) 'a' avlt8
avlt10 = insertAVL (Proxy::Proxy 90) 'a' avlt9
l1' :: String
l1' = lookupAVL (Proxy::Proxy 30) avlt8

-- | Error: key 10 is not in the tree avlt8
-- err = lookupAVL (Proxy::Proxy 10) avlt8

avlt11 = deleteAVL (Proxy::Proxy 20) avlt8
avlt12 = deleteAVL (Proxy::Proxy 60) avlt8
avlt13 = deleteAVL (Proxy::Proxy 30) avlt8
avlt14 = deleteAVL (Proxy::Proxy 50) avlt8
avlt15 = deleteAVL (Proxy::Proxy 0) avlt8
avlt16 = deleteAVL (Proxy::Proxy 70) avlt8
avlt17 = deleteAVL (Proxy::Proxy 70) avlt8
avlt18 = deleteAVL (Proxy::Proxy 75) avlt8
avlt19 = deleteAVL (Proxy::Proxy 21) avlt8
avlt20 = deleteAVL (Proxy::Proxy 21) avle