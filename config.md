<!--
Add here global page variables to use throughout your website.
-->

@def usesearcher = true
@def hasplotly = false
@def menu_items = [(c, "/references/$c/") for c in Char.(65:90)]
+++
author = "Jesús Mejía"
author_twitter = "https://twitter.com/_jmejia"
mintoclevel = 2
sitename = "Bilevel Optimization"
siteinfo = "Thousands of bibliographic references on bi-level optimization. Bi-level optimization consists of solving an optimization problem with another optimization problem as a constraint."
keywords = "bibliography, references,bilevel optimization"
domain = "repository.bi-level.org"


# Add here files or directories that should be ignored by Franklin, otherwise
# these files might be copied and, if markdown, processed by Franklin which
# you might not want. Indicate directories by ending the name with a `/`.
# Base files such as LICENSE.md and README.md are ignored by default.
ignore = ["node_modules/"]

# RSS (the website_{title, descr, url} must be defined to get RSS)
generate_rss = true
website_title = "Bilevel Optimization References"
website_descr = "Repository"
website_url   = "https://tlienart.github.io/FranklinTemplates.jl/"
+++

<!--
Add here global latex commands to use throughout your pages.
-->
\newcommand{\R}{\mathbb R}
\newcommand{\scal}[1]{\langle #1 \rangle}
