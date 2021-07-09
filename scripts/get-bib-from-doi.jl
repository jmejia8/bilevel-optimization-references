using HTTP
using Bibliography
import DelimitedFiles: readdlm, writedlm

#=
using Pitaya

res = works(query="bilevel optimization", limit=500)

for item in res["message"]["items"]
   println(item["URL"])
end

=#

function move_bib_to_dirs()

  dirs = string.(Char.(65:90))
  # create dirs: A/, B/, C/,...
  for c in dirs
    dir = joinpath(BIB_FOLDER, c)
    !isdir(dir) && mkdir(dir)
  end

  @info "Moving bib to folders..."

  files = readdir(BIB_FOLDER)
  for file in files

    bib = joinpath(BIB_FOLDER, file)

    isdir(bib) && (continue)

    data = import_bibtex(bib)

    for k in keys(data)
      entry = data[k]
      title = xtitle(entry) |> strip


      dir = length(title) > 0 ? string(uppercase(title[1])) : "Z"
      if !(dir in dirs)
        dir = "Z"
      end

      bib_new = joinpath(BIB_FOLDER, dir, file)
      println(bib, " --> " , bib_new)
      mv(bib, bib_new)
      break
    end

  end

  @info "Done!"

end


function get_from_doi2bib(doi)
  id = doi[findall(c -> c=='/',  doi)[3]+1:end]
  url = "https://doi2bib.org/2/doi2bib/?id=" * id


  r = HTTP.request("GET",
                   url,
                   ["Accept" => "text/bibliography;style=bibtex"],
                   status_exception=false,
                   readtimeout = 10,
                  )

  if r.status != 200
    return nothing
  end

  return String(r.body)

end

function get_from_doiorg(doi) 
  doi = replace(doi, "dx.doi.org" => "doi.org")
  doi = replace(doi, "http:" => "https:")
  r = HTTP.request("GET",
                   doi,
                   ["Accept" => "text/bibliography;style=bibtex"],
                   status_exception=false,
                   readtimeout = 10,
                  )

  if r.status != 200
    return nothing
  end 

  return String(r.body)
end


function get_bib(doi)

  for provider in [get_from_doiorg, get_from_doi2bib]
    txt = provider(doi)

    if isnothing(txt)
      continue
    end




    try
      return import_bibtex(txt)
    catch
      continue
    end

  end

  nothing

end

function bib_id_to_fname(bib_id)
  rules = [
          "/" => "_",
          "." => "_",
          "," => "_",
          " " => "_",
          "\\" => "_",
          ]
  
  for p in rules
    bib_id = replace(bib_id, p)
  end

  return bib_id
end



function download_save_bib()
  !isdir(BIB_FOLDER) && mkdir(BIB_FOLDER)

  doi_uris = readdlm(NEW_DOI_URIS)

  if isfile(SAVED_DOI_URIS)
    doi_uris_saved = readdlm(SAVED_DOI_URIS)[:,1]
  else
    doi_uris_saved = String[]
  end


  if isfile(BANNED_DOI_URIS)
    doi_uris_banned = readdlm(BANNED_DOI_URIS)[:,1]
  else
    doi_uris_banned = String[]
  end
  

  counter = 0
  for doi in doi_uris
    doi = doi |> strip


    if doi in doi_uris_banned
      @info "This doi is banned: $doi"
      continue
    end

    if doi in doi_uris_saved
      @info "Already saved: $doi"
      continue
    end 
    
    @info "Downloading bib from $doi"

    bib = get_bib(doi)
    if isnothing(bib)
      push!(doi_uris_banned, doi)
      writedlm(BANNED_DOI_URIS, doi_uris_banned)
      @warn "Unable get valid bib\n"
      continue
    end
     

    @info "Saving bibtext file..."

    try
      save_bib(bib, doi_uris_saved, doi, counter)
    catch
      push!(doi_uris_banned, doi)
      writedlm(BANNED_DOI_URIS, doi_uris_banned)
      @warn "Error saving file [skipping]"
      continue
    end

    counter += 1
  end
  

end

function save_bib(bib, doi_uris_saved, doi, counter)
  print(xtitle(bib[bib.keys[1]]), "\nSave bib? Yes/no: ")
  answer = readline() |> strip |> lowercase
  if !isempty(answer) && answer[1] == 'n'
    @info "Ignored"
    println("---")
    error("ignore")
    return
  end

  fname = bib_id_to_fname(String(bib.keys[1]))
  fname = joinpath(BIB_FOLDER, fname * "_" * string(counter)* ".bib")

  Bibliography.export_bibtex(fname, bib)

  
  push!(doi_uris_saved, doi)
  @info "Done"
  println("---")
  writedlm(SAVED_DOI_URIS, doi_uris_saved)
end


function get_bib_files()
  download_save_bib()
  move_bib_to_dirs()
end

