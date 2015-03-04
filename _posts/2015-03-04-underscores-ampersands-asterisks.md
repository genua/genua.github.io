---
layout: post
author: matthias_geier
title: "Ruby 2.1 - Fun with underscores, ampersands and asterisks"
description: ""
category: Ruby
tags: [ruby2.1, ruby, variable assignment, special characters]
---
{% include JB/setup %}

Variable assignment in Ruby is a flexible thing. It allows you to do
helpful things and once you realize that function calls are not much
different from variable assignments, things become much easier and
the code becomes clearer. (Of course, internally a function call is
not the same as a variable assignment, yet its behaviour is similar,
which is what I am referring to).

# Variable assignment

## Basics

Starting with a simple example that can make array assignment beautiful.

    numbers = [4, 2, 7]
    a, b, c = numbers
    puts "a=#{a}, b=#{b}, c=#{c}" #=> a=4, b=2, c=7

This works for as many variables as you need, even when the array size
differs.

    numbers = [4]
    a, b, c = numbers
    puts "a=#{a}, b=#{b}, c=#{c}" #=> a=4, b=, c=

Ruby by default assigns nil to all variables it cannot find a match to.

    numbers = [4, 2, 7, 12, 1]
    a, b, c = numbers
    puts "a=#{a}, b=#{b}, c=#{c}" #=> a=4, b=2, c=7

As you can see, subsets work too.

## Underscore

Having worked so far with only named variables, introducing the underscore
will allow you to skip elements you do not need.

    numbers = [4, 1, 2, 7]
    a, _, b, c = numbers
    puts "a=#{a}, b=#{b}, c=#{c}" #=> a=4, b=2, c=7

The underscore adds as a placeholder for the variable matching inside Ruby.
It is just as *greedy* as any named variable, but as it is not named, you
cannot access it later on. This works of course with the earlier examples too,
when you only need a subset or have a smaller count of array elements.

In blocks it is possible to split an array into multiple variables by
putting the variables in parentheses. It is possible to skip elements
with the underscore again too, just like with regular array assignments
from earlier.

    arr = [["John", "Doe", 15], ["Jane", "Doe", 28]]
    arr.reduce("") do |acc, (name, _, age)|
      acc << "#{name} (#{age}) "
    end #=> Doe (15) Doe (28)

## Asterisk

Making things more complex and introducing the asterisk, which allows the
collection of remaining elements from an assignment. The representation for
the asterisk variable is always an array, whether it gets elements assigned
or not.

    numbers = [5, 4, 9, 2]
    a, b, *c = numbers
    puts "a=#{a}, b=#{b}, c=#{c.inspect}" #=> a=5, b=4, c=[9, 2]

Ruby only allows you to add one asterisk variable to the assignment which
acts as an array container for elements. The position of the asterisk variable
is flexible and does not need to be at the end.

    numbers = [5, 4, 9, 2]
    a, *b, c = numbers
    puts "a=#{a}, b=#{b.inspect}, c=#{c}" #=> a=5, b=[4, 9], c=2

Of course you can also add underscores. Additionally, Ruby allows the
combination of both underscore and asterisk which is especially useful
when you need for instance the first and last element from an array.

    numbers = [5, 4, 9, 2]
    a, *_, b = numbers
    puts "a=#{a}, b=#{b}" #=> a=5, b=2

The asterisk is also used for dereferencing variables. Later on in function
calls it will be used to pass the array content to a function as parameters.
Using the asterisk on a Hash will produce a slightly different behaviour,
it is more or less an alias on to_a.

    numbers = { :first => 1, :second => 2 }
    a, *_, b = *numbers
    puts "a=#{a.inspect}, b=#{b.inspect}" #=> a=[:first, 1], b=[:second, 2]

# Function calls

Moving on to function calls. As I mentioned earlier, in Ruby a function call
behaves similar to the variable assignment we have been doing for the earlier
part of the article. Function calls have some quirks though which will be
discussed in the next section.

## Applying variable assignment

