module CounterPairExample.App where

import CounterPairExample.Counter as Counter
import Control.Monad.Eff.Class (liftEff)
import Prelude (($), const, map, return, bind)
import Pux (noEffects, EffModel)
import Pux.Html (Html, div, button, text)
import Pux.Html.Events (onClick)
import Signal.Channel (Channel, send)

data Action
  = Top (Counter.Action)
  | Bottom (Counter.Action)
  | Reset
  | Nop

type State =
  { topCount :: Counter.State
  , chan :: Channel Action
  , bottomCount :: Counter.State }

init :: Channel Action -> Int -> State
init chan count =
  { topCount: Counter.init count
  , chan: chan
  , bottomCount: Counter.init count }

update :: forall eff. Action -> State -> EffModel State Action eff
update (Top action) state =
  noEffects $ state { topCount = Counter.update action state.topCount }
update (Bottom action) state =
  noEffects $ state { bottomCount = Counter.update action state.bottomCount }
update Reset state = { state: state { topCount = 0, bottomCount = 0 }
                     , effects:
                       [ do
                           liftEff $ send state.chan Nop
                           return Nop
                       ]
                     }

view :: State -> Html Action
view state = div
  []
  [ map Top $ Counter.view state.topCount
  , map Bottom $ Counter.view state.bottomCount
  , button [ onClick (const Reset) ] [ text "Reset" ]
  ]
