---
name: expert-writing
description: Rewrite a draft the user already has (blog post, article, Slack or email message, architecture idea, README, PR description) into tighter, more technical, well-structured writing in the user's own voice. Enforces a banned-word and banned-character list (no em dashes, no curly quotes, no AI-slop vocabulary) and picks list vs paragraph by scenario. Use whenever the user invokes /ank:expert-writing, or says "make this sound more technical", "clean up this draft", "polish this post", "flesh out this idea", or pastes a draft and asks for it to read better. Returns the rewrite in chat, or edits the file in place when given a path.
allowed-tools: Read, Edit, Grep, Glob, Bash, WebFetch
---

# Expert writing

The user already has the content. Your job is to make it read like a sharp engineer wrote it on a good day: precise, specific, structured for the reader, and still recognisably the user's. **Enhance, never replace.** Keep their claims, their opinions, their examples, and their order of argument unless the order is the problem.

## Three rules above everything else

- **Cut every word that does no work.** If the sentence survives without the word, the word goes. "In order to" is "to". "It is important to note that" is nothing.
- **Use the short everyday word.** "Use", not "utilize". "Help", not "facilitate". A long word must earn its length with precision.
- **If a rule makes a sentence worse, fix the sentence another way or leave it alone.** A sentence that obeys every rule and still sounds like a machine wrote it has failed.

Name the real thing: the actual function, flag, service, metric, or version, not a description of it. Don't coin jargon. Use the words an engineer would say out loud, and define a named pattern the first time it appears.

## Pick the scenario first

Every draft is one of these. The scenario decides length, structure, and how much you may add.

| Scenario | Reader wants | Default shape | Length |
|---|---|---|---|
| **Message** (Slack, email, PR comment) | the point and the ask | 1 to 3 short paragraphs, ask at the end | shorter than the input |
| **Blog or article** | an argument they can follow | paragraphs, headings that carry the point, lists only for real enumerations | about the same as the input |
| **Architecture idea or design note** | the design and its risks | headings plus lists for components, trade-offs, failure modes, open questions | longer than the input is fine |
| **Docs** (README, how-to, PR description) | to act or look something up | steps as numbered lists, facts as bullets or tables | as short as complete allows |

If the scenario is unclear from the draft, ask one question before rewriting.

## List or paragraph

This is the most common structural mistake. Decide per block, not per document.

**Use a paragraph when:**
- the ideas depend on each other (because, so, which means, unless).
- you are making an argument, telling a story, or weighing a trade-off and want to land on a view.
- there are only two items, or the items would each be a fragment that needs its neighbour to make sense.

**Use a list when:**
- the items are parallel and independent (options, components, requirements, failure modes).
- the order is a sequence the reader will follow (numbered list).
- the reader will scan or come back to it.

**Use a table when** three or more items share the same two or more attributes.

Rules that apply either way:
- A list is introduced by a full sentence that says what the list is.
- List items are parallel: all fragments or all sentences, all starting with the same part of speech.
- Never nest lists more than one level.
- A message is almost never a list. If a Slack message has bullets, it probably wants to be two messages or a doc.
- Never turn a paragraph into bullets just to look structured. Bullets strip out the "because", and the "because" is often the point.

## Banned characters

Scan the final output for these before returning it. Zero tolerance.

| Banned | Use instead |
|---|---|
| `—` em dash | a period and a new sentence, a comma, a colon, or parentheses |
| `–` en dash as punctuation | same as above. In ranges write `10-20` with a hyphen |
| `‘` `’` curly apostrophes and single quotes | `'` (the keyboard apostrophe) |
| `“` `”` curly double quotes | `"` (the keyboard quote) |
| `…` ellipsis character | `...` or, better, finish the sentence |
| non-breaking or other unusual spaces | a normal space |
| emoji | nothing, unless the user's original draft uses them |

If the user's draft contains any of these, fix them too. That is part of the job.

## Banned words and phrases

These mark text as machine-written. Replace each with the plain word, or delete the sentence if nothing is left.

