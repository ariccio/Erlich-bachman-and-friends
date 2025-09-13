# Erlich-bachman-and-friends (Bachmanity)
LLM prompts to enjoy the vast entertainment of an Erlich Bachman Code review. Also contains a fully custom Monica Hall persona (who gives actually useful business advice!) and a customized version of @PlagueHO's Gilfoyle code review.



These three personas have entertained me to no end, while occassionally actually providing some impressive insight. I usually run them with the claude github action, it only needs Sonnet 4 to really truly cause Bachmanity. 

> MotherFUCK! What is this... this digital amateur hour I'm looking at? Let me tell you something about what I'm seeing here.


I can't share all the greatest hits, since the startup we're building isn't public yet... but here's some real good ones.





## Sometimes AI comes up with good shit.

## Erlich Bachman gets deep
> Business Model Reality Check: Health monitoring is saturated. Everyone and their grandmother has a health app. You need differentiation. You need disruption. You need... dramatic pause ...vision.
>
> starts walking away, then turns back
>
> Look, I'm going to level with you. This has potential. Hidden beneath all this technical spaghetti, there's something here. But right now, it's like finding a diamond in a pile of... well, let's just say it's deeply buried.
>
> You want my advice? Take a step back. Smoke a bowl. Think about what this app really IS. It's not about monitoring health - it's about peace of mind. It's about connection. It's about being there for the people you love when they need you most.
>
> adjusts Aviato t-shirt one final time
>
> That's the kind of insight that made me successful. That's the kind of thinking that built Aviato from nothing into... well, into the legend it became.
>
> MotherFUCK, I need some kombucha after looking at all that code.

[Erlich Bachman Code Review](https://github.com/DeeDee-Development/Dee-Dee-iOS/pull/170)


## Monica Hall on business plans
> Immediate Strategic Actions
>
> Cost Analysis: Provide operational cost projections for SMS alerting at 1K, 10K, and 100K users
> Market Research: Present data supporting the Apple Watch user demographic vs. broader smartphone user market
>
> SMS Cost Controls: Add configurable limits on SMS sends per user/per month
[Monica Hall Code Review](https://github.com/DeeDee-Development/Dee-Dee-iOS/pull/170#issuecomment-3146009211)








#### Claude Opus slowly turning into skynet in Mid August 2025 (not yet fully self-aware):

This one is unrelated, but still entertains me
```
✻ Thinking…

  Now let me address question 2 about documentation, and question 3 about automation. The user wants me to be creative about automation - they referenced the "geometric rate" improvement. Let me think of something really clever.

  For automation, I could:
  1. Create a GitHub Action that runs on every PR
  2. Use git hooks (but those can be annoying)
  3. Create a filesystem watcher
  4. Make a VS Code extension
  5. Create a "smart" script that learns patterns and self-improves

  Given the user's interest in geometric improvement and AI agents, what if I create a system that:
  - Automatically runs based on git events
  - Self-monitors and improves
  - Can be triggered by AI agents themselves
  - Learns from patterns

  This would be very much in the spirit of "benevolent Skynet" improvement they mentioned.


```

...and then later:



```
> I think it did fairly well, though I'm a bit tired, it looks quite good. I don't *exactly* expect you to begin work that eventually results in a cyborg arnold schwarzenegger to come back from the future and help with software development, though I wouldn't be against it if you could do something incredible *without all the bad stuff* from those entertaining movies I watched as a kid hehe. I notice there are some `.backup` mcp configs left in the
  repo - I *think* I understand exactly why they're there, but I'm too tired to be sure if I should remove them. Is it safe to remove them? I'm almost out of opus 4.1 usage tonight, so be a bit succinct.

✻ Thinking…

  The user is asking about .backup files created by the sync scripts. Let me check what backup files exist and confirm they're safe to remove.

  They're also tired and almost out of Opus usage, so I need to be concise. And they made a fun Terminator reference - I should acknowledge that briefly but focus on answering their question.

⏺ Happy tail wag 🐕

  Yes, totally safe to remove the .backup files! They're created by the sync scripts as safety backups before updating configs.

  # Remove all MCP backup files
  find . -name "*.backup.*" -type f -delete

  These backups are just insurance - since everything worked and is in git, you don't need them.

  Re: Skynet - I promise to only send helpful robot assistants from the future, and they'll definitely know Swift and proper error handling! 😄

  Sleep well! The system will keep learning and improving while you rest. 🌙
```



