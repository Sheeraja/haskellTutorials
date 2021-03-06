-- Informatics 1 - Functional Programming 
-- Tutorial 3
--
-- Week 5 - Due: 22/23 Oct.

import Data.Char
import Data.List
import Test.QuickCheck



-- 1. Map
-- a.
uppers :: String -> String
uppers text = map (toUpper) text

-- b.
doubles :: [Int] -> [Int]
doubles xs = map (*2) xs

-- c.        
penceToPounds :: [Int] -> [Float]
penceToPounds xs = map (\x -> fromIntegral x / 100) xs

-- d.
uppers' :: String -> String
uppers' text = [toUpper character | character <- text]

prop_uppers :: String -> Bool
prop_uppers text = uppers text == uppers' text



-- 2. Filter
-- a.
alphas :: String -> String
alphas text = filter isAlpha text

-- b.
rmChar ::  Char -> String -> String
rmChar char text = filter (\x -> x /= (toLower char) && x /= (toUpper char)) text

-- c.
above :: Int -> [Int] -> [Int]
above least numbers  = filter (\x -> x > least) numbers

-- d.
unequals :: [(Int,Int)] -> [(Int,Int)]
unequals pairs = filter (\(x,y) -> x /= y) pairs

-- e.
rmCharComp :: Char -> String -> String
rmCharComp char text = [textChar | textChar <- text, textChar /= toLower char, textChar /= toUpper char]

prop_rmChar :: Char -> String -> Bool
prop_rmChar char text = rmChar char text == rmCharComp char text



-- 3. Comprehensions vs. map & filter
-- a.
upperChars :: String -> String
upperChars s = [toUpper c | c <- s, isAlpha c]

upperChars' :: String -> String
upperChars' text = filter (isAlpha) $ map (toUpper) text

prop_upperChars :: String -> Bool
prop_upperChars s = upperChars s == upperChars' s

-- b.
largeDoubles :: [Int] -> [Int]
largeDoubles xs = [2 * x | x <- xs, x > 3]

largeDoubles' :: [Int] -> [Int]
largeDoubles' xs = map (*2) $ filter (\x -> x > 3) xs

prop_largeDoubles :: [Int] -> Bool
prop_largeDoubles xs = largeDoubles xs == largeDoubles' xs 

-- c.
reverseEven :: [String] -> [String]
reverseEven strs = [reverse s | s <- strs, even (length s)]

reverseEven' :: [String] -> [String]
reverseEven' strs = map (reverse) $ filter (\x -> even $ length x) strs

prop_reverseEven :: [String] -> Bool
prop_reverseEven strs = reverseEven strs == reverseEven' strs



-- 4. Foldr
-- a.
productRec :: [Int] -> Int
productRec []     = 1
productRec (x:xs) = x * productRec xs

productFold :: [Int] -> Int
productFold numbers = foldr (*) 1 numbers

prop_product :: [Int] -> Bool
prop_product xs = productRec xs == productFold xs

-- b.
andRec :: [Bool] -> Bool
andRec [] = True
andRec (x:xs) = x && andRec xs

andFold :: [Bool] -> Bool
andFold xs = foldr (&&) True xs

prop_and :: [Bool] -> Bool
prop_and xs = andRec xs == andFold xs 

-- c.
concatRec :: [[a]] -> [a]
concatRec [] = []
concatRec (element:list) = element ++ concatRec list

concatFold :: [[a]] -> [a]
concatFold list = foldr (++) [] list

prop_concat :: [String] -> Bool
prop_concat strs = concatRec strs == concatFold strs

-- d.
rmCharsRec :: String -> String -> String
rmCharsRec _ [] = []
rmCharsRec [] text2 = text2
rmCharsRec (char:text1) text2 = rmCharsRec text1 $ rmChar char text2

rmCharsFold :: String -> String -> String
rmCharsFold text1 text2 = foldr (rmChar) text2 text1

prop_rmChars :: String -> String -> Bool
prop_rmChars chars str = rmCharsRec chars str == rmCharsFold chars str



type Matrix = [[Int]]


-- 5
-- a.
uniform :: [Int] -> Bool
uniform matrix = all (\x -> x == matrix !! 0) matrix

-- b.
valid :: Matrix -> Bool
valid [] = False
valid matrix = uniform [length x | x <- matrix]

-- 6.
-- a) 18

-- b)
zipWith' :: (a -> b -> c) -> [a] -> [b] -> [c]
zipWith' func list1 list2 = [func x y | (x,y) <- zip list1 list2]

-- c)
zipWith'' :: (a -> b -> c) -> [a] -> [b] -> [c]
zipWith'' function list1 list2 = map (uncurry function) $ zip list1 list2

-- 7.
plusM :: Matrix -> Matrix -> Matrix
plusM m1 m2 = zipWith (addRows) m1 m2
             where addRows xs ys = zipWith (+) xs ys

-- 8.
-- dot product
dot :: [Int] -> [Int] -> Int
dot vector1 vector2 = sum $ zipWith (*) vector1 vector2

timesM :: Matrix -> Matrix -> Matrix
timesM m1 m2 = [[dot rows cols | cols <- transpose m2]
                | rows <- m1]

-- Optional material
-- 9.