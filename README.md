# Todo-Time MVP `Phoenix`

A `Elixir`/`Phoenix` implementation of the Todo-Time MVP feature set.

[![MVP-Loop](https://user-images.githubusercontent.com/194400/65666966-b28dbd00-e036-11e9-9d11-1f5d3e22258e.png)](https://agilevelocity.com/product-owner/mvp-mmf-psi-wtf-part-one-understanding-the-mvp)

> An often over-looked fact
of the Lean Startup "build-measure-learn" loop
is where the loop _starts_.
We contend that starting to build
_before_ doing some basic learning
is a recipe for wasted time/effort.
Instead people learn the (_basic_) _technical skills_
required to build the MVP
_before_ attempting to build.
Learn _technical skills **first**_
as you will be exposed to lots of new ideas
in both tech and UX which will fuel your build.
That's what we are doing in this project.



# Why? 🤷

Our objective with this MVP
is to build the minimal _useable_ App
that is well-documented, tested
and easy for a _beginner_ to understand.

The goal is to _ship_ this App to Heroku
and _use_ it (_internally_).
Once we have collected initial feedback,
we will implement Authentication
and share it with the world!



# _What_? 💭

A _hybrid_ list/task management
and activity (time) tracking tool. <br />
We have found it _tedious_ to use two _separate_ apps
for task and time tracking
and think it's _logical_ to _combine_ the functionality.

If the idea of combining tools
appeals to you keep reading.
If it sounds like a _terrible_ idea to you,
please just ignore this repo and have a great day!

“_If at first the idea is not absurd,
then there is no hope for it._”
~ [Albert Einstein](https://www.goodreads.com/quotes/110518-if-at-first-the-idea-is-not-absurd-then-there)

# _How_? 💡

As always,
our goal is to document as much of the implementation as possible,
so that _anyone_ can follow along.

If _anything_ is unclear please open an issue:


### Quick Note on Naming

If naming things is [hard](https://martinfowler.com/bliki/TwoHardThings.html),
choosing names for schemas/fields is _extra difficult_,
because once APIs are defined
it can be a _mission_ to modify them
because changing APIs "_breaks_" _everything_!
We have been thinking about,
researching and iterating on this idea for a _long_ time.
Hopefully it will be obvious to everyone _why_
a certain field is named the way it is,
but if not, please open an issue/question to seek clarification.




## Schema


+ `person` - the person using the App
(AKA the ["user"](https://github.com/dwyl/time/issues/33))
  or referred to in the reading tracker App (e.g: "author")
  + `id`: `Int`<sup>1</sup>
  + `inserted_at`: `Timestamp`
  + `updated_at`: `Timestamp`
  + `username`: `Binary`
    (_encrypted; personal data is never stored in plaintext_)
  + `username_hash`: `Binary`
    (_salted & hashed for fast lookup during registration/login_)
  + `givenName`: `Binary` (_encrypted_) - first name of a person
    https://schema.org/Person
  + `familyName`: `Binary` (_encrypted_) - last or surname of the person
  + `email`: `Binary` (_encrypted_) - so we can contact the person by email duh.
  + `email_hash`: `Binary` (_salted & hashed for quick lookup_)
  + `password_hash`: `Binary` (_encrypted_)
  + `key_id`: `String` - the ID of the encryption key
  used to encrypt personal data (NOT the key itself!)
  see:
  [dwyl/phoenix-ecto-**encryption**-**example**](https://github.com/dwyl/phoenix-ecto-encryption-example)
  + `status`: `Int` (**FK** `status.id`) - e.g: "0: unverified, 1: verified", etc.
  + `kind`<sup>4</sup>: `Int` (**FK** `kind.id`) - e.g: "reader" or "author"
  for our
  ["Reading Tracker"](https://github.com/nelsonic/time-mvp-phoenix/issues/3)


+ `item` - a basic unit of content.
  + `id`: `Int`
  + `inserted_at`: `Timestamp`
  + `updated_at`: `Timestamp`
  + `text`: `String`
  + `person_id`: `Int` (**FK** `person.id` the "owner" of the item)
  + `kind`<sup>4</sup>: `Int` (**FK** `kind.id`)
  + `status`: `Int` (**FK** `status.id`)


+ `kind` - the _kinds_<sup>2</sup> of `item` or `list` that can be created
  + `id`: `Int`
  + `inserted_at`: `Timestamp`
  + `updated_at`: `Timestamp`
  + `person_id`: `Int` (**FK** `person.id` -
      the person who defined or last updated the kind text)
  + `text`: `String` - examples:
    + "note"
    + "task"
    + "checklist"
    + "reading"
    + "shopping"
    + "exercise"
    + ["reminder"](https://github.com/nelsonic/time-mvp-phoenix/issues/5)
    + ["link"](https://github.com/nelsonic/time-mvp-phoenix/issues/4)
    + "quote"
    + "memo" - https://en.wikipedia.org/wiki/Memorandum
    + "image" - a link to an image stored on a file system (e.g: IPFS or S3)
    + "author" - in the case of a book author


+ `status` - the status of an item, list of items or person
  + `id`: `Int`
  + `inserted_at`: `Timestamp`
  + `updated_at`: `Timestamp`
  + `person_id`: `Int` (**FK** `person.id` - the person
      who defined/updated the status)
  + `text`: `String` - examples:
    + "unverified" - for a person that has not verified their email address
    + "open"
    + "complete"
    + [etc.](https://github.com/dwyl/checklist/pull/3/files#diff-597edb4596faa11c05c29c0d3a8cf94a)

> Plural form of "status" is "status":
https://english.stackexchange.com/questions/877/what-is-plural-form-of-status

+ `list`<sup>3</sup> - a collection of items
  + `id`: `Int`<sup>1</sup>
  + `title`: `String` - e.g: "_Alex's Todo List_"
  + `kind`<sup>4</sup>: `Int` (**FK** `kind.id`)
  + `order`: `Int` - Enum ["alphabetical", "date", "priority", "unordered"]
  + `status`: `Int` (**FK** `status.id`)


+ `list_items`
  + `item_id` (FK item.id)
  + `list_id` (FK list.id)
  + `inserted_at`


+ `timer` - a timer attached to an item. an item can have multiple timers.
  + `id`: `Int`
  + `inserted_at`
  + `item_id` (FK item.id)
  + `start`: `NaiveDateTime` - time started on device
  + `end`: `NaiveDateTime` - time ended on device


### Schema Notes

<sup>1</sup> We are using the `default` Phoenix auto-incrementing `id`
for all `id` fields in this MVP. When we _need_ to make the App "offline first"
we will transition to a Globally Unique [ContentID](https://github.com/dwyl/cid)

<sup>2</sup> We expect people to define their own kinds of lists
The UI will encourage people to create their own "kind"
and these will be curated to avoid duplication and noise.
For now we only need "task" list to get our "timer" working. <br />
Research kinds of list:
+ Kinds<sup>4</sup> of lists:
https://gist.github.com/shazow/2467329/f79c169b49831057c4ec705910c4e11df043e768
+ https://www.lifehack.org/articles/featured/12-lists-that-help-you-get-things-done.html

<sup>3</sup>
A "list" is a way of grouping items of content. <br />
An "essay" or "blog post" is a list of notes. <br />
A "task list" (_or "todo list" if you prefer_) is a list of tasks.

We are well aware that the word "list"
is meaningful in many programming languages. <br />
+ Elm: https://package.elm-lang.org/packages/elm/core/latest/List
+ Elixir: https://hexdocs.pm/elixir/List.html
+ Python: https://docs.python.org/3/tutorial/datastructures.html
+ etc.

We have chosen to use "list" as it's the most obvious word in _english_.
There is no suitable synonym:
https://www.thesaurus.com/browse/list

<sup>4</sup> We cannot use the word "type" as a field name,
because it will be confusing in programming languages
where `type` is either a reserved word or a language construct.
see: https://en.wikipedia.org/wiki/Type_system
Our "second choice" is the word "**kind**",
which is defined as: "_a group of things having similar characteristics_".
see: https://www.google.com/search?q=define+kind
Many thesaurus have "kind" and "type" as synonyms.
We feel this is the best choice because it's easy
for a beginner or non-native english speaker to understand.
e.g: <br />
**Q**: "What kind of list is it?" <br />
**A**: "It is a shopping list." <br />

While "kind" is a term in Type Theory,
see: https://en.wikipedia.org/wiki/Kind_(type_theory) <br />
it is _not_ a reserved word in any of the programming languages we know/use:
+ HTML: https://developer.mozilla.org/en-US/docs/Web/HTML/Element
+ CSS: https://developer.mozilla.org/en-US/docs/Web/CSS/Reference
+ Elixir: https://hexdocs.pm/elixir/master/syntax-reference.html
+ Erlang: http://erlang.org/doc/reference_manual/data_types.html
+ Go: https://golang.org/ref/spec
+ Haskell: https://wiki.haskell.org/Keywords
+ JavaScript:
https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Lexical_grammar#Keywords
+ Java: https://en.wikipedia.org/wiki/List_of_Java_keywords
+ Kotlin: https://kotlinlang.org/docs/reference/keyword-reference.html
+ Rust: https://doc.rust-lang.org/reference/keywords.html
+ Python: https://stackoverflow.com/questions/9642087/list-of-keywords-in-python
+ C++: https://en.cppreference.com/w/cpp/keyword
+ Swift: https://docs.swift.org/swift-book/ReferenceManual/LexicalStructure.html
+ Ruby: https://docs.ruby-lang.org/en/2.2.0/keywords_rdoc.html
+ PHP: https://www.php.net/manual/en/reserved.keywords.php

We have not considered any "Esoteric"
https://en.wikipedia.org/wiki/Esoteric_programming_language
or non-english programming languages
https://en.wikipedia.org/wiki/Non-English-based_programming_languages
because an exhaustive search is impractical.


## _Create_ Schemas

We want to be able to create, edit/update and view
all records in the database therefore we want
[`phx.gen.html`](https://hexdocs.pm/phoenix/Mix.Tasks.Phx.Gen.Html.html)
with views, so that we get "free" UI for creating/updating the data.


We will need to add `person_id` to `kinds` and `status` _after_
the person schema has been created. Person references kinds and status
(_i.e. there is a circular reference_).


This is the order in which the schemas need to be created
so that related tables can reference each other.
For example: People references Kinds and Status
so those need to be created first.

```
mix phx.gen.html Ctx Kind kinds text:string
mix phx.gen.html Ctx Status status text:string
mix phx.gen.html Ctx Person people username:binary username_hash:binary email:binary email_hash:binary givenName:binary familyName:binary password_hash:binary key_id:integer status:references:status kind:references:kinds
mix phx.gen.html Ctx Item items text:string person_id:references:people status:references:status kind:references:kinds
mix phx.gen.html Ctx List lists title:string person_id:references:people status:references:status kind:references:kinds
mix phx.gen.html Ctx Timer timers item_id:references:items start:naive_datetime end:naive_datetime person_id:references:people
```

After running these `phx.gen` commands,
we have the following Entity Relationship (ER) diagram:

![time-er-diagram](https://user-images.githubusercontent.com/194400/65640723-ee973280-dfe2-11e9-8a74-537b1cf467f8.png)

We now need to add `person_id` to `kinds` and `status`
to ensure that a human has ownership over those records.


```sh
mix ecto.gen.migration add_person_id_to_kind
mix ecto.gen.migration add_person_id_to_status
```

Code additions:
+ Add `person_id` to `kinds`:
https://github.com/nelsonic/time-mvp-phoenix/commit/11edd9f6532cfc3df33075bc0356955d041443d9
+ Add `person_id` to `status`:
https://github.com/nelsonic/time-mvp-phoenix/commit/efe6c14bc3a1a3c3c3684fa8e187e1e441934efb

ER Diagram With the `person_id` field
added to the `kinds` and `status` tables:

![time-app-er-diagram-person_id-status-kind](https://user-images.githubusercontent.com/194400/65705007-821e4100-e07f-11e9-8812-e0023e2d10e0.png)


Now we need to associate `items` to `lists`.

```
mix ecto.gen.migration create_list_items_association
```

![dwyl-time-app-er-diagram-list_items](https://user-images.githubusercontent.com/194400/61175870-b8830e80-a5ae-11e9-9e9b-1477ba3b5aa5.png)



## Reading Tracker


+ `author` = `person` with `kind="author"`
+  







## Run the App on `localhost`

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please
[check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
