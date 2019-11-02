{-# LANGUAGE DataKinds             #-}
{-# LANGUAGE FlexibleContexts      #-}
{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE GADTs                 #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE PolyKinds             #-}
{-# LANGUAGE RankNTypes            #-}
{-# LANGUAGE ScopedTypeVariables   #-}
{-# LANGUAGE TypeFamilies          #-}
{-# LANGUAGE TypeOperators         #-}
{-# LANGUAGE UndecidableInstances  #-}

module Intern.AVL (
  AVL(..),
  insertAVL,
  lookupAVL,
  deleteAVL
) where

import           Data.Proxy
import           Data.Type.Equality
import           Intern.AVLOperations
import           Intern.BSTOperations (Lookupable (..), Member)
import           ITree
import           Node
import           Prelude              hiding (lookup)

insertAVL :: (Insertable x a t) =>
  Node x a -> AVL t -> AVL (Insert x a t)
insertAVL = insert

lookupAVL :: (t ~ 'ForkTree l (Node n a1) r, Member x t ~ 'True, Lookupable x a t) =>
  Proxy x -> AVL t -> a
lookupAVL = lookup

deleteAVL :: (Deletable x t) =>
  Proxy x -> AVL t -> AVL (Delete x t)
deleteAVL = delete
