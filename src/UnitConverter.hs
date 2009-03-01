{-----------------------------------------------------------------
 
  (c) 2008-2009 Markus Dittrich 
 
  This program is free software; you can redistribute it 
  and/or modify it under the terms of the GNU General Public 
  License Version 3 as published by the Free Software Foundation. 
 
  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License Version 3 for more details.
 
  You should have received a copy of the GNU General Public 
  License along with this program; if not, write to the Free 
  Software Foundation, Inc., 59 Temple Place - Suite 330, 
  Boston, MA 02111-1307, USA.

--------------------------------------------------------------------}

-- | this module provides the functionality needed to do unit
-- conversions
module UnitConverter ( convert_unit ) where
                      

-- imports
import Data.Char
import qualified Data.Map as M


-- | function in charge of the main unit conversion
-- There are possible paths:
-- 1) The user did not supply a unit type specifier. In this case
--    we look through all available unit maps for a matching
--    conversion routine. If we find more than one we'll abort
--    with a hopefully useful error message.
-- 2) If a user supplies a unit type specifier we directly look
--    through the corresponding map for a conversion
convert_unit :: String -> String -> Maybe String -> Double 
             -> Either String (Double,String) 
convert_unit unit1 unit2 unitType value = 
    
  case unitType of
     -- no unit type specifier: look through all unit maps
    Nothing -> case unit_lookup (make_key unit1 unit2) allConv of
                 []        -> Left unit_conv_error 
                 a@(x:xs)  -> case length a of
                                1 -> Right ( (converter x $ value)
                                           , unit2 )
                                _ -> Left too_many_matches
      
    -- the user supplied a unit type: grab the proper map and look
    Just u -> case M.lookup u allConv of
                Nothing -> Left $ no_unit_error u
                Just a  -> case M.lookup (make_key unit1 unit2) a of
                             Nothing -> Left $ "In " ++ u ++ " :: "
                                                ++ unit_conv_error
                             Just x  -> Right ( (converter x $ value)
                                              , unit2 )
                   
  where
    -- unit conversion errors
    unit_conv_error  = "No unit conversion known for " 
                       ++ unit1 ++ " to " ++ unit2 ++ "!"

    no_unit_error a  = "Don't know unit " ++ a ++ "!"

    too_many_matches = "More than one unit conversion matched.\n"
                       ++ "Consider disambiguating with an explicit "
                       ++ "unit type."

    -- function generating the lookup key into the unit maps
    -- based on two given unit strings
    make_key :: String -> String -> String
    make_key unit1 unit2 = unit1 ++ unit2
    


-- | helper function looking through all unit maps for a matching
-- conversion routine
unit_lookup :: String -> M.Map String UnitMap -> [UnitConverter]
unit_lookup key = M.fold append_val [] 
   where
     append_val entry acc = case M.lookup key entry of
                              Nothing -> acc
                              Just a  -> a:acc


-- | UnitConverter holds all information known about 
-- a particular unit conversion 
data UnitConverter = 
    UnitConverter 
    { converter   :: (Double -> Double)  -- actual conversion fctn
    , description :: String              -- short description
    }


-- | unitMap holds all available conversions for a particular
-- unit type
type UnitMap = M.Map String UnitConverter


-- | allConv holds a map of all available unit conversions
-- indexed by the unit type such as Temp, Length, ....
allConv :: M.Map String UnitMap
allConv = M.fromList [ ("Temp", tempConv)
                     , ("Length", lengthConv)
                     ]


-- | temperature conversions
-- Most of them come from the NIST as published at
-- http://physics.nist.gov/Pubs/SP811/appenB9.html#TEMPERATURE

-- | data structure holding temparature conversions 
tempConv :: UnitMap
tempConv = M.fromList [ ("FC", fc_conv_temp) 
                      , ("CF", cf_conv_temp)
                      , ("CK", ck_conv_temp)
                      , ("KC", kc_conv_temp)
                      , ("FK", fk_conv_temp)
                      , ("KF", kf_conv_temp)
                      ]


-- | convert Fahrenheit to Celcius
fc_conv_temp = UnitConverter 
               { converter   = \x -> (5/9)*(x-32)
               , description = "Fahrenheit to Celsius"
               }

