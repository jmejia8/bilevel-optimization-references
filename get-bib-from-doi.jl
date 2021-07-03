using HTTP
using Bibliography
import DelimitedFiles: readdlm, writedlm

BIB_FOLDER = "bib-files"

function get_bib(doi)
  r = HTTP.request("GET",
                   doi,
                   ["Accept" => "text/bibliography;style=bibtex"],
                   status_exception=false,
                   readtimeout = 10,
                  )

  if r.status != 200
    return nothing
  end
  

  txt = String(r.body)

  return import_bibtex(txt)
end


function main()
  !isdir(BIB_FOLDER) && mkdir(BIB_FOLDER)

  doi_uris = readdlm("doi-uris.txt")
  if isfile("saved-doi-uris.txt")
    doi_uris_saved = readdlm("saved-doi-uris.txt")
  else
    doi_uris_saved = String[]
  end
  

  for doi in doi_uris
    doi = doi |> strip

    if doi in doi_uris_saved
      @info "Already saved: $doi"
      continue
    end
    
    @info "Downloading bib from $doi"

    bib = get_bib(doi)
    if isnothing(bib)
      @warn "Unable get bib"
      continue
    end



    fname = joinpath(BIB_FOLDER, String(bib.keys[1]) * ".bib")

    @info "Saving bibtext file"
    Bibliography.export_bibtex(fname, bib)
    push!(doi_uris_saved, doi)
    @info "Done"
    println("---")
  end
  
  writedlm("saved-doi-uris.txt", doi_uris_saved)

end

main()

