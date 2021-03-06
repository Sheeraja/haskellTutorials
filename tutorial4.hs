-- Informatics 1 - Functional Programming 
-- Tutorial 4
--
-- Due: the tutorial of week 6 (22/23 Oct)

import Data.List
import Data.Char
import Test.QuickCheck
import Network.HTTP (simpleHTTP,getRequest,getResponseBody)

-- <type decls>

type Link = String
type Name = String
type Email = String
type HTML = String
type URL = String

-- </type decls>
-- <sample data>

testURL     = "http://www.inf.ed.ac.uk/teaching/courses/inf1/fp/testpage.html"

testHTML :: String
testHTML =    "<html>"
           ++ "<head>"
           ++ "<title>FP: Tutorial 4</title>"
           ++ "</head>"
           ++ "<body>"
           ++ "<h1>A Boring test page</h1>"
           ++ "<h2>for tutorial 4</h2>"
           ++ "<a href=\"http://www.inf.ed.ac.uk/teaching/courses/inf1/fp/\">FP Website</a><br>"
           ++ "<b>Lecturer:</b> <a href=\"mailto:dts@inf.ed.ac.uk\">Don Sannella</a><br>"
           ++ "<b>TA:</b> <a href=\"mailto:m.k.lehtinen@sms.ed.ac.uk\">Karoliina Lehtinen</a>"
           ++ "</body>"
           ++ "</html>"

testLinks :: [Link]
testLinks = [ "http://www.inf.ed.ac.uk/teaching/courses/inf1/fp/\">FP Website</a><br><b>Lecturer:</b> "
            , "mailto:dts@inf.ed.ac.uk\">Don Sannella</a><br><b>TA:</b> "
            , "mailto:m.k.lehtinen@sms.ed.ac.uk\">Karoliina Lehtinen</a></body></html>" ]


testAddrBook :: [(Name,Email)]
testAddrBook = [ ("Don Sannella","dts@inf.ed.ac.uk")
               , ("Karoliina Lehtinen","m.k.lehtinen@sms.ed.ac.uk")]

-- </sample data>
-- <system interaction>

getURL :: String -> IO String
getURL url = simpleHTTP (getRequest url) >>= getResponseBody

emailsFromURL :: URL -> IO ()
emailsFromURL url =
  do html <- getURL url
     let emails = (emailsFromHTML html)
     putStr (ppAddrBook emails)

emailsByNameFromURL :: URL -> Name -> IO ()
emailsByNameFromURL url name =
  do html <- getURL url
     let emails = (emailsByNameFromHTML html name)
     putStr (ppAddrBook emails)

-- </system interaction>

-- <exercises>

-- 1.
sameString :: String -> String -> Bool
sameString [] [] = True
sameString [] _ = False
sameString _ [] = False
sameString (char1:text1) (char2:text2) | toLower char1 /= toLower char2 || 
                                         toUpper char1 /= toUpper char2 = False
                                       | otherwise = sameString text1 text2


-- 2.
prefix :: String -> String -> Bool
prefix [] [] = True
prefix [] _ = True
prefix _ [] = False
prefix (c1:pref) (c2:text) | toLower c1 == toLower c2 || toUpper c1 == toUpper c2 = prefix pref text
                           | otherwise = False

prop_prefix_pos :: String -> Int -> Bool
prop_prefix_pos str n =  prefix substr (map toLower str) &&
             prefix substr (map toUpper str)
                           where
                             substr  =  take n str

prop_prefix_neg :: String -> Int -> Bool
prop_prefix_neg str n = sameString str substr || (not $ prefix str substr)
                          where substr = take n str
        
        
-- 3.
contains :: String -> String -> Bool
contains text sub = sum [1 | x <- [0..(length text)], prefix sub $ drop x text] /= 0

prop_contains :: String -> Int -> Int -> Bool
prop_contains str m n = contains (map toLower str) substr &&
          contains (map toUpper str) substr
                    where
                      substr = take n (drop m str)


-- 4.
takeUntil :: String -> String -> String
takeUntil _ [] = ""
takeUntil sub (c:text) | prefix sub (c:text) = ""
                       | otherwise = c : takeUntil sub text

dropUntil :: String -> String -> String
dropUntil _ [] = ""
dropUntil sub (c:text) | prefix sub (c:text) = drop (length sub - 1) text
                       | otherwise = dropUntil sub text


-- 5.
split :: String -> String -> [String]
split [] _ = error "Splitter string has to be something"
split _ [] = [""]
split splitter text 
  | text `contains` splitter = [takeUntil splitter text] ++ split (splitter) (dropUntil splitter text)
  | otherwise = [text]

reconstruct :: String -> [String] -> String
reconstruct sub text = foldr (\listelem str -> if str /= "" then listelem ++ sub ++ str else listelem) "" text

prop_split :: Char -> String -> String -> Bool
prop_split c sep str = reconstruct sep' (split sep' str) `sameString` str
  where sep' = c : sep
  

-- 6.
linksFromHTML :: HTML -> [Link]
linksFromHTML html = tail $ split "<a href=\"" html

testLinksFromHTML :: Bool
testLinksFromHTML  =  linksFromHTML testHTML == testLinks


-- 7.
takeEmails :: [Link] -> [Link]
takeEmails list = filter (\x -> prefix "mailto" x) list


-- 8.
link2pair :: Link -> (Name, Email)
link2pair link | not $ prefix "mailto:" link = error "This is fucking wrong"
               | otherwise = (takeUntil "</a>" $ dropUntil "\">" link, 
                              takeUntil "\">" $ dropUntil "mailto:" link)


-- 9.
emailsFromHTML :: HTML -> [(Name,Email)]
emailsFromHTML html = nub $ map (link2pair) (takeEmails $ linksFromHTML html)

testEmailsFromHTML :: Bool
testEmailsFromHTML  =  emailsFromHTML testHTML == testAddrBook


-- 10.
findEmail :: Name -> [(Name, Email)] -> [(Name, Email)]
findEmail searched list = [(name,email) | (name,email) <- list, name `contains` searched]


-- 11.
emailsByNameFromHTML :: HTML -> Name -> [(Name,Email)]
emailsByNameFromHTML html searched = findEmail searched (emailsFromHTML html)


-- Optional Material

-- 12.
hasInitials :: String -> Name -> Bool
hasInitials initials name = initials == map (toUpper) (head (transpose (split " " name)))

-- 13.
emailsByMatchFromHTML :: (Name -> Bool) -> HTML -> [(Name, Email)]
emailsByMatchFromHTML = undefined

emailsByInitialsFromHTML :: String -> HTML -> [(Name, Email)]
emailsByInitialsFromHTML = undefined

-- 14.

-- If your criteria use parameters (like hasInitials), change the type signature.
myCriteria :: Name -> Bool
myCriteria = undefined

emailsByMyCriteriaFromHTML :: HTML -> [(Name, Email)]
emailsByMyCriteriaFromHTML = undefined

-- 15
ppAddrBook :: [(Name, Email)] -> String
ppAddrBook addr = unlines [ name ++ ": " ++ email | (name,email) <- addr ]