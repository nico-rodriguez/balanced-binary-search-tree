# Type Safe BST and AVL trees

Implementation of type safe BST and AVL trees, following four different approaches: unsafe, full externalist, externalist and internalist.

## Summary

- [Prerequisites](#prerequisites)
- [Installing](#installing)
- [Project Structure](#project-structure)
- [Interface](#interface)
- [Examples](#examples)
- [Benchmark](#benchmark)

## Prerequisites

```Shell
ghc (>= 8.10.2)  # GHC Haskell compiler
```

No external Haskell libraries are needed.

## Installing

To get a running copy of the project, simply clone this repository:

```Shell
git clone https://github.com/nico-rodriguez/balanced-binary-search-tree.git
```

## Project Structure

```Shell
balanced-binary-search-tree
│   README.md
└───benchmark
|    └───AVL
|    │   └───FullExtern
|    |   |   |   Benchmark.hs
|    │   │   │
|    |   |   └───Insert
|    │   │   │
|    |   |   └───Lookup
|    │   │   │
|    |   |   └───Delete
|    │   └───Extern
|    │   │   │   ...
|    │   └───Intern
|    │   │   │   ...
|    │   └───Unsafe
|    │       │   ...
|    └───BST
|    │   └───FullExtern
|    |   |   |   Benchmark.hs
|    │   │   │
|    |   |   └───Insert
|    │   │   │
|    |   |   └───Lookup
|    │   │   │
|    |   |   └───Delete
|    │   └───Extern
|    │   │   │   ...
|    │   └───Intern
|    │   │   │   ...
|    │   └───Unsafe
|    │       │   ...
└───src/Data/Tree
    │   ITree.hs
    │   Node.hs
    └───AVL
    │   │   FullExtern.hs
    │   │   Extern.hs
    │   │   Intern.hs
    │   │   Unsafe.hs
    │   │   Invariants.hs
    │   └───FullExtern
    │   │   │   Examples.hs
    │   └───Extern
    │   │   │   Constructor.hs
    │   │   │   Balance.hs, BalanceProofs.hs
    │   │   │   Insert.hs, InsertProofs.hs
    │   │   │   Lookup.hs
    │   │   │   Delete.hs, DeleteProofs.hs
    │   │   │   Examples.hs
    │   └───Intern
    │   │   │   Constructor.hs
    │   │   │   Balance.hs
    │   │   │   Insert.hs
    │   │   │   Lookup.hs
    │   │   │   Delete.hs
    │   │   │   Examples.hs
    │   └───Unsafe
    │       │   Examples.hs
    └───BST
        │   FullExtern.hs
        │   Extern.hs
        │   Intern.hs
        │   Invariants.hs
        │   Utils.hs
        └───FullExtern
        │   │   Examples.hs
        │   └───Extern
        │   │   Constructor.hs
        │   │   Insert.hs, InsertProofs.hs
        │   │   Lookup.hs
        │   │   Delete.hs, DeleteProofs.hs
        │   │   Examples.hs
        └───Intern
            │   Constructor.hs
            │   Insert.hs
            │   Lookup.hs
            │   Delete.hs
            │   Examples.hs
            └───Unsafe
                │   Examples.hs
```

- `ITree.hs` implements the `Tree` and `ITree` data types.

- `Node.hs` implements the nodes of the trees.

- Structure of `Data/Tree/AVL` and `Data/Tree/BST` is similar.

- `Data/Tree/{BST,AVL}/Invariants.hs` implements the BST,AVL invariants, like what it means for a tree to be BST,AVL.

- `Data/Tree/AVL/Unsafe.hs` contains an unsafe implementation of AVL trees (notice there's not an unsafe implementation of BST only). This code was extracted and refactored from that in `Data/Tree/AVL/Extern/{Balance,Insert,Lookup,Delete}.hs`, 'un-lifting' the type level computations to the value level.

- `FullExtern.hs` contains the implementation of the full externalist approach. It provides functionality for performing operations over trees and checking the invariants at the end.

- `Extern.hs` provides the implementation of BST/AVL trees and its operations for the externalist approach; likewise, `Intern` folder contains the implementation for the internalist approach. Notice that there isn't a `*Proofs.hs` inside `Intern`. That's because the proofs and operations in the internalist approach are implemented together (in `{Balance,Insert,Lookup,Delete}.hs`).

- `Unsafe`, `FullExtern`, `Extern`, and `Intern` have an `Examples.hs` with usage examples of the BST/AVL operations.

- In order to use BST/AVL trees, only one of `Usafe.hs`, `FullExtern.hs`, `Extern.hs` or `Intern.hs` need to be imported.

## Interface

Both externalist and internalist approaches have a common interface for manipulating BST/AVL trees. The difference in their implementation is the approach taken when defining the structural invariants that represent the conditions for a tree to be BST/AVL.

### BST trees (some function constraints omitted)

The interface for the full externalist approach is

- `EmptyITree :: ITree 'EmptyTree`.

- `insert :: Node x a -> ITree t -> ITree (Insert x a t)`.

- `lookup :: (t ~ 'ForkTree l (Node n a1) r, Member x t ~ 'True) => Proxy x -> ITree t -> a`.

- `delete :: Proxy x -> ITree t ->  (Delete x t)`.

- `BST :: (IsBST t ~ 'True) => ITree t -> BST t`.

- `proofIsBST :: ITree t -> IsBST t :~: 'True`.

The following is the interface for BST tree for externalist and internalist approaches

- `emptyBST :: BST 'EmptyTree`, an empty BST tree.

- `insertBST :: Proxy x -> a -> BST t -> BST (Insert x a t)`, inserts a value of type `a` with key `x` in a BST of type `BST t`. If the tree already has a node with key `x`, the value is updated.

- `lookupBST :: (t ~ 'ForkTree l (Node n a1) r, Member x t ~ 'True) => Proxy x -> BST t -> a`, returns the value, of type `a`, that is associated to the key `x` in the BST tree of type `BST t`. The constraint `t ~ 'ForkTree l (Node n a1) r` checks at compile time if the tree is not empty; the constraint `Member x t ~ 'True` checks at compile time that the tree `t` has a node with key `x` (ensuring that the lookup will return some value).

- `deleteBST :: Proxy x -> BST t -> BST (Delete x t)`, deletes the node with key `x` in a BST of type `BST t`. If the tree doesn't have a node with key `x`, it just returns the original tree.

### AVL trees (some function constraints omitted)

For the unsafe approach, the interface is

- `emptyAVL :: AVL`.

- `insertAVL :: Show a => Int -> a -> AVL -> AVL`.

- `lookupAVL :: Int -> AVL -> Maybe a`.

- `deleteAVL :: Int -> AVL -> AVL`.

For the full externalist approach, the interface is

- `EmptyITree :: ITree 'EmptyTree`.

- `insert :: Node x a -> ITree t -> ITree (Insert x a t)`.

- `lookup :: (t ~ 'ForkTree l (Node n a1) r, Member x t ~ 'True) => Proxy x -> ITree t -> a`.

- `delete :: Proxy x -> ITree t ->  (Delete x t)`.

- `AVL :: (IsBST t ~ 'True, IsAVL t ~ 'True) => ITree t -> AVL t`.

- `proofIsBST :: ITree t -> IsBST t :~: 'True`.

- `proofIsAVL :: ITree t -> IsAVL t :~: 'True`.

For the externalist and internalist approaches, the interface is

- `emptyAVL :: AVL 'EmptyTree`.

- `insertAVL :: Proxy x -> a -> AVL t -> AVL (Insert x a t)`.

- `lookupAVL :: (t ~ 'ForkTree l (Node n a1) r, Member x t ~ 'True) => Proxy x -> AVL t -> a`.

- `deleteAVL :: Proxy x -> AVL t -> AVL (Delete x t)`.

## Examples

For more usage examples see the `Examples.hs` file for each approach.

### Full Extern

A full externalist approach means grouping the operations and only perform the check of the invariants at the end (instead of checking the invariants after each operation)

```haskell
import           Data.Proxy (Proxy (Proxy))
import           Data.Type.Equality   (gcastWith)
import           Data.Tree.AVL.FullExtern (delete, ITree(EmptyITree), insert, lookup, AVL(AVL),
                                ProofIsAVL(proofIsAVL))
import           Data.Tree.Node (mkNode)

-- Insert four values in a row and check the BST and AVL invariants at the end
avl = gcastWith (proofIsAVL t) $ gcastWith (proofIsBST t) $ AVL t
    where
        t = insert (mkNode (Proxy::Proxy 4) 'f') $ insert (mkNode (Proxy::Proxy 3) True) $ insert (mkNode (Proxy::Proxy 5) [1,2,3]) $ EmptyTree

-- For performing a lookup, it's necessary to take the ITree 't' out of the AVL constructor
l1' = case avl of
    AVL t -> lookup (Proxy::Proxy 3) t

-- | Error at compile time: key 1 is not in the tree avl
-- err = case avl of
--     AVL t -> lookup p1 t
-- For performing deletions, it's necessary to take the ITree 't' out of the AVL constructor
avlt2 = case avl of
AVL t -> gcastWith (proofIsAVL t') $ gcastWith (proofIsBST t') $ AVL t'
            where
                t' = delete (Proxy::Proxy 3) $ delete (Proxy::Proxy 4) $ delete (Proxy::Proxy 5) $ t
```

### Extern

```haskell
import Proxy (Proxy(Proxy))
import Data.Tree.BST.Extern (emptyBST,insertBST,lookupBST,deleteBST)
import Data.Tree.AVL.Extern (emptyAVL,insertAVL,lookupAVL,deleteAVL)

bste = emptyBST

# Insert value 'f' with key 4
bst1 = insertBST (Proxy::Proxy 4) 'f' bste
# Insert value [1,2] with key 2
bst2 = insertBST (Proxy::Proxy 2) [1,2] bst1

# list = [1,2]
list = lookupBST (Proxy::Proxy 2) bst2
# Following line gives error at compile time because bst2 doesn't have key 3
# lookupBST (Proxy::Proxy 3) bst2

# Delete node with key 4
bst3 = deleteBST (Proxy::Proxy 4) bst 2
# Following line gives error at compile time because bst2 doesn't have key 1
# deleteBST (Proxy::Proxy 1) bst2
```

The previous example used BST tree. For using AVL trees just replace

```Shell
emptyBST -> emptyAVL
insertBST -> insertAVL
lookupBST -> lookupAVL
deleteBST -> deleteAVL
```

Notice that operations for BST may only be applied to BST trees, and operations for AVL trees may only be applied for AVL trees. For instance, this is not possible (gives error at compile time):

```haskell
insertAVL (Proxy::Proxy 5) bst2
```

because `bst2` is not an AVL tree.

### Intern

For using the internalist approach, the code example for the externalist approach works, with the only difference in the import list:

```haskell
import Data.Tree.BST.Intern (emptyBST,insertBST,lookupBST,deleteBST)
-- Instead of import Data.Tree.BST.Extern (emptyBST,insertBST,lookupBST,deleteBST)

import Data.Tree.AVL.Intern (emptyAVL,insertAVL,lookupAVL,deleteAVL)
-- Instead of import Data.Tree.AVL.Extern (emptyAVL,insertAVL,lookupAVL,deleteAVL)
```

## Benchmark

### Structure

```Shell
balanced-binary-search-tree
│   README.md
└───benchmark
|    └───AVL
|    │   └───FullExtern
|    |   |   |   Benchmark.hs
|    │   │   │
|    |   |   └───Insert
|    │   │   │
|    |   |   └───Lookup
|    │   │   │
|    |   |   └───Delete
|    │   └───Extern
|    │   │   │   ...
|    │   └───Intern
|    │   │   │   ...
|    │   └───Unsafe
|    │       │   ...
|    └───BST
|    │   ...
```

There are benchmarks for both BST and AVL trees for each approach. For instance, in the folder `benchmark/AVL/FullExtern`
there are three folders and one source file: `Insert`, `Lookup`, `Delete` and `Benchmark.hs`.

Inside each folder there are
different source files for benchmarking each operation under several tree sizes; they're splitted in different files
in order to be able to measure not only the running times, but also the compile times.

The source files `Benchmark.hs` performs all of the benchmarks defined inside the folders `Insert`, `Lookup` and `Delete`.

### Running the benchmark

TODO: Explain how to run the automated benchmark
