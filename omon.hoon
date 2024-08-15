=>  ..part
~%  %omon  +  ~
|%
+$  octs  (pair @ud @)
++  omon-form
  |$  [a]
  $-(octs [a octs])
::
++  omon
  ~/  %build
  |*  m2=mold
  ~%  %core  +  ~
  |%
  +$  form  (omon-form m2)
  ++  pure
    |=  a=m2
    ^-  form
    |=  =octs
    [a octs]
  ::
  ++  bind
    ~/  %bind
    |*  m1=mold
    ~/  %bind-baked
    |=  [a=(omon-form m1) b=$-(m1 form)]
    ^-  form
    ~/  %bind-fun
    |=  =octs
    :: ~&  !.(!=(read-bytes))
    =^  c  octs  (a octs)
    ((b c) octs)
  --
::
++  write-bytes
  |=  a=[src=@ off=@ len=@]
  =/  m  (omon ,~)
  ^-  form:m
  |=  =octs
  :: ~&  !.(!=(..write-bytes))
  =,  a
  ?>  (lte (add off len) p.octs)
  :-  ~
  :-  p.octs
  (sew 3 [off len src] q.octs)
::
++  read-bytes
  |=  [off=@ len=@]
  =/  m  (omon @)
  ^-  form:m
  |=  =octs
  :: ~&  !.(!=([off len]))
  ?>  (lte (add off len) p.octs)
  :_  octs
  (cut 3 [off len] q.octs)
--