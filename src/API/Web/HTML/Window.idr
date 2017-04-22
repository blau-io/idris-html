--    Copyright 2017, the blau.io contributors
--
--    Licensed under the Apache License, Version 2.0 (the "License");
--    you may not use this file except in compliance with the License.
--    You may obtain a copy of the License at
--
--        http://www.apache.org/licenses/LICENSE-2.0
--
--    Unless required by applicable law or agreed to in writing, software
--    distributed under the License is distributed on an "AS IS" BASIS,
--    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--    See the License for the specific language governing permissions and
--    limitations under the License.

module API.Web.HTML.Window

import API.Web.HTML.Document
import API.Web.Time.HighResolution
import IdrisScript

%access public export
%default total

||| An HTML Window as of
||| https://html.spec.whatwg.org/multipage/browsers.html#window
record Window where
  constructor New
  ||| The `Document` associated with `window`.
  document : API.Web.HTML.Document.Document
  self     : Ptr

||| A FrameRequestCallback is the function to call when it's time to update an
||| animation for the next repaint. The callback has one single argument, a
||| DOMHighResTimeStamp, which indicates the current time for when
||| requestAnimationFrame starts to fire callbacks.
FrameRequestCallback : Type
FrameRequestCallback = DOMHighResTimeStamp -> JS_IO ()

||| RequestAnimationFrame tells the browser that you wish to perform an
||| animation and requests that the browser call a specified function to update
||| an animation before the next repaint. The method takes as an argument a
||| callback to be invoked before the repaint.
-- I would love to have this as a Nat instead of an Int. It is specified that
-- this method returns an unsigned long, but Javascript has a weird concept
-- of numbers, so we somehow ended up using Ints.
partial
requestAnimationFrame : Window -> FrameRequestCallback -> JS_IO $ Maybe Int
requestAnimationFrame (New _ self) callback = let
    id = jscall "%0.requestAnimationFrame(%1)"
                (JSRef -> JsFn FrameRequestCallback -> JS_IO JSRef)
                self (MkJsFn callback)
  in
    case !(IdrisScript.pack !id) of
         (JSNumber ** n) => pure $ Just $ fromJS n
         _               => pure Nothing

||| defaultWindow is a default implementation of Window, intended to be used in
||| in a browser.
defaultWindow : JS_IO $ Maybe Window
defaultWindow = case !maybeDocument of
    Nothing         => pure Nothing
    (Just document) => map Just $
                       API.Web.HTML.Window.New <$> pure document <*> self
  where
    self : JS_IO JSRef
    self = jscall "window" (JS_IO JSRef)

    maybeDocument : JS_IO $ Maybe API.Web.HTML.Document.Document
    maybeDocument = let
        docRef = join $ jscall "%0.document" (JSRef -> JS_IO JSRef) <$> self
      in
        -- right now, this will never fail, because an HTML Document is pretty
        -- much an empty type.
        Just <$> map API.Web.HTML.Document.New docRef

