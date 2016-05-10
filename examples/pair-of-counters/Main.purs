module CounterPairExample where

import CounterPairExample.App (init, update, view)
import Prelude (bind)
import Pux (start, fromSimple, renderToDOM)
import Signal.Channel (channel, subscribe)

main = do
  chan <- channel CounterPairExample.App.Nop
  let chanSignal = subscribe chan
  app <- start
    { initialState: init chan 0
    , update: update
    , view: view
    , inputs: [chanSignal]
    }

  renderToDOM "#app" app.html
