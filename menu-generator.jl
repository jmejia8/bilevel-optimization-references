include("utils.jl")

MD_PATH = "references"


function main()
  !isdir(MD_PATH) && mkdir(MD_PATH)

  data = import_bibtex("references-bilevel.bib")

  sortrule(a, b) = begin
    atitle = xtitle(a) |> strip
    btitle = xtitle(b) |> strip
    ayear = xyear(a) |> strip
    byear = xyear(b) |> strip

    if atitle[1] < btitle[1]
      return true
    elseif atitle[1] == btitle[1] && ayear > byear
      return true
    end

    return false

  end

  sort!(data, lt = sortrule, by = x -> data[x])

  letter_old = '\0'
  md_txt = ""

  for k in keys(data)
    entry = data[k]


    authors = xnames(entry) |> tex2unicode
    link = xlink(entry)
    title = xtitle(entry) |> tex2unicode |> strip
    published_in = xin(entry) |> tex2unicode |> strip
    year = xyear(entry)
    letter = lowercase(title[1])


    if letter_old == '\0'
      letter_old = letter
    end

    if letter != letter_old
      l = uppercase(letter_old)
      fname = joinpath(MD_PATH, "$l.md")
      println("Generating ", fname)


      head = """
      +++
      title = "$(uppercase(letter_old))"
      hascode = false
      +++

      # $(uppercase(letter_old))
      """

      md_txt = head * md_txt

      open(fname,"w") do io
        println(io, md_txt)
      end

      md_txt = ""
      letter_old = letter
    end


    md_txt *= """
    ~~~
    <div class="reference">
    ~~~
    ### $title
    - **Authors**: $authors
    - **Published in**: $(linkify(published_in, link))
    ~~~
    </div>
    ~~~
    """

  end
end

main()

