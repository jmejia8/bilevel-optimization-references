using PlotlyJS
include("utils.jl")

function interest_over_time()
  data = import_bibtex("references-bilevel.bib")

  years = String[]
  
  for k in keys(data)
    entry = data[k]
    year = xyear(entry) |> strip
    push!(years, year)
  end

  trace1 = histogram(;x=years,
                     marker=attr(color="rgb(49, 130, 189)",opacity=0.6,
                                 line = attr( color="white", width=1 )),
                     xbins = attr(size=1),
                    )
  data = [trace1]
  layout = Layout(;title = "Interest Over Time",
                  yaxis=attr(title="Number of papers"),
                  xaxis_tickangle=-45,
                  height=400,
                  barmode="group")
  plt = plot(data, layout)

  fdplotly(json(plt)) # hide
end

