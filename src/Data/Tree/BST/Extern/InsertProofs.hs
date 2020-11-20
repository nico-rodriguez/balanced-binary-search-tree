{-# LANGUAGE DataKinds             #-}
{-# LANGUAGE ExplicitNamespaces    #-}
{-# LANGUAGE FlexibleContexts      #-}
{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE ScopedTypeVariables   #-}
{-# LANGUAGE TypeFamilies          #-}
{-# LANGUAGE TypeOperators         #-}
{-# LANGUAGE UndecidableInstances  #-}

{-# LANGUAGE Safe                  #-}

module Data.Tree.BST.Extern.InsertProofs (
  ProofIsBSTInsert(proofIsBSTInsert)
) where

import           Data.Kind                        (Type)
import           Data.Proxy                       (Proxy (Proxy))
import           Data.Tree.BST.Extern.Constructors(IsBSTT(EmptyIsBSTT,ForkIsBSTT))
import           Data.Tree.BST.Extern.Insert      (Insertable (Insert),
                                                   Insertable' (Insert'))
import           Data.Tree.BST.Invariants         (GtN, LtN)
import           Data.Tree.ITree                  (Tree (EmptyTree, ForkTree))
import           Data.Tree.Node                   (Node)
import           Data.Type.Equality               ((:~:) (Refl), gcastWith)
import           GHC.TypeNats                     (CmpNat, Nat)
import           Prelude                          (Bool (True), undefined,
                                                   Ordering (EQ, GT, LT), ($))


-- | Prove that inserting a node with key 'x' and element value 'a'
-- | in a BST tree preserves the BST condition.
class ProofIsBSTInsert (x :: Nat) (a :: Type) (t :: Tree) where
  proofIsBSTInsert :: Node x a -> IsBSTT t -> IsBSTT (Insert x a t)
instance ProofIsBSTInsert x a 'EmptyTree where
  proofIsBSTInsert node _ = ForkIsBSTT EmptyIsBSTT node EmptyIsBSTT
instance (o ~ CmpNat x n,
  ProofIsBSTInsert' x a ('ForkTree l (Node n a1) r) o) =>
  ProofIsBSTInsert x a ('ForkTree l (Node n a1) r) where
  proofIsBSTInsert node tIsBST = proofIsBSTInsert' node tIsBST (Proxy::Proxy o)

-- | Prove that inserting a node with key 'x' and element value 'a'
-- | in a BST tree preserves the BST condition, given that the comparison between
-- | 'x' and the root key of the tree equals 'o'.
-- | The BST invariant was already check when proofIsBSTInsert was called before.
-- | The 'o' parameter guides the proof.
class ProofIsBSTInsert' (x :: Nat) (a :: Type) (t :: Tree) (o :: Ordering) where
  proofIsBSTInsert' :: Node x a -> IsBSTT t -> Proxy o -> IsBSTT (Insert' x a t o)
instance ProofIsBSTInsert' x a ('ForkTree l (Node n a1) r) 'EQ where
  proofIsBSTInsert' _ (ForkIsBSTT l _ r) _ = ForkIsBSTT l node r
    where
      node = undefined::Node n a
instance (CmpNat x n ~ 'LT) =>
  ProofIsBSTInsert' x a ('ForkTree 'EmptyTree (Node n a1) r) 'LT where
  proofIsBSTInsert' _ (ForkIsBSTT _ node' r) _ =
    ForkIsBSTT (ForkIsBSTT EmptyIsBSTT node EmptyIsBSTT) node' r
      where
        node = undefined::Node x a
instance (l ~ 'ForkTree ll (Node ln lna) lr, o ~ CmpNat x ln,
  CmpNat x n ~ 'LT,
  ProofIsBSTInsert' x a l o, ProofLtNInsert' x a l n o) =>
  ProofIsBSTInsert' x a ('ForkTree ('ForkTree ll (Node ln lna) lr) (Node n a1) r) 'LT where
  proofIsBSTInsert' _ (ForkIsBSTT l node' r) _ =
    gcastWith (proofLtNInsert' node l (Proxy::Proxy n) po) $
    ForkIsBSTT (proofIsBSTInsert' node l po) node' r
      where
        po = Proxy::Proxy o
        node = undefined::Node x a
instance (CmpNat x n ~ 'GT) =>
  ProofIsBSTInsert' x a ('ForkTree l (Node n a1) 'EmptyTree) 'GT where
  proofIsBSTInsert' _ (ForkIsBSTT l node' _) _ =
    ForkIsBSTT l node' (ForkIsBSTT EmptyIsBSTT node EmptyIsBSTT)
      where
        node = undefined::Node x a
instance (r ~ 'ForkTree rl (Node rn rna) rr, o ~ CmpNat x rn,
  CmpNat x n ~ 'GT,
  ProofIsBSTInsert' x a r o, ProofGtNInsert' x a r n o) =>
  ProofIsBSTInsert' x a ('ForkTree l (Node n a1) ('ForkTree rl (Node rn rna) rr)) 'GT where
  proofIsBSTInsert' _ (ForkIsBSTT l node' r) _ =
    gcastWith (proofGtNInsert' node r (Proxy::Proxy n) po) $
    ForkIsBSTT l node' (proofIsBSTInsert' node r po)
      where
        po = Proxy::Proxy o
        node = undefined::Node x a


-- | Prove that inserting a node with key 'x' (lower than 'n') and element value 'a'
-- | in a tree 't' which verifies 'LtN t n ~ 'True' preserves the LtN invariant,
-- | given that the comparison between 'x' and the root key of the tree equals 'o'.
-- | The 'o' parameter guides the proof.
class ProofLtNInsert' (x :: Nat) (a :: Type) (t :: Tree) (n :: Nat) (o :: Ordering) where
  proofLtNInsert' :: (CmpNat x n ~ 'LT, LtN t n ~ 'True) =>
    Node x a -> IsBSTT t -> Proxy n -> Proxy o -> LtN (Insert' x a t o) n :~: 'True
instance (CmpNat x n1 ~ 'EQ) =>
  ProofLtNInsert' x a ('ForkTree l (Node n1 a1) r) n 'EQ where
  proofLtNInsert' _ _ _ _ = Refl
instance (CmpNat x n1 ~ 'LT) =>
  ProofLtNInsert' x a ('ForkTree 'EmptyTree (Node n1 a1) r) n 'LT where
  proofLtNInsert' _ _ _ _ = Refl
instance (l ~ 'ForkTree ll (Node ln lna) lr, o ~ CmpNat x ln,
  CmpNat x n1 ~ 'LT, LtN l n ~ 'True,
  ProofLtNInsert' x a l n o) =>
  ProofLtNInsert' x a ('ForkTree ('ForkTree ll (Node ln lna) lr) (Node n1 a1) r) n 'LT where
  proofLtNInsert' _ (ForkIsBSTT l _ _) pn _ =
    gcastWith (proofLtNInsert' node l pn (Proxy::Proxy o)) Refl
      where
          node = undefined::Node x a
instance (CmpNat x n1 ~ 'GT) =>
  ProofLtNInsert' x a ('ForkTree l (Node n1 a1) 'EmptyTree) n 'GT where
  proofLtNInsert' _ _ _ _ = Refl
instance (r ~ 'ForkTree rl (Node rn rna) rr, o ~ CmpNat x rn,
  CmpNat x n1 ~ 'GT, LtN r n ~ 'True,
  ProofLtNInsert' x a r n o) =>
  ProofLtNInsert' x a ('ForkTree l (Node n1 a1) ('ForkTree rl (Node rn rna) rr)) n 'GT where
  proofLtNInsert' _ (ForkIsBSTT _ _ r) pn _ =
    gcastWith (proofLtNInsert' node r pn (Proxy::Proxy o)) Refl
      where
        node = undefined::Node x a


-- | Prove that inserting a node with key 'x' (greater than 'n') and element value 'a'
-- | in a tree 't' which verifies 'GtN t n ~ 'True' preserves the GtN invariant,
-- | given that the comparison between 'x' and the root key of the tree equals 'o'.
-- | The 'o' parameter guides the proof.
class ProofGtNInsert' (x :: Nat) (a :: Type) (t :: Tree) (n :: Nat) (o :: Ordering) where
  proofGtNInsert' :: (CmpNat x n ~ 'GT, GtN t n ~ 'True) =>
    Node x a -> IsBSTT t -> Proxy n -> Proxy o -> GtN (Insert' x a t o) n :~: 'True
instance (CmpNat x n1 ~ 'EQ) =>
  ProofGtNInsert' x a ('ForkTree l (Node n1 a1) r) n 'EQ where
  proofGtNInsert' _ _ _ _ = Refl
instance (CmpNat x n1 ~ 'LT) =>
  ProofGtNInsert' x a ('ForkTree 'EmptyTree (Node n1 a1) r) n 'LT where
  proofGtNInsert' _ _ _ _ = Refl
instance (l ~ 'ForkTree ll (Node ln lna) lr, o ~ CmpNat x ln,
  CmpNat x n1 ~ 'LT, GtN l n ~ 'True,
  ProofGtNInsert' x a l n o) =>
  ProofGtNInsert' x a ('ForkTree ('ForkTree ll (Node ln lna) lr) (Node n1 a1) r) n 'LT where
  proofGtNInsert' node (ForkIsBSTT l _ _) pn _ =
    gcastWith (proofGtNInsert' node l pn (Proxy::Proxy o)) Refl
instance (CmpNat x n1 ~ 'GT) =>
  ProofGtNInsert' x a ('ForkTree l (Node n1 a1) 'EmptyTree) n 'GT where
  proofGtNInsert' _ _ _ _ = Refl
instance (r ~ 'ForkTree rl (Node rn rna) rr, o ~ CmpNat x rn,
  CmpNat x n1 ~ 'GT, GtN r n ~ 'True,
  ProofGtNInsert' x a r n o) =>
  ProofGtNInsert' x a ('ForkTree l (Node n1 a1) ('ForkTree rl (Node rn rna) rr)) n 'GT where
  proofGtNInsert' node (ForkIsBSTT _ _ r) pn _ =
    gcastWith (proofGtNInsert' node r pn (Proxy::Proxy o)) Refl
