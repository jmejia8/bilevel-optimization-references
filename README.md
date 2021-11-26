# Bilevel Optimization Bibliography


References on bilevel optimization.

Homepage: [http://repository.bi-level.org](http://repository.bi-level.org)

## Adding New References

Firstly, install `Franklin.jl` on Julia (1.1 or later).

Identify references from Crossref. Suggestion:

```julia
using Pitaya

ENV["JULIA_MAILTO"]="your@email.com"
res = works(query="bilevel optimization 2021", limit=500);

for item in res["message"]["items"]
    println(item["URL"])
end
```

Follow the following steps to save new bibliographic sources.

1. Delete links in `txt/doi-uris.txt`
2. Paste the new DOIs (URL) in `txt/doi-uris.txt`
3. Run in terminal `include("utils.jl");generate_content()` to download the BIB files and update MD files.
4. Update index (search engine): `using Franklin;lunr()`
5. Open a local server to visualize the changes `using Franklin;serve()`.

Now, your are able to commit and push changes to the repo.

### License:

This work is licensed under the Creative Commons CC BY-NC-SA 4.0 license (Attribution Non-Commercial Share Alike International License version 4.0): [http://creativecommons.org/licenses/by-nc-sa/4.0/](http://creativecommons.org/licenses/by-nc-sa/4.0/)
