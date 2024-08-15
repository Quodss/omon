/+  *omon
:-  %say  |=  *  :-  %noun
::
=<  ~>  %bout
    (run code "21+21=")
|%
++  parse
  |=  source=tape
  =/  m  (omon @)
  =/  edge=@  0
  |-  ^-  form:m
  ?~  source  (pure:m edge)
  ?:  ?|  =(i.source ',')
          =(i.source '.')
          =(i.source '<')
          =(i.source '>')
          =(i.source '+')
          =(i.source '-')
      ==
    ;<  ~  bind:m  (write-bytes i.source edge 1)
    $(source t.source, edge +(edge))
  ?:  |(=('[' i.source) =(']' i.source))
    ;<  ~  bind:m  (write-bytes i.source edge 1)
    $(source t.source, edge (add edge 5))
  $(source t.source)
::
++  fill-jumps
  |=  edge=@
  =/  m  (omon ,~)
  =/  ptr=@  0
  |-  ^-  form:m
  =*  outer  $
  ?:  =(ptr edge)  (pure:m ~)
  ;<  rid=@  bind:m  (read-bytes ptr 1)
  ?:  =(']' rid)
    ~|(%ser-not-open !!)
  ?.  =('[' rid)
    outer(ptr +(ptr))
  =/  depf  1
  =.  ptr  (add 5 ptr)
  =/  start=@  ptr
  |-  ^-  form:m
  =*  search-end  $
  ?:  =(ptr edge)  ~|(%sel-not-closed !!)
  ;<  rid1=@  bind:m  (read-bytes ptr 1)
  =.  rid  rid1  =>  +
  ?:  =('[' rid)
    search-end(ptr (add 5 ptr), depf +(depf))
  ?.  =(']' rid)
    search-end(ptr +(ptr))
  =.  depf  (dec depf)
  ?.  =(0 depf)
    search-end(ptr (add 5 ptr))
  =.  ptr  (add 5 ptr)
  =/  end=@  ptr
  ;<  ~  bind:m  (write-bytes end (sub start 4) 4)
  ;<  ~  bind:m  (write-bytes start (sub end 4) 4)
  ;<  ~  bind:m  outer(ptr start, edge (sub end 5))  ::  fill nested []
  outer
::
++  run
  |=  [source=tape input=tape]
  ^-  tape
  =|  output=tape
  =<  -  %.  [100.000 0]
  =/  m  (omon tape)
  ^-  form:m
  ;<  tape-start=@  bind:m  (parse source)
  ;<  ~             bind:m  (fill-jumps tape-start)
  =/  tape-ptr=@  tape-start
  =/  prog-ptr=@  0
  |-  ^-  form:m
  ?:  =(prog-ptr tape-start)  (pure:m (flop output))
  ;<  instr=@  bind:m  (read-bytes prog-ptr 1)
  ?+    instr  ~|(%weird-instr !!)
      %'+'
    ;<  char=@  bind:m  (read-bytes tape-ptr 1)
    ;<  ~  bind:m
      ?:  =(char 255)
        (write-bytes 0 tape-ptr 1)
      (write-bytes +(char) tape-ptr 1)
    $(prog-ptr +(prog-ptr))
  ::
      %'-'
    ;<  char=@  bind:m  (read-bytes tape-ptr 1)
    ;<  ~  bind:m
      ?:  =(char 0)
        (write-bytes 255 tape-ptr 1)
      (write-bytes (dec char) tape-ptr 1)
    $(prog-ptr +(prog-ptr))
  ::
      %'<'
    ?:  =(tape-ptr tape-start)  ~|(%out-of-bounds !!)
    $(prog-ptr +(prog-ptr), tape-ptr (dec tape-ptr))
  ::
      %'>'
    $(prog-ptr +(prog-ptr), tape-ptr +(tape-ptr))
  ::
      %','
    ?~  input  ~|(%input-block !!)
    ;<  ~  bind:m  (write-bytes i.input tape-ptr 1)
    $(prog-ptr +(prog-ptr), input t.input)
  ::
      %'.'
    ;<  char=@  bind:m  (read-bytes tape-ptr 1)
    $(prog-ptr +(prog-ptr), output [char output])
  ::
      %'['
    ;<  cond=@  bind:m  (read-bytes tape-ptr 1)
    ?:  =(0 cond)
      ;<  jmp=@  bind:m  (read-bytes +(prog-ptr) 4)
      $(prog-ptr jmp)
    $(prog-ptr (add 5 prog-ptr))
  ::
      %']'
    ;<  cond=@  bind:m  (read-bytes tape-ptr 1)
    ?:  =(0 cond)
      $(prog-ptr (add 5 prog-ptr))
    ;<  jmp=@  bind:m  (read-bytes +(prog-ptr) 4)
    $(prog-ptr jmp)
  ::
  ==
