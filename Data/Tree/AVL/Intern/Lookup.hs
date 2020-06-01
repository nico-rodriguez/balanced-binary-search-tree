{-# LANGUAGE DataKinds             #-}
{-# LANGUAGE ExplicitNamespaces    #-}
{-# LANGUAGE FlexibleContexts      #-}
{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE ScopedTypeVariables   #-}
{-# LANGUAGE TypeFamilies          #-}
{-# LANGUAGE UndecidableInstances  #-}

module Data.Tree.AVL.Intern.Lookup (
  Lookupable(lookup)
) where

import           Data.Kind                        (Type)
import           Data.Proxy                       (Proxy (Proxy))
import           Data.Tree.AVL.Intern.Constructor (AVL (ForkAVL))
import           Data.Tree.BST.Utils              (LookupValueType, Member)
import           Data.Tree.ITree                  (Tree (ForkTree))
import           Data.Tree.Node                   (Node (Node), getValue)
import           GHC.TypeLits                     (CmpNat, Nat)
import           Prelude                          (Bool (True),
                                                   Ordering (EQ, GT, LT))


-- | This class provides the functionality to lookup a node with key 'x'
-- | in a non empty AVL 't'.
-- | The lookup is defined at the value level and the type level.
-- | It's necessary to know the type 'a' of the value stored in node with key 'x'
-- | so that the type of the value returned by 'lookup' may be specified.
class Lookupable (x :: Nat) (a :: Type) (t :: Tree) where
  lookup :: (t ~ 'ForkTree l (Node n a1) r, Member x t ~ 'True) =>
    Proxy x -> AVL t -> a
instance (Lookupable' x a ('ForkTree l (Node n a1) r) (CmpNat x n), a ~ LookupValueType x ('ForkTree l (Node n a1) r)) =>
  Lookupable x a ('ForkTree l (Node n a1) r) where
  lookup x t = lookup' x t (Proxy::Proxy (CmpNat x n))

-- | This class provides the functionality to lookup a node with key 'x'
-- | in a non empty AVL 't'.
-- | It's only used by the 'Lookupable' class and it has one extra parameter 'o',
-- | which is the type level comparison of 'x' with the key value of the root node.
-- | The 'o' parameter guides the lookup.
class Lookupable' (x :: Nat) (a :: Type) (t :: Tree) (o :: Ordering) where
  lookup' :: Proxy x -> AVL t -> Proxy o -> a
instance Lookupable' x a ('ForkTree l (Node n a) r) 'EQ where
  lookup' _ (ForkAVL _ (Node a) _) _ = getValue (Node a::Node n a)
instance (l ~ 'ForkTree ll (Node ln lna) lr, Lookupable' x a l (CmpNat x ln)) =>
  Lookupable' x a ('ForkTree ('ForkTree ll (Node ln lna) lr) (Node n a1) r) 'LT where
  lookup' p (ForkAVL l@ForkAVL{} _ _) _ = lookup' p l (Proxy::Proxy (CmpNat x ln))
instance (r ~ 'ForkTree rl (Node rn rna) rr, Lookupable' x a r (CmpNat x rn)) =>
  Lookupable' x a ('ForkTree l (Node n a1) ('ForkTree rl (Node rn rna) rr)) 'GT where
  lookup' p (ForkAVL _ _ r@ForkAVL{}) _ = lookup' p r (Proxy::Proxy (CmpNat x rn))