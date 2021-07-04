# constants
BIB_FOLDER      = "bib-files"  # contains bib files
MD_PATH         = "references" # Markdown files contaning references

STATISTICS_FILE = "txt/stats.txt"           # contains data to gen. stats
SAVED_DOI_URIS  = "txt/saved-doi-uris.txt"  # corresponding DOIs with bib
BANNED_DOI_URIS = "txt/banned-doi-uris.txt" # DOIs unable to get bib
NEW_DOI_URIS    = "txt/doi-uris.txt"        # New DOIs to be downloaded


import Bibliography: xnames, xyear, xlink, xtitle, xin, import_bibtex
import Bibliography
using Unicode

# engine
include("scripts/bibs-to-md.jl")
include("scripts/get-bib-from-doi.jl")
include("scripts/plot-statistics.jl")

function hfun_bar(vname)
  val = Meta.parse(vname[1])
  return round(sqrt(val), digits=2)
end

function hfun_m1fill(vname)
  var = vname[1]
  return pagevar("index", var)
end

function lx_baz(com, _)
  # keep this first line
  brace_content = Franklin.content(com.braces[1]) # input string
  # do whatever you want here
  return uppercase(brace_content)
end

tex2unicode_replacements = (
    "---" => "—", # em dash needs to go first
    "--"  => "–",
    "\\&"  => "&",
    "{\\'a}"  => "á",
    "{\\'e}"  => "é",
    "{\\'i}"  => "í",
    "{\\'o}"  => "ó",
    "{\\'u}"  => "ú",
    "{\\~n}"  => "ñ",
    r"\\`\{(\S)\}" => s"\1\u300", # \`{o} 	ò 	grave accent
    r"\\'\{(\S)\}" => s"\1\u301", # \'{o} 	ó 	acute accent
    r"\\\^\{(\S)\}" => s"\1\u302", # \^{o} 	ô 	circumflex
    r"\\~\{(\S)\}" => s"\1\u303", # \~{o} 	õ 	tilde
    r"\\=\{(\S)\}" => s"\1\u304", # \={o} 	ō 	macron accent (a bar over the letter)
    r"\\u\{(\S)\}" => s"\1\u306",  # \u{o} 	ŏ 	breve over the letter
    r"\\\.\{(\S)\}" => s"\1\u307", # \.{o} 	ȯ 	dot over the letter
    r"\\\\\"\{(\S)\}" => s"\1\u308", # \"{o} 	ö 	umlaut, trema or dieresis
    r"\\r\{(\S)\}" => s"\1\u30A",  # \r{a} 	å 	ring over the letter (for å there is also the special command \aa)
    r"\\H\{(\S)\}" => s"\1\u30B",  # \H{o} 	ő 	long Hungarian umlaut (double acute)
    r"\\v\{(\S)\}" => s"\1\u30C",  # \v{s} 	š 	caron/háček ("v") over the letter
    r"\\d\{(\S)\}" => s"\1\u323",  # \d{u} 	ụ 	dot under the letter
    r"\\c\{(\S)\}" => s"\1\u327",  # \c{c} 	ç 	cedilla
    r"\\k\{(\S)\}" => s"\1\u328",  # \k{a} 	ą 	ogonek
    r"\\b\{(\S)\}" => s"\1\u331",  # \b{b} 	ḇ 	bar under the letter
    r"\{\}" => s"",  # empty curly braces should not have any effect
    r"\\o" => s"\u00F8",  # \o 	ø 	latin small letter O with stroke
    r"\\O" => s"\u00D8",  # \O 	Ø 	latin capital letter O with stroke
    r"\\l" => s"\u0142",  # \l 	ł 	latin small letter L with stroke
    r"\\L" => s"\u0141",  # \L 	Ł 	latin capital letter L with stroke
    r"\\i" => s"\u0131",  # \i 	ı 	latin small letter dotless I

    # TODO:
    # \t{oo} 	o͡o 	"tie" (inverted u) over the two letters
    # \"{\i} 	ï 	Latin Small Letter I with Diaeresis

    # Sources : https://www.compart.com/en/unicode/U+0131 enter the unicode character into the search box
)


linkify(text, link) = isempty(link) ? text : "[$text]($link)"

function tex2unicode(s)
    for replacement in tex2unicode_replacements
        s = replace(s, replacement)
    end
    Unicode.normalize(s)
end


#hideall

function generate_content()
  get_bib_files()
  generate_md()
end

