---
layout: post
author: matthias_geier
title: "PostgreSQL - Recursive data collection"
description: "Using stored procedures to recusively collect data"
category: "PostgreSQL"
tags: [rails4.0, postgresql, stored-proc]
---
{% include JB/setup %}

Using stored procedures is sometimes a very nice idea to collect recursive
data directly on the database.
Assuming a simple tree structure, it is a trivial (but not a very fast)
thing to implement it in Rails:

    belongs_to :parent [.....]

    def find_parents
      parents = [self]
      if self.parent_id.present?
        parents += self.parent.find_parents
      end
      return parents
    end

This will end in as many database queries as there are parents. The alternative
is to let the database take care of it. Instead we build a rather simple stored
procedure in PostgreSQL:

    CREATE LANGUAGE plpgsql;

    CREATE OR REPLACE FUNCTION ancestor_items(item_id integer)
    RETURNS SETOF item AS $$
      DECLARE
        next_item_id integer;
        item record;
      BEGIN
        next_item_id = item_id;
        LOOP
          SELECT INTO item * FROM items WHERE id=next_item_id;
          EXIT WHEN NOT FOUND;
          RETURN NEXT item;
          next_item_id = item.parent_id;
        END LOOP;
      END;
    $$ LANGUAGE plpgsql;

Running this stored procedure inside Rails is rather simple as well:

    ActiveRecord::Base.connection.execute('SELECT * FROM ancestor_items(15)')

Though this will only return a result set from psql, while it would be
preferable to get a Relation that is chainable and essentially a Rails-
native structure.
This can be achieved by picking the from-method:

    def find_ancestor_items(item_id)
      return Item.from("ancestor_items(#{item_id.to_i}) AS items")
    end

By using that snippet, the stored procedure is utilized, the regular finder
of ActiveRecord::Base is simulated and will work with any relation chain
in your code base.
