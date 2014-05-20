---
layout: post
title: "Ruby - Pattern for dynamically including modules"
description: "A pattern to include Modules by Object instance during
initialization"
category: "Ruby"
tags: [ruby, pattern, module-include]
---
{% include JB/setup %}

When using Single Table Inheritance or STI a huge amount of code is responsible
for determining the table name and creating instances, finders and the likes.
Sometimes it can be beneficial to use Modules instead of creating a child-
class, especially when considering the idea behind Concerns (the pattern before
Rails snatched the name), not to mention the gain when using a different ORM
that has no option for STI built-in.

Take an event class that is required to behave differently depending on the
event-type that is stored in an instance variable.

    class Event
      attr_accessor :type

      def run
        case @type
        when 'MouseEvent'
          puts "This is a mouse event"
        when 'KeyboardEvent'
          puts "This is a keyboard event"
        end
      end
    end

The use-case is quite similar to STI, create an abstract class and implement
all methods in the child-classes. Now let's do it with Modules.

    module MouseEvent
      def run
        puts "This is a mouse event"
      end
    end

    module KeyboardEvent
      def run
        puts "This is a keyboard event"
      end
    end

    class Event
      def initialize(type)
        if Module.const_defined?(type)
          self.singleton_class.send(:include, Module.const_get(type))
        end
      end
    end

    Event.new("MouseEvent").run
    This is a mouse event
    => nil

    Event.new("KeyboardEvent").run
    This is a keyboard event
    => nil

As shown above, the instance copy of Event is modified by send an include.
Dealing with nested Modules does not work yet and guarding the const_get seems
a bit much for an internal call that is a controlled environment and should
never process user input. The improved version looks like this.

    class String
      def constantize
        return self.to_s.split('::').reduce(Module){ |m, c| m.const_get(c) }
      end
    end

    module MouseEvent
      def run
        puts "This is a mouse event"
      end
    end

    module KeyboardEvent
      def run
        puts "This is a keyboard event"
      end
    end

    class Event
      def initialize(type)
        self.singleton_class.send(:include, type.constantize)
      end
    end

    Event.new("MouseEvent").run
    This is a mouse event
    => nil

    Event.new("KeyboardEvent").run
    This is a keyboard event
    => nil

It is pretty and not much code for the gain of it. A word of warning though,
as a collegue responded when he first heard the concept:

  There be dragons

Modifying the class copy *can* lead to a rollercoaster ride of debugging pain.
