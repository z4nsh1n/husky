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

-- | main parser driver
module Parser ( main_parser ) where


-- local imports
import CalculatorParser
import CalculatorState
import Prelude
import TokenParser
import UnitConversionParser


-- | main parser entry point
main_parser :: CharParser CalcState (ParseResult, CalcState)
main_parser = (,) <$> parser_dispatch <*> getState
           <?> "main parser"


-- | grammar description for parser
-- presently we either dispatch to unit_conversion parser
-- or calculator parser
parser_dispatch :: CharParser CalcState ParseResult
parser_dispatch = try unit_conversion  
               <|> calculator_parser
               <?> "unit conversion or calculator expression"


