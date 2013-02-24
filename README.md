# THIS PLUGIN IS NOT MAINTAINED.

I will keep it up of course because it does work! However hacking jekyll to run mustache _inside_ of liquid is just wrong ... =/
I'm building yet another static blog generator from the ground up that natively supports mustache so perhaps that will catch your interest: http://ruhoh.com

## What 

**Mustache-for-jekyll** is a jekyll plugin that allows you to write your templates in Mustache rather than Liquid.

Jekyll uses the [Liquid templating language](https://github.com/Shopify/liquid) to parse its templates.
My immediate impression of liquid was "I really don't want to use this".
Liquid is very restrictive and very complicated to learn initially.
As a programmer I don't want to use a pseudo language abstraction when I can just use native ruby.

Mustache on the other hand is very powerful, expressive, and concise.
You can run any kind of ruby code you wish to format your data for the templates.

## Warning

As with _any_ Jekyll plugin, Your Jekyll site **can no longer be pushed to GitHub pages**.
GitHub does not run any plugins whatsoever so any plugin, including this one, will break your website if you host it on GitHub pages.

You can still host your website on GitHub but you have to pre-process your site and commit the `_site_` directory to your repo
which means you are effectively no longer tracking your Jekyll site, just the rendered output of your Jekyll site.

As well, you can host your Jekyll site yourself and run all your plugins to your hearts content.

## Why

- I didn't want to learn yet another templating language (liquid) 
- Mustache is much more powerful and intuitive than liquid.
- Liquid is just harder to use.

My original plan was to hack Jekyll itself to use a templating language of your choice (like Mustache).

The problem with this approach is it's a very narrow solution.  
You'd have to run the custom gem and above all this hack will _never_ make it into the main release.

It's important to remember that although I don't like Liquid as a programmer, Jekyll uses Liquid for a very important reason:

#### Liquid is secure. 

Jekyll powers GitHub pages and GitHub will run your site through Jekyll - this is very nice gesture.  
But GitHub will never run your custom ruby code on their server and so Liquid is very apt solution.

Therefore for the benefit of the community, I have released the Mustache solution as a plugin for anyone that wants to use it
and host their own Jekyll site.

But ultimately I think we should work toward moving Jekyll forward in a way
that GitHub will aprove of because anything else will just be complicated hacks.

My personal experience has been frustrating to work within the constraints of Jekyll, but
ultimately it's the best way to help the most people and move the project forward.

## Usage

This plugin works _with_ Liquid to parse content as Mustache templates.
**Important:** We still need liquid and the liquid tags because Jekyll depends on liquid.  
However what we can do is run Mustache alongside liquid as liquid Block tag.  

### How it works

1. Place the `jekstache.rb` file in your `_plugins` folder.  
This plugin registers a liquid block tag named `jekstache`.
2. Use the jekstache block tag to define a mustache template content.


... blah blah ..



## TODO

- Add demo jekyll website running mustache-with-jekyll
