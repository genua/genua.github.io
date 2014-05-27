---
layout: post
title: "Ruby - Dynamic inheritance pattern"
description: "A pattern for calling super in methods generated with define_method"
category: "Ruby"
tags: [pattern, object-orientation]
---
{% include JB/setup %}

Inheritance in Ruby works... as it should most of the time. Unless the method
is dynamically generated from a **Proc** or **lambda**. When that happens,
calling *super* is just not possible.

This pattern will describe how inheritance can be achieved on class methods
that are defined on demand.

As example serves a resolver scenario, in which we map a series of associations
to a single symbol. When calling the resolver it should either return all
mapped associations or the given search symbol.

    class A
      # default resolver
      def self.resolver(sym)
        return [sym]
      end

      def self.register_sym_map(sym, *assocs)
        @class_register ||= {}
        @class_register[sym] = assocs

        class << self
          define_method(:resolver) do |sym|
            if @class_register[sym]
              @class_register[sym]
            else
              self.class.superclass.method(:resolver).call(sym)
            end
          end
        end
      end
    end

    class B < A
      register_sym_map :group1, :assoc1, :assoc2, :assoc3
    end

    B.resolver(:group1)
    => [:assoc1, :assoc2, :assoc3]

    B.resolver(:group2)
    => [:group2]

Edges of this pattern are the class method on *A* which will always cap the
*super*-calling at *A* and the ability to override the *resolver* by hand
in any child class.

Alternatives to solve similar problems might be to have a class variable
inside the class methods (refering to the meta-class of *A* in our example)
and storing a hash-map of **class => sym => assocs** for access throughout
the application. Sometimes the class variable patter might be preferable, yet
its major disadvantage would be the need to traverse all ancestors by hand.
