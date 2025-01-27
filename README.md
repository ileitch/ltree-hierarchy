LTree Hierarchy
===============

A simplistic gem that allows ActiveRecord models to be organized in a tree or hierarchy. It uses a materialized path implementation based around PostgreSQL's [ltree](http://www.postgresql.org/docs/current/static/ltree.html) data type, associated functions and operators.

Why might you want to use it?
-----------------------------

- You want to be able to construct optimized hierarchical queries with ease, both from Ruby AND raw SQL.
- You want to be able to compose complex arel expressions from pre-defined building blocks.
- You prefer PostgreSQL over other relational DBs.

Getting started
---------------

Follow these steps to apply to any ActiveRecord model:

1. Install
 - Add to Gemfile: **gem 'ltree-hierarchy'**
 - Install required gems: **bundle install**
2. Add parent_id (integer) and path (ltree) columns to your table.
3. Add ltree hierarchy to your model
   - Add to app/models/[model].rb: has_ltree_hierarchy

Organizing records into a tree
------------------------------

Set the parent association or parent_id:

Node.create! :name => 'New York', :parent => Node.create!(:name => 'USA')

Navigating the tree
-------------------

The usual basic tree stuff. Use the following methods on any model instance:

- parent
- ancestors
- and_ancestors
- siblings
- and_siblings
- children
- and_children
- descendents
- and_descendents

Use the **roots** method on your model class to find all root nodes.

TODO
----

- Support PG 9.1+ CREATE EXTENSION syntax.
- Expose further ltree capabilities.
- Add scopes for selection by depth, methods for checking children etc.
- Support configuration options for magic column names. parent_id and path are currently hard-coded.
- Better error message for circular references. Don't neglect i18n.