::
++  code
  """
  >> +
    [- >,>+< 
    ----- ----- ----- -----    ; checking with ascii 43 ie plus symbol
    ----- ----- ----- -----
    ---
    [
    +++++ +++++ +++++ +++++
    +++++ +++++ +++++ +++++
    +++
    < ] >>
    ]
    ; first input is over and terminated by a 'plus' symbol
    <->>>>>+
    [- >,>+<
    ----- ----- ----- -----   ; checking with ascii 61 ie = symbol
    ----- ----- ----- -----
    ----- ----- ----- ------
    [
    +++++ +++++ +++++ +++++
    +++++ +++++ +++++ +++++
    +++++ +++++ +++++ ++++++
    < ] >>
    ]
        ; second input is over and terminated by an = symbol
        ; now the array looks like 0 0 0 49 0 50 0 0 0 0 0 0 0 0 49 0 53 0 0 1 0
        ; for an input 12'plus'15=
    <<<<
    [<+<]
                ; filled with 1's in between
    + [<+>-<<[>-]>] ; This is a special loop to traverse LEFT through indefinite no of 0s
                ; Lets call it left traverse
    <<
    [<+<]
    >[>]<
                ; now the array looks like
                ; 0 0 1 49 1 50 0 0 0 0 0 0 0 1 49 1 53 0 0 1 for eg:12plus15
    [
    [->+>   + [>+<->>[<-]<]  ; Right traverse
        >>[>]<+ [<]
        + [<+>-<<[>-]>]  ; Left traverse
        <<-<
    ] 
    + [>+<->>[<-]<] 
    >> [>] <<-<[<]
    + [<+>-<<[>-]>]
    <<-<
    ]
              ; now actual addition took place
              ; ie array is 00000000000000 98 0 103 0 0 1
    + [>+<->>[<-]<]
    >>
    [ 
    ----- ----- ----- -----
    ----- ----- ----- -----
    ----- ---
    >>]
                ; minus 48 to get the addition correct as we add 2 ascii numbers
    >-<         ; well an undesired 1 was there 2 place after 103 right ? just to kill it
            ; now the array is 00000 00000 0000 50 0 55
            ; now comes the biggest task Carry shifting
    <<
    [<<]
    +++++ +++++ +++++ +++++
    +++++ +++++ +++++ +++++
    +++++ +++
    [>>]
        ; we added a 48 before all the digits in case there is an overall carry
        ; to make the size n plus 1
        ; array : 00000 00000 00 48 0 50 0 55
    <<
    <<
    [
    [>>->[>]>+>>>> >>>+<<<< <<<<<[<]><<]
    >+[>]>-
    [-<<[<]>+[>]>]
    >>>>>+>>>
    +++++ +++++ +++++ +++++ +++++
    +++++ +++++ +++++ +++++ +++++
    +++++ +++
    <
                ; comparison loop:  0   1   0   a      b  0
                ;                  (q) (p)    (num)  (58)
    [->-[>]<<]  ; comparison loop to check each digit with 58: greater means 
                ; we need to minus 10 and add 1 to next significant digit
    <[-
            ; n greater than or equal to 58 (at p)
            <<<< <<<
            [<]+
            >
            ----- ----- ; minus 10 to that digit
            <<+         ; plus 1 to next digit
            >
            [>]
            >>>>>>
    ]
    < [-<
            ; n less than 58 (at q)
            <<<<<<
            [<]+
            [>]
            >>>>>
      ]
        ; at (q)
        >>>[-]>[-]
        <<<<< <<<<<
        [<]>
        <<
    ]
        ; Its all over now : something like 0 48 0 52 0 66 ( ie 0 4 18 )
        ; will turn into 0 48 0 53 0 56 (ie 0 5 8)
    >>
    ----- ----- ----- -----
    ----- ----- ----- -----
    ----- ---
            ; here we are just checking first digit is 48 or not
            ; its weird to print 0 ahead but it is defenitely needed
            ; if it is 49 ie 1
    [
    +++++ +++++ +++++ +++++
    +++++ +++++ +++++ +++++
    +++++ +++
    .
    [-]
    ]
    >>
    [.>>]
    +++++ +++++
    .           ; to print nextline : ascii 10
  """
--