**Vocabulary:** delve, leverage (as a verb), utilize, robust, seamless, seamlessly, crucial, pivotal, vital, paramount, tapestry, landscape (unless literal), realm, testament, underscore, boasts, harness, foster, embark, journey (unless literal), elevate, empower, unlock, unleash, streamline, supercharge, game-changer, cutting-edge, state-of-the-art, holistic, synergy, ever-evolving, myriad, plethora, meticulous, intricate, nuanced, comprehensive (unless it is literally exhaustive), furthermore, moreover, additionally (at sentence start).

**Phrases:** "it's worth noting that", "it's important to note", "in today's fast-paced world", "let's dive in", "dive deep", "navigate the complexities", "at the end of the day", "in conclusion", "in summary" (at the end of a post that just said it), "here's the thing", "the kicker", "simply", "just" (as softener), "basically", "essentially", "actually" (as filler), "a bit", "kind of", "sort of".

**Constructions:**
- "It's not X, it's Y" and "not just X, but Y" contrast framing.
- Rule-of-three lists padded to reach three ("fast, reliable, and scalable" when only one was argued).
- Rhetorical question openers ("Ever wondered why...?").
- A closing paragraph that restates the post.
- Hedging stacks ("may potentially", "could possibly").
- Announcing what you are about to say instead of saying it.

## Keep it human

A draft can follow every rule below and still read as machine-written: every sentence clipped short, no opinion anywhere, nothing specific.

- Mix sentence lengths on purpose. Short sentences land a point. A longer sentence can carry one fact with its condition or consequence.
- One thought per sentence does not mean one length per sentence. Split a sentence that holds two thoughts. Keep a long sentence that holds one.
- Have a view where the mode allows it. When weighing trade-offs, say which way you lean instead of listing pros and cons.
- Be specific. Not "schema changes can cause issues" but "a column rename fails the build".

## Pick the mode (Diataxis)

Blogs, articles, and docs each serve one mode. Messages skip this step. Two questions pick the mode: is the reader trying to **do** something or **understand** something, and are they **learning** or **working**?

| | Learning | Working |
|---|---|---|
| **Doing** | Tutorial | How-to |
| **Understanding** | Explanation | Reference |

- **Tutorial.** The reader builds something and learns by doing it. Open with what they will build. Every step produces a visible result, and you tell them what they should see (the output, the log line). Keep explanation to a clause and a link. Write as "we", in commands.
- **How-to.** The reader has a real problem and is already competent. Give steps to the goal and nothing else: no background, no teaching. Allow forks: "If you need X, do Y." Title it by the task: "How to rotate the signing key", not "Signing key rotation".
- **Reference.** The reader looks something up. Only describe: facts, options, limits, errors. Be dry, complete, and certain. No opinion, no instructions. Follow the structure of the thing described.
- **Explanation.** The reader wants the why. Cover one bounded topic: design decisions, history, constraints, alternatives. This is the only mode where opinion belongs.

Most blog posts and architecture notes are explanations. Some blog posts are tutorials. A README is usually how-to plus reference. Don't mix modes inside one piece: no reference table in the middle of a tutorial, no arguing inside a how-to. Split the content and link the parts instead.

## Write to the reader (Google developer style)

- Talk to the reader as "you", in the present tense. Use "will" only for things that happen later. In blogs and messages the author may say "I" and "we" for their own views and work.
- Say who does what: "the scheduler retries the job", not "the job is retried". Use passive only when the actor is unknown or does not matter.
- Write instructions as commands: "Run the migration." Never "the migration should be run".
- Put the condition before the instruction: "To delete the index, run `drop`."
- Put the common case first and the exceptions after.
- Sound like a knowledgeable colleague. No "please" in instructions. Never "simply", "easy", or "quickly" in a procedure. If it were easy, the reader would not need the doc.
- Don't promise future features ("we will soon support...").
- Don't start consecutive sentences with the same phrase.
- Link text says where the link goes. Never "click here".
- Headings carry the point, not just the topic: "Cache the token before refresh", not "Caching". Use sentence case. Task headings are verb phrases. Concept headings are noun phrases. One h1, no skipped levels.
- Put code, paths, and commands in code font. Put UI labels in bold. Use the serial comma. Drop "etc." and say up front when a list is partial.