-- | convert Celcius to Fahrenheit
cf_conv_temp = UnitConverter 
               { converter   = \x -> (9/5)*x + 32
               , description = "Celsius to Fahrenheit"
               }


-- | convert Celius to Kelvin 
ck_conv_temp = UnitConverter 
               { converter   = \x -> x + 273.15
               , description = "Celsius to Kelvin"
               }


-- | convert Kelvin to Celcius
kc_conv_temp = UnitConverter 
               { converter   = \x -> x - 273.15
               , description = "Kelvin to Celcius"
               }


-- | convert Fahrenheit to Kelvin
kf_conv_temp = UnitConverter 
               { converter   = \x -> (5/9)*(x + 459.67)
               , description = "Fahrenheit to Kelvin"
               }

-- | convert Kelvin to Fahrenheit
fk_conv_temp = UnitConverter 
               { converter   = \x -> (9/5)*x - 459.67
               , description = "Fahrenheit to Kelvin"
               }


-- | length conversions
-- Most of them come from the NIST as published at
-- http://physics.nist.gov/Pubs/SP811/appenB9.html#LENGTH

-- | data structure holding length conversion 
lengthConv :: UnitMap
lengthConv = M.fromList [ ("mft", mf_conv_length) 
                        , ("ftm", fm_conv_length)
                        , ("min", mi_conv_length)
                        , ("inm", im_conv_length)
                        , ("mmi", mmi_conv_length)
                        , ("mim", mim_conv_length)
                        , ("kmmi", kmmi_conv_length)
                        , ("mikm", mikm_conv_length)
                        , ("myd", my_conv_length)
                        , ("ydm", ym_conv_length)
                        , ("mnmi", mnmi_conv_length)
                        , ("nmim", nmim_conv_length)
                        , ("kmnmi", kmnmi_conv_length)
                        , ("nmikm", nmikm_conv_length)
                      ]


-- | convert meter to foot
mf_conv_length = UnitConverter 
                 { converter   = ((1/0.3048)*)
                 , description = "meter to foot"
                 }


-- | convert foot to meter
fm_conv_length = UnitConverter 
                 { converter   = (0.3048*)
                 , description = "foot to meter"
                 }



-- | convert meter to inch
mi_conv_length = UnitConverter 
                 { converter   = ((1/0.0254)*)
                 , description = "meter to inch"
                 }


-- | convert inch to meter
im_conv_length = UnitConverter 
                 { converter   = (0.0254*)
                 , description = "inch to meter"
                 }


-- | convert meter to mile
mmi_conv_length = UnitConverter 
                 { converter   = ((1/1.609344e3)*)
                 , description = "meter to mile"
                 }


-- | convert mile to meter
mim_conv_length = UnitConverter 
                  { converter   = (1.609344e3*)
                 , description = "mile to meter"
                 }


-- | convert kilometer to mile
kmmi_conv_length = UnitConverter 
                 { converter   = ((1/1.609344)*)
                 , description = "kilometer to mile"
                 }


-- | convert mile to kilometer
mikm_conv_length = UnitConverter 
                  { converter   = (1.609344*)
                 , description = "mile to kilometer"
                 }


-- | convert meter to yard
my_conv_length = UnitConverter 
                 { converter   = ((1/0.9144)*)
                 , description = "meter to yard"
                 }


-- | convert yard to meter
ym_conv_length = UnitConverter 
                  { converter   = (0.9144*)
                 , description = "yard to meter"
                 }


-- | convert meter to nautical mile
mnmi_conv_length = UnitConverter 
                 { converter   = ((1/1.852e3)*)
                 , description = "meter to nautical mile"
                 }


-- | convert nautical mile to meter
nmim_conv_length = UnitConverter 
                  { converter   = (1.852e3*)
                 , description = "nautical mile to meter"
                 }


-- | convert kilometer to nautical mile
kmnmi_conv_length = UnitConverter 
                 { converter   = ((1/1.852)*)
                 , description = "kilometer to nautical mile"
                 }


-- | convert nautical mile to kilometer
nmikm_conv_length = UnitConverter 
                 { converter   = (1.852*)
                 , description = "nautical mile to kilometer"
                 }