When using function calls in Ruby, there is the regular call, in which you
call the function by name and hand it all the parameters it requires.

    def foo(a, b)
      puts "a=#{a}, b=#{b}"
    end
    foo(1, 2) #=> a=1, b=2

Or you can use what you know from the asterisk assignment and pass it an
array.

    my_b = [2, 3]
    def foo(a, b, c)
      puts "a=#{a}, b=#{b}, c=#{c}"
    end
    foo(1, *my_b) #=> a=1, b=2, c=3

Of course you can use one array for all arguments. The main issue you have
to take care of here is that each element of the array being passed is used
as one assignment. The parameters have to match the amount the function
actually requires, otherwise Ruby will throw an ArgumentError.

What worked in blocks earlier, of course works here as well.

    def foo(a, (b, c))
      puts "a=#{a}, b=#{b}, c=#{c}"
    end
    foo(1, [2, 3]) #=> a=1, b=2, c=3

Next up would be the underscore. The usefulness is a little questionable, but
thinking back I can recall one or two examples when it made sense. Remember
that an underscore is an unnamed variable and acts just as *greedy* as any
other named.

    def foo(_, b, _)
      puts "b=#{b}"
    end
    foo(1, 2, 3) #=> b=2

Collecting remaining arguments and therefore avoiding any ArgumentError can
be achieved by using the asterisk again. The placement of the asterisk is,
similar to variable assignment, up to you.

    def foo(*a, b)
      puts "a=#{a.inspect}, b=#{b}"
    end
    foo(1, 2, 3) #=> a=[1, 2], b=2

## Default values

Of course this is not the end of it. Ruby allows you to define defaults for
any parameter of the function. There are two rules to follow. First you need
to group all parameters that have a default together, you cannot split them.
Second is that default values are not greedy.

    def foo(a, b=5, c=6, d, e)
      puts "a=#{a}, b=#{b}, c=#{c}, d=#{d}, e=#{e}"
    end
    foo(1, 2, 3)       #=> a=1, b=5, c=6, d=2, e=3
    foo(1, 2, 3, 4)    #=> a=1, b=2, c=6, d=3, e=4
    foo(1, 2, 3, 4, 5) #=> a=1, b=2, c=3, d=4, e=5

It is possible to also add an asterisk parameter to a function with defaults.
The asterisk parameter needs to be defined after the block with all defaults,
that is mandatory.  That asterisk parameter ends up to be the least greedy.
First up all required parameters are satisfied, then from left to right all
defaults and whatever remains is put into the asterisk parameter.

    def foo(a, b=5, c=6, *d, e)
      puts "a=#{a}, b=#{b}, c=#{c}, d=#{d.inspect}, e=#{e}"
    end
    foo(1, 2)          #=> a=1, b=5, c=6, d=[], e=2
    foo(1, 2, 3)       #=> a=1, b=2, c=6, d=[], e=3
    foo(1, 2, 3, 4, 5) #=> a=1, b=2, c=3, d=[4], e=5

Conventionally it may make sense to order your parameters in such a way, that
all required are first, then all defaults and the asterisk after that.

## Ampersand

Methods and procs (that also works for lambdas) can be shortened or passed
into function by using the ampersand character. I have identified two usages
that I frequently use and increase readability and structure.

Method shortening is probably used in over half of the map calls I make in
Rails. It essentially hands the map a symbol of the method the map should
call on every element of an array. This can be any method name that takes
no parameters (defaults are fine) and map will raise you a NoMethodError or
ArgumentError should something go wrong.

    [1, 2, 3].map(&:to_s)
    => ["1", "2", "3"]

    [1, 2, 3].reduce(0, &:+)
    => 6

It is also possible to define your own block using a proc or lambda and
pass that instead of defining your *do...end* in place.

    p = Proc.new{ |i| i + i }
    [1, 2, 3].map(&p)
    => [2, 4, 6]

This can be especially useful when you have the same block you need to use
over and over again.

# Final thoughts

Ruby offers a set of tools that allow you to make your code readable and
explicit. It'd be a shame not to use them. I am especially a fan of the
variable assignment options, as they usually save me multiple lines of
splitting arrays into variables that have meaningful names.