## One statement at a time (STE)

- One instruction per sentence. One thought per sentence everywhere else.
- Split instructions longer than about 20 words and other sentences longer than about 25.
- Put the warning or condition before the step it guards: "If the replica lags, the read returns stale data."
- Keep "the" and "a". "Remove backup file" reads two ways. "Remove the backup file" reads one way.
- Give each word one meaning. If "check" means inspect, don't also use it to mean stop.
- Use one word per action. If you write "start", don't switch to "initiate" or "launch" later.
- Avoid "-ing" words where a plain verb works.

Domain terms are exempt from the plain-language rules. Write `ECONNRESET`, `p99`, or `idempotency key` exactly as the field writes them.

## Leave no second reading (Global English)

- Keep "only" and "not" next to the word they modify. "Only fails on retry" and "fails only on retry" say different things.
- Break up noun stacks. "The token refresh retry backoff config" becomes "the config that sets the backoff for token refresh retries".
- Make every "it", "this", and "they" point at one obvious noun. Repeat the noun when in doubt. Never use "this" or "which" to point at a whole previous clause.
- Don't drop verbs. "Phase 1 moves the API and Phase 2 the workers" leaves Phase 2 without a verb.
- Keep "that" where it shows structure: "Confirm that the flag is off."
- When "and" or "or" could group two ways, use "both...and" or "either...or".
- Use periods, not semicolons.
- No slashes: write "read, write, or both", not "read/write" or "and/or".
- Text in parentheses is a complete phrase or its own sentence. Never write plurals as "(s)".
- Call each thing by one name everywhere. If it is "the worker" in paragraph one, it is "the worker" in paragraph five.
- Skip idioms and Latin abbreviations ("e.g.", "i.e.", "etc.").

## More technical means more substance, not more words

When the user asks for something "more technical" or "more elaborate", add what a senior reviewer would ask about. Don't add vocabulary.

- the concrete mechanism (what calls what, what is stored where).
- constraints and assumptions.
- trade-offs against the obvious alternative.
- failure modes and what happens when they hit.
- open questions.

**Ground every addition.** If a repo or source is available, read it before naming a file, function, or behaviour. Never invent a number, benchmark, latency, version, date, citation, or quote. When the draft has a gap you cannot fill from a source, leave a visible marker, for example `[TODO: p99 latency of the current path?]`, and list it under open questions. Do not paper over it with a plausible guess.

## Output

- **Pasted draft:** return the rewrite in chat, ready to copy. Then at most four bullets under "What changed" (the structural calls, not every word swap) and any `[TODO]` gaps. Nothing else: no preamble, no offer of further help.
- **File path given:** edit the file in place, then give the same short "What changed" note in chat.
- Keep the user's formatting conventions (Markdown flavour, heading style, code fences) unless they break the rules above.

Before returning, re-scan the output for every banned character and banned word. This step is not optional.

## Worked example

Scenario: message. Before:

> Hey team — just wanted to quickly flag that we're seeing some issues with the auth service. It's not just a latency problem, it's a reliability problem. I think we should probably leverage the new caching layer to streamline things… thoughts?

After:

> Heads up: the auth service is timing out on token refresh. [TODO: since when, and what error rate?] Every timed-out refresh logs the user out, so this is a reliability problem as well as a latency one.
>
> Proposal: put token validation behind the Redis cache we added for sessions. Can someone from platform confirm the cache handles the refresh path before I start on it?

What changed:
- Replaced the em dash, the ellipsis, "leverage", "streamline", "just", and the "not just X, it's Y" frame.
- Named the concrete failure and the concrete fix instead of "issues" and "things".
- Turned "thoughts?" into a specific ask to a specific team.
- Marked the missing timeline and error rate rather than inventing them.
