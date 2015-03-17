---
layout: post
author: martin_hauser
title: "Using partial function application and function composition in ruby"
description: "Exploring a few possibilities on how to improve the flow of
ruby code using functional specialities not commonly known to exist in ruby."
category: Ruby
tags: [ruby, functional]
---
{% include JB/setup %}

## Motivation

Those who have ever dabbled in any functional programming language recall that
partial function application and function composition are two interesting
concepts that allow a different approach to programming problems that
imperative programming languages, such as ruby, do not commonly provide.

Ruby is a curious beast, as it tries to include paradigmas from both the
imperative and the functional world to form a whole. When you are using our
everyday map or reduce, you are applying constructs commonly found in
functional programming languages, for example.

This post will explore some of the possibilities this 'best of two worlds'
approach of Ruby provides, regarding the paradigmas mentioned above.

## Partial function application

Functional programming languages contain a process that allows 'currying'
of functions, namely converting a function with several parameters into
several, nested functions which only take one parameter. This is done by
having functions generate functions which take a parameter. The below example
attempts to illustrate currying:

    def f(a, b)
      a + b
    end

    def g(a)
      ->(b) { a + b }
    end

    irb(main):013:0> g(1)
    => #<Proc:0x00171e3f4db628@(irb):2 (lambda)>
    irb(main):014:0> g(1).call(2)
    => 3

As you can see, the function g takes a parameter `a`, and returns a function
that takes a parameter `b`. The result of both `f` and `g` return  the same
result once all needed parameters have been specified.
However, instead of returning the result, `g` returns an anonymous function
with the parameter `a` being partially applied and the returned function
expecting the 2. parameter, `b`. Functions like this `g` are commonly refered
to as 'higher order functions'.

This approach works to explain partial function application and currying,
however, it quickly becomes cumbersome. However, ruby provides it's own
method `curry` to make this process easier.

Revisiting above's simple function `f` and the attempt to partially apply it:

    def f(a, b)
      a + b
    end

    irb(main):019:0> f_proc = self.method("f").to_proc
    => #<Proc:0x00171e3814b9b0 (lambda)>
    irb(main):021:0> f_proc.curry[1]
    => #<Proc:0x00171e37ceec50 (lambda)>
    irb(main):022:0> f_proc.curry[1][2]
    => 3
    irb(main):022:0> f_proc.curry.(1).(2)
    => 3
    irb(main):022:0> f_proc.curry[1,2]
    => 3
    irb(main):022:0> f_proc.curry.call(1,2)
    => 3

A few new things have been used in this example. Ruby does support currying
only on anonymous functions, thus using the `method` call we retrieve the
method object and use `to_proc` to convert it into an anonymous function.

The `to_proc` operator can be used in many ways and is more commonly known
to the ruby programmer by it's shorthand, the Ampersand operator. The
shorthand does not work when assigning variables, though.

Then there is `curry`. Curry turns a proc or lambda into it's "curried"
version, allowing it to be partially applied now. Function parameters can be
passed all usual ways a proc can be called, that means either using `call`,
using square brackets or the `.()` notation.

### Why use partial function application

Partial function application allows you to pass 'specialised' versions of your
functions to other functions, thus making some code a lot less cubersome. The
functions are automatically only executed once the last argument has been
applied and therefore can be used to 'delay' execution of specific operations
until they are needed.

This a little more complicated example might help to evaluate the power of
partial function application:

    def pretty_print_me(name, format, value)
      puts "section '#{name}' " + (format % value)
    end

    def print_current_var_state(pp_proc)
      pp_proc.call("%5d", 42)
      pp_proc["%-7s"]["hello"]
    end

    def section_printer(name)
      pp_proc = self.method("pretty_print_me").to_proc
      return pp_proc.curry[name]
    end

Using this example, the preferenced `pretty_print_me` can be passed to other
functions, e. g. to `print_current_var_state`:

    irb(main):002:0> pp = section_printer("prelude")
    => #<Proc:0x000756581767a8 (lambda)>
    irb(main):003:0> print_current_var_state(pp)
    section 'prelude'    42
    section 'prelude' hello
    => nil
    irb(main):004:0> pp = section_printer("main")
    => #<Proc:0x0007564c608ed0 (lambda)>
    irb(main):005:0> print_current_var_state(pp)
    section 'main'    42
    section 'main' hello
    => nil


## function composition

Another common paradigma in functional programming is 'function composition',
a method that allows to create new functions by connecting two functions
together. Most commonly functions are chained in a way that the output of the
first functions is fed into the second function, basically creating a function
that is the equivalent of `f(g(params))`.

For this, we create a new function `compose` that will allow one to create a
new function from two arbitary procs or lamdas (including methods converted
using the `method().to_proc` from above.):

    def compose(f, g)
      ->(*args) { g.call(f.call(*args)) }
    end

Using this `compose` function, composition is now possible, using
this to create new functions on the fly:

    irb(main):002:0> f = compose(:to_s.to_proc, :to_sym.to_proc)
    => #<Proc:0x000d4fe0f02070@test.rb:2 (lambda)>
    irb(main):003:0> f.call(5)
    => :"5"
    irb(main):004:0> f.call("/")
    => :/

A more complicated example using map and currying:

    irb(main):002:0> add = ->(i,j) { i + j }
    => #<Proc:0x000923d760a2f8@(irb):2 (lambda)>
    irb(main):003:0> add2 = z.curry[2]
    => #<Proc:0x000923d14270b8 (lambda)>
    irb(main):004:0> fn = compose(add2, :to_s.to_proc)
    => #<Proc:0x000923cbbbe548@test.rb:2 (lambda)>
    irb(main):005:0> [1, 2, 3].map(&fn)
    => ["3", "4", "5"]

A useful shorthand could be overloading the `*` operator of the Proc class
to call the `compose` function, however it is generally not recommended
opening core classes and should be avoided.

## Conclusion

Using the concepts of 'function composition' and 'partial function application'
allows to restructure some ruby code and subsequentially makes some tedious
tasks a lot easier, though care has to be taken to not produce 'unreadable'
code by overusing these concepts.
