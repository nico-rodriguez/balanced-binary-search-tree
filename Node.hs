{-# LANGUAGE DataKinds          #-}
{-# LANGUAGE GADTs              #-}
{-# LANGUAGE PolyKinds          #-}
{-# LANGUAGE RankNTypes         #-}
{-# LANGUAGE StandaloneDeriving #-}

module Node (Node(Node), mkNode, getValue) where

import           Data.Kind    (Type)
import           Data.Proxy   (Proxy)
import           GHC.TypeLits (Nat)
import           Prelude      (Show)

data Node :: Nat -> Type -> Type where
  Node :: a -> Node k a
deriving instance Show a => Show (Node k a)

mkNode :: forall (k::Nat)(a::Type). Proxy k -> a -> Node k a
mkNode _ = Node

getValue :: forall (k::Nat)(a::Type). Node k a -> a
getValue (Node a) = a
