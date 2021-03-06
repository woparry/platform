{-# LANGUAGE OverloadedStrings #-}
module Unison.Test.Term where

import Unison.Term
import Unison.Term.Extra ()
import Unison.Reference as R
import Unison.Var (Var)
import Unison.Symbol (Symbol)
import Unison.Symbol.Extra ()
import Test.Tasty
-- import Test.Tasty.SmallCheck as SC
-- import Test.Tasty.QuickCheck as QC
import Test.Tasty.HUnit
import qualified Unison.ABT.Extra as ABT

-- term for testing
type TTerm = Term (Symbol (Maybe ()))

tests :: TestTree
tests = testGroup "Term"
  [ testCase "alpha equivalence (term)" $ assertEqual "identity"
     ((lam' ["a"] $ var' "a") :: TTerm)
      (lam' ["x"] $ var' "x")
  , testCase "hash cycles" $ assertEqual "pingpong"
     (ABT.hash pingpong1)
     (ABT.hash pingpong2)
  ]

-- various unison terms, useful for testing

id :: TTerm
id = lam' ["a"] $ var' "a"

const :: TTerm
const = lam' ["x", "y"] $ var' "x"

one :: TTerm
one = num 1

zero :: TTerm
zero = num 0

plus :: TTerm -> TTerm -> TTerm
plus a b = ref (R.Builtin "+") `app` a `app` b

minus :: TTerm -> TTerm -> TTerm
minus a b = ref (R.Builtin "-") `app` a `app` b

fix :: TTerm
fix = letRec'
  [ ("fix", lam' ["f"] $ var' "f" `app` (var' "fix" `app` var' "f")) ]
  (var' "fix")

pingpong1 :: TTerm
pingpong1 =
  letRec'
    [ ("ping", lam' ["x"] $ var' "pong" `app` (plus (var' "x") one))
    , ("pong", lam' ["y"] $ var' "pong" `app` (minus (var' "y") one)) ]
    (var' "ping" `app` one)

pingpong2 :: TTerm
pingpong2 =
  letRec'
    [ ("pong1", lam' ["p"] $ var' "pong1" `app` (minus (var' "p") one))
    , ("ping1", lam' ["q"] $ var' "pong1" `app` (plus (var' "q") one)) ]
    (var' "ping1" `app` one)
