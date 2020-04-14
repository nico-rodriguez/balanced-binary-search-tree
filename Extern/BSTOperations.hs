{-# LANGUAGE DataKinds             #-}
{-# LANGUAGE FlexibleContexts      #-}
{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE ScopedTypeVariables   #-}
{-# LANGUAGE TypeFamilies          #-}
{-# LANGUAGE TypeOperators         #-}
{-# LANGUAGE UndecidableInstances  #-}

module Extern.BSTOperations (
  Insertable(Insert, insert), Insertable'(Insert', insert'),
  Member,
  Lookupable(lookup),
  Maxable(MaxKey, MaxValue, maxValue), MaxKeyDeletable(MaxKeyDelete, maxKeyDelete),
  Deletable(Delete, delete), Deletable'(Delete', delete')
) where

import           Data.Kind          (Type)
import           Data.Proxy         (Proxy (Proxy))
import           Data.Type.Bool     (If)
import           Data.Type.Equality (type (==))
import           GHC.TypeLits       (CmpNat, Nat)
import           ITree              (ITree (EmptyITree, ForkITree),
                                     Tree (EmptyTree, ForkTree))
import           Node               (Node (Node), getValue)
import           Prelude            (Bool (False, True), Ordering (EQ, GT, LT),
                                     Show)

-- | This class provides the functionality to insert a node with key 'x' and value type 'a'
-- | in a tree 't' without checking any structural invariant (BST).
-- | The insertion is defined at the value level and the type level, and is performed
-- | as if the tree is a BST; the checking of the BST invariant is performed after the insertion.
class Insertable (x :: Nat) (a :: Type) (t :: Tree) where
  type Insert (x :: Nat) (a :: Type) (t :: Tree) :: Tree
  insert :: Node x a -> ITree t -> ITree (Insert x a t)
instance Show a => Insertable x a 'EmptyTree where
  type Insert x a 'EmptyTree = 'ForkTree 'EmptyTree (Node x a) 'EmptyTree
  insert (Node a) EmptyITree         = ForkITree EmptyITree (Node a::Node x a) EmptyITree
instance Insertable' x a ('ForkTree l (Node n a1) r) (CmpNat x n) => Insertable x a ('ForkTree l (Node n a1) r) where
  type Insert x a ('ForkTree l (Node n a1) r) = Insert' x a ('ForkTree l (Node n a1) r) (CmpNat x n)
  insert n t = insert' n t (Proxy::Proxy (CmpNat x n))

-- | This class provides the functionality to insert a node with key 'x' and value type 'a'
-- | in a non empty tree 't' without checking any structural invariant (BST).
-- | It's only used by the 'Insertable' class and it has one extra parameter 'o',
-- | which is the type level comparison of 'x' with the key value of the root node.
-- | The 'o' parameter guides the insertion.
class Insertable' (x :: Nat) (a :: Type) (t :: Tree) (o :: Ordering) where
  type Insert' (x :: Nat) (a :: Type) (t :: Tree) (o :: Ordering) :: Tree
  insert' :: Node x a -> ITree t -> Proxy o -> ITree (Insert x a t)
instance (Show a, CmpNat x n ~ 'EQ) => Insertable' x a ('ForkTree l (Node n a1) r) 'EQ where
  type Insert' x a ('ForkTree l (Node n a1) r) 'EQ = 'ForkTree l (Node n a) r
  insert' (Node a) (ForkITree l (Node _) r) _ = ForkITree l (Node a::Node n a) r
instance (Show a, CmpNat x n ~ 'LT) => Insertable' x a ('ForkTree 'EmptyTree (Node n a1) r) 'LT where
  type Insert' x a ('ForkTree 'EmptyTree (Node n a1) r) 'LT = 'ForkTree ('ForkTree 'EmptyTree (Node x a) 'EmptyTree) (Node n a1) r
  insert' (Node a) (ForkITree EmptyITree n r) _ = ForkITree (ForkITree EmptyITree (Node a::Node x a) EmptyITree) n r
instance (CmpNat x n ~ 'LT, l ~ 'ForkTree ll (Node ln lna) lr, Insertable' x a l (CmpNat x ln)) => Insertable' x a ('ForkTree ('ForkTree ll (Node ln lna) lr) (Node n a1) r) 'LT where
  type Insert' x a ('ForkTree ('ForkTree ll (Node ln lna) lr) (Node n a1) r) 'LT = 'ForkTree (Insert' x a ('ForkTree ll (Node ln lna) lr) (CmpNat x ln)) (Node n a1) r
  insert' (Node a) (ForkITree l@ForkITree{} n r) _ = ForkITree (insert' (Node a::Node x a) l (Proxy::Proxy (CmpNat x ln))) n r
instance (Show a, CmpNat x n ~ 'GT) => Insertable' x a ('ForkTree l (Node n a1) 'EmptyTree) 'GT where
  type Insert' x a ('ForkTree l (Node n a1) 'EmptyTree) 'GT = 'ForkTree l (Node n a1) ('ForkTree 'EmptyTree (Node x a) 'EmptyTree)
  insert' (Node a) (ForkITree l n EmptyITree) _ = ForkITree l n (ForkITree EmptyITree (Node a::Node x a) EmptyITree)
instance (CmpNat x n ~ 'GT, r ~ 'ForkTree rl (Node rn rna) rr, Insertable' x a r (CmpNat x rn)) => Insertable' x a ('ForkTree l (Node n a1) ('ForkTree rl (Node rn rna) rr)) 'GT where
  type Insert' x a ('ForkTree l (Node n a1) ('ForkTree rl (Node rn rna) rr)) 'GT = 'ForkTree l (Node n a1) (Insert' x a ('ForkTree rl (Node rn rna) rr) (CmpNat x rn))
  insert' (Node a) (ForkITree l n r@ForkITree{}) _ = ForkITree l n (insert' (Node a::Node x a) r (Proxy::Proxy (CmpNat x rn)))

-- | Type family to test wether there is a node in the tree 't' with key 'x'.
-- | It assumes that 't' is a BST in order to perform the search.
type family Member (x :: Nat) (t :: Tree) :: Bool where
  Member _x 'EmptyTree = 'False
  Member x ('ForkTree l (Node n _a) r) =
    (If (CmpNat x n == 'EQ)
      'True
      (If (CmpNat x n == 'LT)
        (Member x l)
        (Member x r)
      )
    )

-- | Type family to search for the type of the value stored with key 'x' in a tree 't'.
-- | It assumes that 't' is a BST and that 'x' is a member of 't' in order to perform the search
-- | (so it always return a valid type).
type family LookupValueType (x :: Nat) (t :: Tree) :: Type where
  LookupValueType x ('ForkTree l (Node n a) r) =
    (If (CmpNat x n == 'EQ)
      a
      (If (CmpNat x n == 'LT)
        (LookupValueType x l)
        (LookupValueType x r)
      )
    )

-- | This class provides the functionality to lookup a node with key 'x'
-- | in a non empty tree 't' without checking any structural invariant (BST).
-- | The lookup is defined at the value level and the type level, and is performed
-- | as if the tree is a BST.
-- | It's necessary to know the type 'a' of the value stored in node with key 'x'
-- | so that the type of the value returned by 'lookup' may be specified.
class Lookupable (x :: Nat) (a :: Type) (t :: Tree) where
  lookup :: (t ~ 'ForkTree l (Node n a1) r, Member x t ~ 'True) =>
    Proxy x -> ITree t -> a
instance (Lookupable' x a ('ForkTree l (Node n a1) r) (CmpNat x n), a ~ LookupValueType x ('ForkTree l (Node n a1) r)) =>
  Lookupable x a ('ForkTree l (Node n a1) r) where
  lookup x t = lookup' x t (Proxy::Proxy (CmpNat x n))

-- | This class provides the functionality to lookup a node with key 'x'
-- | in a non empty tree 't' without checking any structural invariant (BST).
-- | It's only used by the 'Lookupable' class and it has one extra parameter 'o',
-- | which is the type level comparison of 'x' with the key value of the root node.
-- | The 'o' parameter guides the lookup.
class Lookupable' (x :: Nat) (a :: Type) (t :: Tree) (o :: Ordering) where
  lookup' :: (t ~ 'ForkTree l (Node n a1) r, Member x t ~ 'True) =>
    Proxy x -> ITree t -> Proxy o -> a
instance Lookupable' x a ('ForkTree l (Node n a) r) 'EQ where
  lookup' _ (ForkITree _ node _) _ = getValue node
instance (l ~ 'ForkTree ll (Node ln lna) lr, Member x l ~ 'True, Lookupable' x a l (CmpNat x ln)) =>
  Lookupable' x a ('ForkTree ('ForkTree ll (Node ln lna) lr) (Node n a1) r) 'LT where
  lookup' p (ForkITree l@ForkITree{} _ _) _ = lookup' p l (Proxy::Proxy (CmpNat x ln))
instance (r ~ 'ForkTree rl (Node rn rna) rr, Member x r ~ 'True, Lookupable' x a ('ForkTree rl (Node rn rna) rr) (CmpNat x rn)) =>
  Lookupable' x a ('ForkTree l (Node n a1) ('ForkTree rl (Node rn rna) rr)) 'GT where
  lookup' p (ForkITree _ _ r@ForkITree{}) _ = lookup' p r (Proxy::Proxy (CmpNat x rn))

-- | This class provides the functionality to delete the node with maximum key value
-- | in a tree 't' without checking any structural invariant (BST).
-- | The deletion is defined at the value level and the type level, and is performed
-- | as if the tree is a BST; the checking of the BST invariant is performed after the deletion.
class MaxKeyDeletable (t :: Tree) where
  type MaxKeyDelete (t :: Tree) :: Tree
  maxKeyDelete :: (t ~ 'ForkTree l (Node n a1) r) =>
    ITree t -> ITree (MaxKeyDelete t)
instance MaxKeyDeletable 'EmptyTree where
  type MaxKeyDelete 'EmptyTree = 'EmptyTree
  maxKeyDelete EmptyITree = EmptyITree
instance MaxKeyDeletable ('ForkTree l (Node n a1) 'EmptyTree) where
  type MaxKeyDelete ('ForkTree l (Node n a1) 'EmptyTree) = l
  maxKeyDelete (ForkITree l (Node _) EmptyITree) = l
instance MaxKeyDeletable ('ForkTree rl (Node rn ra) rr) =>
  MaxKeyDeletable ('ForkTree l (Node n a1) ('ForkTree rl (Node rn ra) rr)) where
  type MaxKeyDelete ('ForkTree l (Node n a1) ('ForkTree rl (Node rn ra) rr)) =
    ('ForkTree l (Node n a1) (MaxKeyDelete ('ForkTree rl (Node rn ra) rr)))
  maxKeyDelete (ForkITree l node r@ForkITree{}) =
    ForkITree l node (maxKeyDelete r)

-- | This class provides the functionality to get the key, type and value of the node with maximum key value
-- | in a tree 't' without checking any structural invariant (BST).
-- | The lookup is defined at the value level and the type level, and is performed
-- | as if the tree is a BST.
-- | Since the keys are only kept at the type level, there's no value level getter of the maximum key.
class Maxable (t :: Tree) where
  type MaxKey (t :: Tree) :: Nat
  type MaxValue (t :: Tree) :: Type
  maxValue :: (t ~ 'ForkTree l (Node n a1) r, a ~ MaxValue t) =>
    ITree t -> a
instance Maxable ('ForkTree l (Node n a1) 'EmptyTree) where
  type MaxKey ('ForkTree l (Node n a1) 'EmptyTree) = n
  type MaxValue ('ForkTree l (Node n a1) 'EmptyTree) = a1
  maxValue (ForkITree _ (Node a1) EmptyITree) = a1
instance Maxable ('ForkTree rl (Node rn ra) rr) =>
  Maxable ('ForkTree l (Node n a1) ('ForkTree rl (Node rn ra) rr)) where
  type MaxKey ('ForkTree l (Node n a1) ('ForkTree rl (Node rn ra) rr)) = MaxKey ('ForkTree rl (Node rn ra) rr)
  type MaxValue ('ForkTree l (Node n a1) ('ForkTree rl (Node rn ra) rr)) = MaxValue ('ForkTree rl (Node rn ra) rr)
  maxValue (ForkITree _ (Node _) r@ForkITree{}) = maxValue r

-- | This class provides the functionality to delete the node with key 'x'
-- | in a tree 't' without checking any structural invariant (BST).
-- | The deletion is defined at the value level and the type level, and is performed
-- | as if the tree is a BST; the checking of the BST invariant is performed after the deletion.
class Deletable (x :: Nat) (t :: Tree) where
  type Delete (x :: Nat) (t :: Tree) :: Tree
  delete :: Proxy x -> ITree t -> ITree (Delete x t)
instance Deletable x 'EmptyTree where
  type Delete x 'EmptyTree = 'EmptyTree
  delete _ EmptyITree = EmptyITree
instance (Deletable' x ('ForkTree l (Node n a1) r) (CmpNat x n)) =>
  Deletable x ('ForkTree l (Node n a1) r) where
  type Delete x ('ForkTree l (Node n a1) r) = Delete' x ('ForkTree l (Node n a1) r) (CmpNat x n)
  delete px t = delete' px t (Proxy::Proxy (CmpNat x n))

-- | This class provides the functionality to delete a node with key 'x'
-- | in a non empty tree 't' without checking any structural invariant (BST).
-- | It's only used by the 'Deletable' class and it has one extra parameter 'o',
-- | which is the type level comparison of 'x' with the key value of the root node.
-- | The 'o' parameter guides the insertion.
class Deletable' (x :: Nat) (t :: Tree) (o :: Ordering) where
  type Delete' (x :: Nat) (t :: Tree) (o :: Ordering) :: Tree
  delete' :: Proxy x -> ITree t -> Proxy o -> ITree (Delete' x t o)
instance Deletable' x ('ForkTree 'EmptyTree (Node n a1) 'EmptyTree) 'EQ where
  type Delete' x ('ForkTree 'EmptyTree (Node n a1) 'EmptyTree) 'EQ = 'EmptyTree
  delete' _ (ForkITree EmptyITree (Node _) EmptyITree) _ = EmptyITree
instance Deletable' x ('ForkTree 'EmptyTree (Node n a1) ('ForkTree rl (Node rn ra) rr)) 'EQ where
  type Delete' x ('ForkTree 'EmptyTree (Node n a1) ('ForkTree rl (Node rn ra) rr)) 'EQ = ('ForkTree rl (Node rn ra) rr)
  delete' _ (ForkITree EmptyITree (Node _) r@ForkITree{}) _ = r
instance Deletable' x ('ForkTree ('ForkTree ll (Node ln la) lr) (Node n a1) 'EmptyTree) 'EQ where
  type Delete' x ('ForkTree ('ForkTree ll (Node ln la) lr) (Node n a1) 'EmptyTree) 'EQ = ('ForkTree ll (Node ln la) lr)
  delete' _ (ForkITree l@ForkITree{} (Node _) EmptyITree) _ = l
instance (Show (MaxValue ('ForkTree ll (Node ln la) lr)), MaxKeyDeletable ('ForkTree ll (Node ln la) lr), Maxable ('ForkTree ll (Node ln la) lr)) =>
  Deletable' x ('ForkTree ('ForkTree ll (Node ln la) lr) (Node n a1) ('ForkTree rl (Node rn ra) rr)) 'EQ where
  type Delete' x ('ForkTree ('ForkTree ll (Node ln la) lr) (Node n a1) ('ForkTree rl (Node rn ra) rr)) 'EQ =
    ('ForkTree (MaxKeyDelete ('ForkTree ll (Node ln la) lr)) (Node (MaxKey ('ForkTree ll (Node ln la) lr)) (MaxValue ('ForkTree ll (Node ln la) lr))) ('ForkTree rl (Node rn ra) rr))
  delete' _ (ForkITree l@ForkITree{} (Node _) r@ForkITree{}) _ =
    ForkITree (maxKeyDelete l) (Node (maxValue l)::Node (MaxKey ('ForkTree ll (Node ln la) lr)) (MaxValue ('ForkTree ll (Node ln la) lr))) r
instance Deletable' x ('ForkTree 'EmptyTree (Node n a1) r) 'LT where
  type Delete' x ('ForkTree 'EmptyTree (Node n a1) r) 'LT = ('ForkTree 'EmptyTree (Node n a1) r)
  delete' _ t@(ForkITree EmptyITree (Node _) _) _ = t
instance (Deletable' x ('ForkTree ll (Node ln la) lr) (CmpNat x ln)) =>
  Deletable' x ('ForkTree ('ForkTree ll (Node ln la) lr) (Node n a1) r) 'LT where
  type Delete' x ('ForkTree ('ForkTree ll (Node ln la) lr) (Node n a1) r) 'LT =
    ('ForkTree (Delete' x ('ForkTree ll (Node ln la) lr) (CmpNat x ln)) (Node n a1) r)
  delete' px (ForkITree l@ForkITree{} node r) _ = ForkITree (delete' px l (Proxy::Proxy (CmpNat x ln))) node r
instance Deletable' x ('ForkTree l (Node n a1) 'EmptyTree) 'GT where
  type Delete' x ('ForkTree l (Node n a1) 'EmptyTree) 'GT = ('ForkTree l (Node n a1) 'EmptyTree)
  delete' _ t@(ForkITree _ (Node _) EmptyITree) _ = t
instance (Deletable' x ('ForkTree rl (Node rn ra) rr) (CmpNat x rn)) =>
  Deletable' x ('ForkTree l (Node n a1) ('ForkTree rl (Node rn ra) rr)) 'GT where
  type Delete' x ('ForkTree l (Node n a1) ('ForkTree rl (Node rn ra) rr)) 'GT =
    ('ForkTree l (Node n a1) (Delete' x ('ForkTree rl (Node rn ra) rr) (CmpNat x rn)))
  delete' px (ForkITree l node r@ForkITree{}) _ = ForkITree l node (delete' px r (Proxy::Proxy (CmpNat x rn)))
