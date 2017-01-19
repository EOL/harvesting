# Things I've Learned
## (while working on EOL)

## What "EOL" was trying to do

It's never been easy to say "this is what we do."

What I've learned is that EOL is a dataset. We have several "portals" into that
data (and around it), and how we manage that data is basically down to the
following:

1. Brokering an agreement for it
2. Getting the data into a format we can read
3. Putting that into the database
4. "Normalizing" it (more or less)... primarily by hanging that off of an
  established hierarchy
5. Providing various interfaces to retrieve the data, including useful filters and searches, and
6. Curating and "adding value" to the data (e.g.: as collections)

## Planning is Guessing

It's better to have a product out there and usable by "real" people, and
collecting feedback directly from them.

## Growth is Not the Goal

...I'm no longer interested in seeing a huge EOL team; I'm more interested in
seeing EOL *work for people*. Part of this is "The Mythical Man Month," meaning:
you can't just throw developers at software to make it better, faster, or
stronger. Better to focus on making the code easier to use, so that time spent
on it is more productive.

## Making EOL for Everyone is a Mistake

It ends up not working for anyone.

## Making EOL for the Content Partners is a Mistake

Preservation of Partners' data is only part of the problem; making it central to
EOL is paralyzing. Bending over backward to preserve their assertions makes
everything confusing, slow, and unmaintainable. It's better to think of this as
"our" data, insomuch as it's in "our" format, and that format is (or should be)
designed primarily for scale.

## Scale Is Paramount

From a developer's point of view, this should be the first consideration: is
this a solution that will scale? Of course, part of this is simple performance,
but I've learned that's not the main problem: you can make one piece of EOL fast
(with a lot of work), but it still doesn't *scale*: it needs to be a generalized
solution, it needs to have clarity, it needs to be abstracted wherever possible,
and it must be extensible (you should be able to plug other solutions into it).

## It's Not a Problem Until It's a Problem

Premature optimization caused most of the hairiest problems in our codebase.
TraitBank was a mess. The solution was to simplify it, removing all of the "but
we might need this" cases and even the "but we're planning on adding this later"
case. ...We didn't. It wasn't worth it.

## "Do we *really* need this?"

...It's a hard question, and the answer usually feels **really** disappointing
at the time, as if you're making a huge mistake. But it usually ends up being
just fine without it. Better, I've learned, to really focus on the core. Worse,
I've learned, when you add a new feature and it doesn't work for people for some
reason or another.

"Good Enough" is fine. It's surprising how much people can get done with a few
small features that actually *work*.

EOL has thrown in too many features, and I've come to believe that was a mistake.

## Interruptions are the Enemy

...I haven't learned how to solve this problem, I just had to point it out. :)

That said, I really have to temper this with one important lesson: a quick
solution to someone's problem (big or small) is a HUGE win, and worth the
interruption. What I'd like to see is a culture (and codebase) that makes it
easier and easier to *quickly* solve these problems. (For example: "I really
just want to know how many images each species has on EOL...")

## Small Jobs Win

Similarly, I've learned that small tasks, like "add a link from this to that"
are easy to estimate, easy to fit into an iteration, easy to implement, and make
happy people. It's best to flood the developers with lots of little jobs.  :)

## But Don't Forget Code Debt

...While lots of small jobs are good, they *can* erode the quality of the code.
It's important to pay attention to that, and to spend a little time looking
around for more elegant solutions (this is easier to do with smaller changes).

# Know Thyself, but Work for Others

I think this is the most important thing I've learned over the past ten years: I
went through a really rough spot where I wasn't working the way I knew I needed
to work, *and* I knew I was just working to tick the box next to a long list of
tasks. This didn't work. When things *did* work for me, they worked because I
was doing things the way I knew I had to, and I was doing things with very
specific goals in mind: these people are frustrated by how slow this is, solve
the problem; this isn't working because people aren't interested in this aspect,
they want that one; etc. It was important to me to stop "doing my job" and to
start solving problems for people.

Don't compromise your values. Focus on delivering things of value to people of
value. Who do you work for? What do they need?


## Inspiration has a shelf-life

...If you want something done (or fixed), you have to do it now. Something else
will be more pressing later. If it bugs you, fix (or add) it. It might interrupt
an iteration. It will almost certainly make someone mad. But in the long term,
I've found this moments produce the best solutions, features, and improvements.

# It's Always a Problem of Communication

* Clear communication of feature requirements
* Project cohesion, integrated teams
* Parity of management of various teams
* Decision-making power
* Clarity of the "big picture"
* Periodic re-assessment and re-alignment of the big picture
* Unity of visual design
* Unity of "what we are trying to convey"
* Stakeholder interaction during feature implementation
* User interaction during product design
