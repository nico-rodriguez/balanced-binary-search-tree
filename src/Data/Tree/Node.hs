{-# LANGUAGE DataKinds          #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE GADTs              #-}
{-# LANGUAGE KindSignatures     #-}
{-# LANGUAGE StandaloneDeriving #-}

{-# LANGUAGE Safe               #-}

module Data.Tree.Node (Node, mkNode, getValue) where

import           Data.Kind    (Type)
import           Data.Proxy   (Proxy)
import           GHC.TypeLits (Nat)
import           Prelude      (Show)

data Node :: Nat -> Type -> Type where
  Node :: a -> Node k a
deriving stock instance Show a => Show (Node k a)

mkNode :: Proxy k -> a -> Node k a
mkNode _ = Node

getValue :: Node k a -> a
getValue (Node a) = a
